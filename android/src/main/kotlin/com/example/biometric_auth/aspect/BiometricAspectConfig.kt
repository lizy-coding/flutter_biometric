package com.example.biometric_auth.aspect

/**
 * 生物识别切面配置
 */
data class BiometricAspectConfig(
    val title: String = "生物识别验证",
    val subtitle: String = "请验证您的身份",
    val description: String = "使用您的指纹、面容或其他生物特征进行身份验证",
    val negativeButtonText: String = "取消",
    val securedMethods: Set<String> = emptySet()
) 