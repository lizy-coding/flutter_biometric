package com.example.biometric_auth.api

import android.content.Context
import android.content.Intent
import androidx.fragment.app.FragmentActivity
import com.example.biometric_auth.annotation.BiometricAuthentication
import com.example.biometric_auth.aspect.BiometricAspectConfig
import com.example.biometric_auth.utils.BiometricAuthHelper

/**
 * 生物识别认证API入口类
 * 提供简洁统一的接口供外部调用
 */
object BiometricAuth {
    
    /**
     * 初始化模块配置
     * 
     * @param moduleName 模块名称
     * @param config 配置选项
     */
    fun init(moduleName: String, config: BiometricAspectConfig) {
        BiometricAuthHelper.initModule(moduleName, config)
    }
    
    /**
     * 创建一个带默认值的配置对象
     * 
     * @param title 认证对话框标题
     * @param subtitle 认证对话框副标题
     * @param description 认证对话框描述
     * @param negativeButtonText 取消按钮文本
     * @param securedMethods 需要保护的方法列表
     * @return 配置对象
     */
    fun createConfig(
        title: String = "生物识别验证",
        subtitle: String = "请验证您的身份",
        description: String = "使用您的指纹、面容或其他生物特征进行身份验证",
        negativeButtonText: String = "取消",
        securedMethods: Set<String> = emptySet()
    ): BiometricAspectConfig {
        return BiometricAspectConfig(
            title, subtitle, description, negativeButtonText, securedMethods
        )
    }
    
    /**
     * 检查设备是否支持生物识别
     * 
     * @param context 上下文
     * @return 是否支持
     */
    fun isSupported(context: Context): Boolean {
        return BiometricAuthHelper.isSupported(context)
    }
    
    /**
     * 显示生物识别认证对话框
     * 
     * @param activity 当前活动
     * @param title 对话框标题
     * @param subtitle 对话框副标题
     * @param description 对话框描述
     * @param negativeButtonText 取消按钮文本
     * @param onSuccess 认证成功回调
     * @param onFailure 认证失败回调
     * @param onError 认证错误回调
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
        BiometricAuthHelper.authenticate(
            activity, title, subtitle, description, negativeButtonText,
            onSuccess, onFailure, onError
        )
    }
    
    /**
     * 通过切面验证指定模块的方法
     * 
     * @param activity 当前活动
     * @param moduleName 模块名称
     * @param methodName 方法名称
     * @param onSuccess 成功回调
     * @param onError 错误回调
     */
    fun verifyMethod(
        activity: FragmentActivity,
        moduleName: String, 
        methodName: String,
        onSuccess: () -> Unit,
        onError: (Int, String) -> Unit = { _, _ -> }
    ) {
        BiometricAuthHelper.authenticateViaAspect(
            activity, moduleName, methodName, onSuccess, onError
        )
    }
    
    /**
     * 获取指纹管理API
     * 
     * @return 指纹管理器对象
     */
    fun getFingerprintManager(): FingerprintManager {
        return FingerprintManager
    }
    
    /**
     * 启动指纹管理界面
     * 
     * @param activity 当前活动
     */
    fun startFingerprintManager(activity: FragmentActivity) {
        // 直接启动界面，验证逻辑由界面自身处理
        val intent = Intent(activity, com.example.biometric_auth.ui.FingerprintManagerActivity::class.java)
        activity.startActivity(intent)
    }
}