package com.example.biometric_auth.utils

import android.content.Context
import androidx.fragment.app.FragmentActivity
import com.example.biometric_auth.aspect.BiometricAspect
import com.example.biometric_auth.aspect.BiometricAspectConfig
import com.example.biometric_auth.core.BiometricCallback
import com.example.biometric_auth.core.BiometricManager

/**
 * 生物识别帮助工具类
 * 提供简便的静态方法来初始化和使用生物识别功能
 */
object BiometricAuthHelper {
    
    private const val TAG = "BiometricAuthHelper"
    
    /**
     * 初始化模块的生物识别配置
     * 
     * @param moduleName 模块名称
     * @param config 生物识别配置
     */
    fun initModule(moduleName: String, config: BiometricAspectConfig) {
        BiometricAspect.getInstance().registerModule(moduleName, config)
    }
    
    /**
     * 检查设备是否支持生物识别
     * 
     * @param context 上下文
     * @return 是否支持
     */
    fun isSupported(context: Context): Boolean {
        return BiometricManager.isBiometricAvailable(context)
    }
    
    /**
     * 直接执行生物识别验证
     * 
     * @param activity 活动
     * @param title 标题
     * @param subtitle 副标题
     * @param description 描述
     * @param negativeButtonText 取消按钮文本
     * @param onSuccess 成功回调
     * @param onFailure 失败回调
     * @param onError 错误回调
     */
    fun authenticate(
        activity: FragmentActivity,
        title: String = "生物识别验证",
        subtitle: String = "请验证您的身份",
        description: String = "使用您的指纹、面容或其他生物特征进行身份验证",
        negativeButtonText: String = "取消",
        onSuccess: () -> Unit,
        onFailure: () -> Unit = {},
        onError: (Int, String) -> Unit = { _, _ -> }
    ) {
        BiometricManager.getInstance().showBiometricPrompt(
            activity,
            title,
            subtitle,
            description,
            negativeButtonText,
            object : BiometricCallback {
                override fun onAuthenticationSucceeded() {
                    onSuccess()
                }
                
                override fun onAuthenticationFailed() {
                    onFailure()
                }
                
                override fun onAuthenticationError(errorCode: Int, errorMessage: String) {
                    onError(errorCode, errorMessage)
                }
            }
        )
    }
    
    /**
     * 通过切面方式验证
     * 
     * @param activity 当前活动
     * @param moduleName 模块名称
     * @param methodName 方法名称
     * @param onSuccess 成功回调
     * @param onError 错误回调
     */
    fun authenticateViaAspect(
        activity: FragmentActivity,
        moduleName: String,
        methodName: String,
        onSuccess: () -> Unit,
        onError: (Int, String) -> Unit = { _, _ -> }
    ) {
        BiometricAspect.getInstance().authenticateBeforeExecution(
            activity,
            moduleName,
            methodName,
            onSuccess,
            onError
        )
    }
} 