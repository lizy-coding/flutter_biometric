import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_biometric_method_channel.dart';

abstract class FlutterBiometricPlatform extends PlatformInterface {
  /// Constructs a FlutterBiometricPlatform.
  FlutterBiometricPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBiometricPlatform _instance = MethodChannelFlutterBiometric();

  /// The default instance of [FlutterBiometricPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterBiometric].
  static FlutterBiometricPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterBiometricPlatform] when
  /// they register themselves.
  static set instance(FlutterBiometricPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  
  /// 检查设备是否支持生物识别
  Future<bool> isBiometricSupported() {
    throw UnimplementedError('isBiometricSupported() has not been implemented.');
  }
  
  /// 进行生物识别认证
  Future<bool> authenticate({
    String? title,
    String? subtitle,
    String? description,
    String? negativeButtonText,
  }) {
    throw UnimplementedError('authenticate() has not been implemented.');
  }
  
  /// 获取已存储的指纹数量
  Future<int> getFingerprintCount() {
    throw UnimplementedError('getFingerprintCount() has not been implemented.');
  }
  
  /// 获取所有已存储的指纹
  Future<List<String>> getAllFingerprints() {
    throw UnimplementedError('getAllFingerprints() has not been implemented.');
  }
  
  /// 添加新的指纹
  Future<bool> addFingerprint({String? fingerprintHash}) {
    throw UnimplementedError('addFingerprint() has not been implemented.');
  }
  
  /// 删除指定索引的指纹
  Future<bool> deleteFingerprint(int index) {
    throw UnimplementedError('deleteFingerprint() has not been implemented.');
  }
  
  /// 清除所有指纹
  Future<bool> clearAllFingerprints() {
    throw UnimplementedError('clearAllFingerprints() has not been implemented.');
  }
  
  /// 验证指纹
  Future<bool> verifyFingerprint(String fingerprintHash) {
    throw UnimplementedError('verifyFingerprint() has not been implemented.');
  }
  
  /// 设置测试指纹
  Future<bool> setupTestFingerprint() {
    throw UnimplementedError('setupTestFingerprint() has not been implemented.');
  }
  
  /// 测试指纹验证
  Future<bool> testFingerprintVerification() {
    throw UnimplementedError('testFingerprintVerification() has not been implemented.');
  }
  
  /// 显示指纹管理界面
  Future<bool> showFingerprintManager() {
    throw UnimplementedError('showFingerprintManager() has not been implemented.');
  }
}
