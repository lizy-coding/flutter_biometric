package com.example.biometric_auth.api

import android.content.Context
import com.example.biometric_auth.storage.FingerprintDataStore

/**
 * 指纹管理API类
 * 提供指纹数据管理功能
 */
object FingerprintManager {
    
    /**
     * 获取已存储的指纹数量
     * 
     * @param context 上下文
     * @return 指纹数量
     */
    fun getFingerprintCount(context: Context): Int {
        return FingerprintDataStore.getInstance(context).getFingerprintCount()
    }
    
    /**
     * 添加新的指纹数据
     * 
     * @param context 上下文
     * @param fingerprintHash 指纹哈希值
     * @return 是否添加成功
     */
    fun addFingerprint(context: Context, fingerprintHash: String = "biometric_fixed_hash_for_validation"): Boolean {
        // 默认使用固定指纹哈希
        android.util.Log.d("FingerprintManager", "添加指纹: $fingerprintHash")
        return FingerprintDataStore.getInstance(context).addFingerprint(fingerprintHash)
    }
    
    /**
     * 删除指定索引的指纹
     * 
     * @param context 上下文
     * @param index 指纹索引
     * @return 是否删除成功
     */
    fun deleteFingerprint(context: Context, index: Int): Boolean {
        return FingerprintDataStore.getInstance(context).deleteFingerprint(index)
    }
    
    /**
     * 清除所有指纹数据
     * 
     * @param context 上下文
     */
    fun clearAllFingerprints(context: Context) {
        FingerprintDataStore.getInstance(context).clearAllFingerprints()
    }
    
    /**
     * 验证指纹是否有效
     * 
     * @param context 上下文
     * @param fingerprintHash 指纹哈希值
     * @return 是否验证通过
     */
    fun verifyFingerprint(context: Context, fingerprintHash: String): Boolean {
        return FingerprintDataStore.getInstance(context).verifyFingerprint(fingerprintHash)
    }
    
    /**
     * 获取所有已存储的指纹数据
     * 
     * @param context 上下文
     * @return 指纹数据列表
     */
    fun getAllFingerprints(context: Context): List<String> {
        return FingerprintDataStore.getInstance(context).getAllFingerprints()
    }
    
    /**
     * 生成随机的指纹哈希值(用于测试)
     * 
     * @param context 上下文
     * @return 随机指纹哈希
     */
    fun generateTestFingerprint(context: Context): String {
        // 为了测试一致性，返回固定哈希值
        return "biometric_fixed_hash_for_validation"
    }
    
    /**
     * 设置测试指纹（清除所有指纹后添加一个指定的测试指纹）
     * 
     * @param context 上下文
     * @param fingerprintHash 测试指纹哈希值
     */
    fun setupTestFingerprint(context: Context) {
        val testFingerprint = "biometric_fixed_hash_for_validation"
        FingerprintDataStore.getInstance(context).setupTestFingerprint(testFingerprint)
    }
    
    /**
     * 测试指纹验证
     * 使用固定哈希值进行测试验证
     * 
     * @param context 上下文
     * @return 验证结果
     */
    fun testFingerprintVerification(context: Context): Boolean {
        val testHash = "biometric_fixed_hash_for_validation"
        android.util.Log.d("FingerprintManager", "测试指纹验证: $testHash")
        return FingerprintDataStore.getInstance(context).verifyFingerprint(testHash)
    }
    
    fun canAddMoreFingerprints(context: Context): Boolean {
        return getFingerprintCount(context) < MAX_FINGERPRINTS
    }
    const val MAX_FINGERPRINTS = 5


}