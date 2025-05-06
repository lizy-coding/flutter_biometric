package com.example.biometric_auth.aspect

import android.util.Log
import androidx.fragment.app.FragmentActivity
import com.example.biometric_auth.core.BiometricCallback
import com.example.biometric_auth.core.BiometricManager

/**
 * 生物识别切面
 * 用于在方法执行前进行生物识别验证
 */
class BiometricAspect private constructor() {
    companion object {
        private const val TAG = "BiometricAspect"
        
        @Volatile
        private var INSTANCE: BiometricAspect? = null
        
        fun getInstance(): BiometricAspect {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: BiometricAspect().also { INSTANCE = it }
            }
        }
    }
    
    // 存储需要生物识别验证的配置项
    private val aspectConfigMap = mutableMapOf<String, BiometricAspectConfig>()
    
    /**
     * 注册一个模块的生物识别配置
     * 
     * @param moduleName 模块名称
     * @param config 生物识别配置
     */
    fun registerModule(moduleName: String, config: BiometricAspectConfig) {
        aspectConfigMap[moduleName] = config
        Log.d(TAG, "已注册模块: $moduleName 的生物识别配置")
    }
    
    /**
     * 检查方法是否需要生物识别验证
     * 
     * @param moduleName 模块名称
     * @param methodName 方法名称
     * @return 是否需要验证
     */
    fun needsAuthentication(moduleName: String, methodName: String): Boolean {
        val config = aspectConfigMap[moduleName] ?: return false
        return config.securedMethods.contains(methodName)
    }
    
    /**
     * 在执行方法前进行生物识别验证
     * 
     * @param activity 当前活动
     * @param moduleName 模块名称
     * @param methodName 方法名
     * @param successCallback 验证成功回调
     * @param errorCallback 验证失败回调
     */
    fun authenticateBeforeExecution(
        activity: FragmentActivity,
        moduleName: String,
        methodName: String,
        successCallback: () -> Unit,
        errorCallback: (Int, String) -> Unit
    ) {
        val config = aspectConfigMap[moduleName] ?: run {
            Log.e(TAG, "模块 $moduleName 未注册生物识别配置")
            successCallback()
            return
        }
        
        if (!needsAuthentication(moduleName, methodName)) {
            successCallback()
            return
        }
        
        // 检查设备是否支持生物识别
        if (!BiometricManager.isBiometricAvailable(activity)) {
            Log.e(TAG, "设备不支持生物识别")
            errorCallback(-100, "设备不支持生物识别")
            return
        }
        
        // 显示生物识别对话框
        BiometricManager.getInstance().showBiometricPrompt(
            activity,
            config.title,
            config.subtitle,
            config.description,
            config.negativeButtonText,
            object : BiometricCallback {
                override fun onAuthenticationSucceeded() {
                    Log.d(TAG, "生物识别验证成功")
                    successCallback()
                }
                
                override fun onAuthenticationFailed() {
                    Log.e(TAG, "生物识别验证失败")
                    errorCallback(-101, "生物识别验证失败")
                }
                
                override fun onAuthenticationError(errorCode: Int, errorMessage: String) {
                    Log.e(TAG, "生物识别验证错误: $errorCode, $errorMessage")
                    errorCallback(errorCode, errorMessage)
                }
            }
        )
    }
} 