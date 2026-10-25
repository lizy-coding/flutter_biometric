package com.example.flutter_biometric

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// BiometricPrompt error codes (API 28 contract, stable across versions).
private const val ERROR_HW_UNAVAILABLE = 1
private const val ERROR_TIMEOUT = 5
private const val ERROR_LOCKOUT = 7
private const val ERROR_USER_CANCELED = 10
private const val ERROR_NO_BIOMETRICS = 11
private const val ERROR_HW_NOT_PRESENT = 12
private const val ERROR_NEGATIVE_BUTTON = 13
private const val ERROR_NO_DEVICE_CREDENTIAL = 14
private const val ERROR_LOCKOUT_PERMANENT = 9

// android.hardware.biometrics.BiometricPrompt.AuthenticationResultType value
// for credential-backed authentication (androidx returns the same int).
private const val AUTH_TYPE_DEVICE_CREDENTIAL = 2

/**
 * Biometric authentication adapter over the flutter_biometric/auth channel.
 * Self-registers through FlutterPlugin so the host app keeps only app-shell
 * native code. Every method replies with a typed status map; a missing or
 * non-Fragment activity degrades to `unavailable`, never a channel error.
 */
class FlutterBiometricPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private var channel: MethodChannel? = null
    private var appContext: Context? = null
    private var activity: FragmentActivity? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "flutter_biometric/auth").also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        appContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity as? FragmentActivity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity as? FragmentActivity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "queryCapabilities" -> result.success(queryCapabilities())
            "authenticate" -> authenticate(call, result)
            else -> result.notImplemented()
        }
    }

    private fun queryCapabilities(): Map<String, Any?> {
        val context = appContext ?: return emptyStatus()
        val manager = BiometricManager.from(context)
        val canStrong = canAuthenticate(manager, BiometricManager.Authenticators.BIOMETRIC_STRONG)
        val canWeak = canAuthenticate(manager, BiometricManager.Authenticators.BIOMETRIC_WEAK)
        val canCredential =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                canAuthenticate(manager, BiometricManager.Authenticators.DEVICE_CREDENTIAL)
            } else {
                BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED
            }

        // FEATURE_FACE distinguishes face hardware from fingerprint-only
        // devices, because BIOMETRIC_WEAK alone also succeeds via fingerprint.
        val fingerprintAvailable = canStrong == BiometricManager.BIOMETRIC_SUCCESS &&
            hasFeature(context, PackageManager.FEATURE_FINGERPRINT)
        val faceAvailable = canWeak == BiometricManager.BIOMETRIC_SUCCESS &&
            hasFeature(context, PackageManager.FEATURE_FACE)

        val enrolled = mutableListOf<String>()
        if (fingerprintAvailable) enrolled.add("fingerprint")
        if (faceAvailable) enrolled.add("face")

        val credentialAvailable = canCredential == BiometricManager.BIOMETRIC_SUCCESS
        return mapOf(
            "deviceSupported" to (fingerprintAvailable || faceAvailable || credentialAvailable),
            "fingerprintAvailable" to fingerprintAvailable,
            "faceAvailable" to faceAvailable,
            "deviceCredentialAvailable" to credentialAvailable,
            "enrolledTypes" to enrolled,
        )
    }

    private fun authenticate(call: MethodCall, result: MethodChannel.Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.success(unavailable("activity_unavailable", "当前没有可用的 FragmentActivity"))
            return
        }
        val reason = call.argument<String>("reason")
        if (reason.isNullOrBlank()) {
            result.success(invalidData("missing_reason", "认证原因不能为空"))
            return
        }
        val strength = call.argument<String>("strength") ?: "strong"

        // androidx throws on the platform thread when biometric and device
        // credential authenticators are combined below API 30; degrade to a
        // typed outcome instead of crashing the host app.
        if (strength == "strongWithCredential" &&
            Build.VERSION.SDK_INT < Build.VERSION_CODES.R
        ) {
            result.success(
                unavailable(
                    "combination_unsupported",
                    "当前系统版本不支持生物特征与设备凭据组合认证",
                )
            )
            return
        }

        val authenticators = when (strength) {
            "weak" -> BiometricManager.Authenticators.BIOMETRIC_WEAK
            "strongWithCredential" ->
                BiometricManager.Authenticators.BIOMETRIC_STRONG or
                BiometricManager.Authenticators.DEVICE_CREDENTIAL
            else -> BiometricManager.Authenticators.BIOMETRIC_STRONG
        }

        val builder = BiometricPrompt.PromptInfo.Builder()
            .setTitle(call.argument<String>("title") ?: "身份验证")
            .setAllowedAuthenticators(authenticators)
        val subtitle = call.argument<String>("subtitle")
        if (!subtitle.isNullOrBlank()) builder.setSubtitle(subtitle)
        if (strength != "strongWithCredential") {
            // androidx routes the negative button through the regular error
            // callback (ERROR_NEGATIVE_BUTTON); no listener is exposed.
            builder.setNegativeButtonText(call.argument<String>("negativeLabel") ?: "取消")
        }

        // Replies complete asynchronously from the prompt callbacks; the
        // platform main thread must stay free for those callbacks.
        var replied = false
        fun complete(map: Map<String, Any?>) {
            if (!replied) {
                replied = true
                result.success(map)
            }
        }
        val prompt = BiometricPrompt(
            currentActivity,
            ContextCompat.getMainExecutor(currentActivity),
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(authResult: BiometricPrompt.AuthenticationResult) {
                    // authenticationType is only meaningful on API 30+; the
                    // androidx 28-29 compatibility path is biometric-only by
                    // construction and reports an unreliable constant there.
                    val usedCredential =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            runCatching {
                                authResult.authenticationType == AUTH_TYPE_DEVICE_CREDENTIAL
                            }.getOrDefault(false)
                        } else {
                            false
                        }
                    complete(
                        mapOf(
                            "status" to "authenticated",
                            "usedDeviceCredential" to usedCredential,
                        )
                    )
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    complete(mapStatus(errorCode, errString.toString()))
                }
                // onAuthenticationFailed is a per-attempt mismatch; the prompt
                // stays up, so the reply waits for success or a final error.
            },
        )
        // Some OEM/SDK states reject prompt arguments with a throw instead of
        // routing them through the error callback; keep the channel
        // non-throwing like every other failure path here.
        try {
            prompt.authenticate(builder.build())
        } catch (error: IllegalArgumentException) {
            complete(invalidData("prompt_rejected", error.message ?: "系统拒绝了认证参数"))
        } catch (error: IllegalStateException) {
            complete(unavailable("prompt_unavailable", error.message ?: "认证提示不可用"))
        }
    }

    private fun mapStatus(errorCode: Int, message: String): Map<String, Any?> {
        val status = when (errorCode) {
            ERROR_USER_CANCELED, ERROR_NEGATIVE_BUTTON -> "userCancel"
            ERROR_TIMEOUT -> "timeout"
            ERROR_LOCKOUT -> "lockout"
            ERROR_LOCKOUT_PERMANENT -> "permanentlyLockedOut"
            ERROR_NO_BIOMETRICS -> "notEnrolled"
            ERROR_NO_DEVICE_CREDENTIAL -> "credentialNotSet"
            ERROR_HW_NOT_PRESENT -> "noHardware"
            ERROR_HW_UNAVAILABLE -> "hardwareUnavailable"
            else -> "failed"
        }
        return mapOf(
            "status" to status,
            "reason" to "android_error_$errorCode",
            "message" to message,
        )
    }

    private fun canAuthenticate(manager: BiometricManager, authenticators: Int): Int =
        runCatching { manager.canAuthenticate(authenticators) }
            .getOrElse { BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE }

    private fun hasFeature(context: Context, feature: String): Boolean =
        context.packageManager.hasSystemFeature(feature)

    private fun emptyStatus(): Map<String, Any?> = mapOf(
        "deviceSupported" to false,
        "fingerprintAvailable" to false,
        "faceAvailable" to false,
        "deviceCredentialAvailable" to false,
        "enrolledTypes" to emptyList<String>(),
    )
}

/** Status helpers mirroring the typed outcome reasons in Dart. */
private fun unavailable(reason: String, message: String): Map<String, Any?> = mapOf(
    "status" to "unavailable",
    "reason" to reason,
    "message" to message,
)

private fun invalidData(reason: String, message: String): Map<String, Any?> = mapOf(
    "status" to "invalidData",
    "reason" to reason,
    "message" to message,
)
