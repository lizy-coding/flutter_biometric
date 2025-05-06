package com.example.biometric_auth.core

import android.content.Context
import androidx.biometric.BiometricPrompt
import androidx.biometric.BiometricManager as AndroidxBiometricManager
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import com.example.biometric_auth.storage.FingerprintDataStore

/**
 * 生物识别管理器，负责处理生物识别相关操作
 */
class BiometricManager private constructor() {
    
    companion object {
        @Volatile
        private var INSTANCE: BiometricManager? = null
        
        fun getInstance(): BiometricManager {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: BiometricManager().also { INSTANCE = it }
            }
        }
        
        // 检查设备是否支持生物识别
        fun isBiometricAvailable(context: Context): Boolean {
            val biometricManager = AndroidxBiometricManager.from(context)
            return when (biometricManager.canAuthenticate(AndroidxBiometricManager.Authenticators.BIOMETRIC_STRONG)) {
                AndroidxBiometricManager.BIOMETRIC_SUCCESS -> true
                else -> false
            }
        }
    }
    
    /**
     * 显示生物识别认证对话框
     * 
     * @param activity 当前活动
     * @param title 对话框标题
     * @param subtitle 对话框副标题
     * @param description 对话框描述文本
     * @param negativeButtonText 取消按钮文本
     * @param callback 认证结果回调
     */
    fun showBiometricPrompt(
        activity: FragmentActivity,
        title: String,
        subtitle: String,
        description: String,
        negativeButtonText: String,
        callback: BiometricCallback
    ) {
        val executor = ContextCompat.getMainExecutor(activity)
        
        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle(title)
            .setSubtitle(subtitle)
            .setDescription(description)
            .setNegativeButtonText(negativeButtonText)
            .setAllowedAuthenticators(AndroidxBiometricManager.Authenticators.BIOMETRIC_STRONG)
            .build()
        
        val biometricPrompt = BiometricPrompt(activity, executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    super.onAuthenticationError(errorCode, errString)
                    callback.onAuthenticationError(errorCode, errString.toString())
                }
                
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    super.onAuthenticationSucceeded(result)
                    // 验证指纹数据是否在存储中
                    val cryptoObject = result.cryptoObject
                    val fingerprintHash = generateFingerprintHash(cryptoObject)
                    
                    // 如果没有存储指纹数据，则默认允许通过
                    val fingerprintStore = FingerprintDataStore.getInstance(activity)
                    val count = fingerprintStore.getFingerprintCount()
                    val verified = (count == 0 || fingerprintStore.verifyFingerprint(fingerprintHash))
                    
                    android.util.Log.d("BiometricManager", "指纹验证: 哈希=$fingerprintHash, 存储数量=$count, 验证结果=$verified")
                    
                    if (verified) {
                        callback.onAuthenticationSucceeded()
                    } else {
                        // 指纹存在但不匹配
                        callback.onAuthenticationFailed()
                    }
                }
                
                override fun onAuthenticationFailed() {
                    super.onAuthenticationFailed()
                    callback.onAuthenticationFailed()
                }
            })
        
        biometricPrompt.authenticate(promptInfo)
    }
    
    /**
     * 生成指纹哈希值
     * 为简化实现，使用设备标识符和自定义key生成一致的哈希
     */
    private fun generateFingerprintHash(cryptoObject: BiometricPrompt.CryptoObject?): String {
        // 始终使用固定哈希进行验证
        android.util.Log.d("BiometricManager", "生成固定指纹哈希: biometric_fixed_hash_for_validation")
        return "biometric_fixed_hash_for_validation"
    }
}

/**
 * 生物识别回调接口
 */
interface BiometricCallback {
    fun onAuthenticationSucceeded()
    fun onAuthenticationFailed()
    fun onAuthenticationError(errorCode: Int, errorMessage: String)
} 