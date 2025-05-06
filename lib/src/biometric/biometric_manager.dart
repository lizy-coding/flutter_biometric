import 'package:flutter/material.dart';
import 'package:flutter_biometric/flutter_biometric.dart';
import 'package:local_auth/local_auth.dart';

import 'biometric_service.dart';

/// 生物识别管理器
/// 负责协调local_auth库和原生插件的功能
class BiometricManager {
  final BiometricService _biometricService = BiometricService();
  final FlutterBiometric _nativePlugin = FlutterBiometric();
  
  /// 单例实现
  static final BiometricManager _instance = BiometricManager._internal();
  
  factory BiometricManager() => _instance;
  
  BiometricManager._internal();
  
  /// 检查设备生物识别可用性
  Future<BiometricStatus> checkBiometricStatus() async {
    // 先检查设备是否支持
    bool isSupported = await _biometricService.isBiometricsAvailable();
    if (!isSupported) {
      return BiometricStatus.unsupported;
    }
    
    // 检查是否已设置生物识别
    bool isEnrolled = await _biometricService.isBiometricsEnrolled();
    if (!isEnrolled) {
      return BiometricStatus.notEnrolled;
    }
    
    return BiometricStatus.available;
  }
  
  /// 获取可用的生物识别类型
  Future<List<BiometricType>> getAvailableBiometrics() {
    return _biometricService.getAvailableBiometrics();
  }
  
  /// 进行生物识别验证
  /// 
  /// [reason] - 验证原因
  /// [biometricOnly] - 是否仅使用生物识别
  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    return await _biometricService.authenticate(
      localizedReason: reason,
      biometricOnly: biometricOnly,
    );
  }
  
  /// 获取已存储的指纹数量
  Future<int> getFingerprintCount() {
    return _nativePlugin.getFingerprintCount();
  }
  
  /// 获取所有已存储的指纹
  Future<List<String>> getAllFingerprints() {
    return _nativePlugin.getAllFingerprints();
  }
  
  /// 添加新的指纹
  /// 先验证身份，然后进行指纹添加
  Future<bool> addFingerprint({String? fingerprintHash}) async {
    // 先进行身份验证
    bool isAuthenticated = await authenticate(
      reason: '请验证您的身份以添加新指纹',
    );
    
    if (!isAuthenticated) {
      return false;
    }
    
    // 通过原生插件添加指纹
    return await _nativePlugin.addFingerprint(fingerprintHash: fingerprintHash);
  }
  
  /// 删除指定索引的指纹
  /// 先验证身份，然后进行指纹删除
  Future<bool> deleteFingerprint(int index) async {
    // 先进行身份验证
    bool isAuthenticated = await authenticate(
      reason: '请验证您的身份以删除指纹',
    );
    
    if (!isAuthenticated) {
      return false;
    }
    
    // 通过原生插件删除指纹
    return await _nativePlugin.deleteFingerprint(index);
  }
  
  /// 清除所有指纹
  /// 先验证身份，然后清除所有指纹
  Future<bool> clearAllFingerprints() async {
    // 先进行身份验证
    bool isAuthenticated = await authenticate(
      reason: '请验证您的身份以清除所有指纹',
    );
    
    if (!isAuthenticated) {
      return false;
    }
    
    // 通过原生插件清除所有指纹
    return await _nativePlugin.clearAllFingerprints();
  }
  
  /// 显示系统指纹设置或原生指纹管理界面
  Future<void> showFingerprintSettings(BuildContext context) async {
    try {
      // 尝试显示原生指纹管理界面
      await _nativePlugin.showFingerprintManager();
    } catch (e) {
      // 如果失败，则显示对话框提示用户
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('无法打开指纹管理'),
            content: const Text('无法打开原生指纹管理界面，请前往系统设置手动管理指纹。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    }
  }
}

/// 生物识别状态枚举
enum BiometricStatus {
  /// 设备不支持生物识别
  unsupported,
  
  /// 设备支持但用户未设置生物识别
  notEnrolled,
  
  /// 生物识别可用
  available,
} 