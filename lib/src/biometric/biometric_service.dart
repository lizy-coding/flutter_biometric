import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

/// 统一管理生物识别功能的服务类
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  
  /// 单例实现
  static final BiometricService _instance = BiometricService._internal();
  
  factory BiometricService() => _instance;
  
  BiometricService._internal();
  
  /// 检查设备是否支持生物识别
  Future<bool> isBiometricsAvailable() async {
    try {
      // 检查是否有硬件支持
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      // 检查设备是否支持
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      
      return canCheckBiometrics && isDeviceSupported;
    } on PlatformException catch (e) {
      print('生物识别检查失败: ${e.message}');
      return false;
    }
  }
  
  /// 获取可用的生物识别类型
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('获取可用生物识别类型失败: ${e.message}');
      return [];
    }
  }
  
  /// 进行生物识别验证
  /// 
  /// [localizedReason] - 向用户显示的验证原因
  /// [biometricOnly] - 是否只使用生物识别（不允许PIN/密码）
  Future<bool> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
    bool useErrorDialogs = true,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          useErrorDialogs: useErrorDialogs,
          stickyAuth: true,
        ),
        authMessages: [
          // Android自定义消息
          const AndroidAuthMessages(
            signInTitle: '生物识别验证',
            biometricHint: '验证您的身份',
            cancelButton: '取消',
          ),
          // iOS自定义消息
          const IOSAuthMessages(
            cancelButton: '取消',
            goToSettingsButton: '设置',
            goToSettingsDescription: '请在设置中配置生物识别',
          ),
        ],
      );
    } on PlatformException catch (e) {
      print('生物识别验证失败: ${e.message}');
      if (e.code == auth_error.notAvailable) {
        print('设备不支持生物识别');
      } else if (e.code == auth_error.notEnrolled) {
        print('用户未设置生物识别');
      } else if (e.code == auth_error.lockedOut || e.code == auth_error.permanentlyLockedOut) {
        print('生物识别被锁定');
      }
      return false;
    }
  }
  
  /// 判断生物识别是否已经设置
  Future<bool> isBiometricsEnrolled() async {
    try {
      final availableBiometrics = await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      print('检查生物识别设置失败: $e');
      return false;
    }
  }
} 