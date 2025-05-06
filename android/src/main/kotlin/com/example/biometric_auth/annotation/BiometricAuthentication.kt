package com.example.biometric_auth.annotation

/**
 * 生物识别验证注解
 * 用于标记需要生物识别验证的方法
 */
@Target(AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
annotation class BiometricAuthentication 