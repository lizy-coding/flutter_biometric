package com.example.flutter_biometric

import android.content.Context
import androidx.fragment.app.FragmentActivity
import com.example.biometric_auth.api.BiometricAuth
import com.example.biometric_auth.api.FingerprintManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterBiometricPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private var activity: FragmentActivity? = null
  
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_biometric")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "isBiometricSupported" -> {
        result.success(BiometricAuth.isSupported(context))
      }
      "authenticate" -> {
        if (activity == null) {
          result.error("NO_ACTIVITY", "Activity is required for authentication", null)
          return
        }
        
        val title = call.argument<String>("title") ?: "生物识别验证"
        val subtitle = call.argument<String>("subtitle") ?: "请验证您的身份"
        val description = call.argument<String>("description") ?: "使用您的指纹、面容或其他生物特征进行身份验证"
        val negativeButtonText = call.argument<String>("negativeButtonText") ?: "取消"
        
        BiometricAuth.authenticate(
          activity!!,
          title,
          subtitle,
          description,
          negativeButtonText,
          onSuccess = {
            result.success(true)
          },
          onFailure = {
            result.success(false)
          },
          onError = { errorCode, errorMessage ->
            result.error(errorCode.toString(), errorMessage, null)
          }
        )
      }
      "getFingerprintCount" -> {
        result.success(FingerprintManager.getFingerprintCount(context))
      }
      "getAllFingerprints" -> {
        result.success(FingerprintManager.getAllFingerprints(context))
      }
      "addFingerprint" -> {
        val fingerprintHash = call.argument<String>("fingerprintHash") ?: "biometric_fixed_hash_for_validation"
        result.success(FingerprintManager.addFingerprint(context, fingerprintHash))
      }
      "deleteFingerprint" -> {
        val index = call.argument<Int>("index")
        if (index == null) {
          result.error("INVALID_ARGUMENT", "Index is required", null)
          return
        }
        result.success(FingerprintManager.deleteFingerprint(context, index))
      }
      "clearAllFingerprints" -> {
        FingerprintManager.clearAllFingerprints(context)
        result.success(true)
      }
      "verifyFingerprint" -> {
        val fingerprintHash = call.argument<String>("fingerprintHash")
        if (fingerprintHash == null) {
          result.error("INVALID_ARGUMENT", "Fingerprint hash is required", null)
          return
        }
        result.success(FingerprintManager.verifyFingerprint(context, fingerprintHash))
      }
      "setupTestFingerprint" -> {
        FingerprintManager.setupTestFingerprint(context)
        result.success(true)
      }
      "testFingerprintVerification" -> {
        result.success(FingerprintManager.testFingerprintVerification(context))
      }
      "showFingerprintManager" -> {
        if (activity == null) {
          result.error("NO_ACTIVITY", "Activity is required for showing fingerprint manager", null)
          return
        }
        BiometricAuth.startFingerprintManager(activity!!)
        result.success(true)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
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
} 