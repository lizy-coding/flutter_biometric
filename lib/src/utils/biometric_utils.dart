import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

/// 生物识别类型的辅助工具类
class BiometricUtils {
  /// 获取生物识别类型的用户友好名称
  static String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return '面容识别';
      case BiometricType.fingerprint:
        return '指纹识别';
      case BiometricType.strong:
        return '强加密生物识别';
      case BiometricType.weak:
        return '弱加密生物识别';
      default:
        return '未知';
    }
  }
  
  /// 获取生物识别类型的图标
  static IconData getBiometricTypeIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return Icons.face;
      case BiometricType.fingerprint:
        return Icons.fingerprint;
      case BiometricType.strong:
        return Icons.security;
      case BiometricType.weak:
        return Icons.security;
      default:
        return Icons.help_outline;
    }
  }
  
  /// 格式化指纹哈希值，隐藏部分数据
  static String formatFingerprintHash(String hash) {
    if (hash.length <= 8) return hash;
    
    final start = hash.substring(0, 4);
    final end = hash.substring(hash.length - 4);
    
    return '$start....$end';
  }
  
  /// 检查默认的测试指纹哈希值
  static bool isTestFingerprint(String hash) {
    return hash == 'biometric_fixed_hash_for_validation';
  }
} 