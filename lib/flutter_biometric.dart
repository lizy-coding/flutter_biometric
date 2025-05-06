import 'flutter_biometric_platform_interface.dart';

class FlutterBiometric {
  /// 获取平台版本信息
  Future<String?> getPlatformVersion() {
    return FlutterBiometricPlatform.instance.getPlatformVersion();
  }
  
  /// 检查设备是否支持生物识别
  Future<bool> isBiometricSupported() {
    return FlutterBiometricPlatform.instance.isBiometricSupported();
  }
  
  /// 进行生物识别认证
  /// 
  /// [title] - 认证对话框标题
  /// [subtitle] - 认证对话框副标题
  /// [description] - 认证对话框描述
  /// [negativeButtonText] - 取消按钮文本
  Future<bool> authenticate({
    String? title,
    String? subtitle,
    String? description,
    String? negativeButtonText,
  }) {
    return FlutterBiometricPlatform.instance.authenticate(
      title: title,
      subtitle: subtitle,
      description: description,
      negativeButtonText: negativeButtonText,
    );
  }
  
  /// 获取已存储的指纹数量
  Future<int> getFingerprintCount() {
    return FlutterBiometricPlatform.instance.getFingerprintCount();
  }
  
  /// 获取所有已存储的指纹
  Future<List<String>> getAllFingerprints() {
    return FlutterBiometricPlatform.instance.getAllFingerprints();
  }
  
  /// 添加新的指纹
  /// 
  /// [fingerprintHash] - 指纹哈希值，如果为null则使用默认值
  Future<bool> addFingerprint({String? fingerprintHash}) {
    return FlutterBiometricPlatform.instance.addFingerprint(
      fingerprintHash: fingerprintHash,
    );
  }
  
  /// 删除指定索引的指纹
  /// 
  /// [index] - 指纹索引
  Future<bool> deleteFingerprint(int index) {
    return FlutterBiometricPlatform.instance.deleteFingerprint(index);
  }
  
  /// 清除所有指纹
  Future<bool> clearAllFingerprints() {
    return FlutterBiometricPlatform.instance.clearAllFingerprints();
  }
  
  /// 验证指纹
  /// 
  /// [fingerprintHash] - 待验证的指纹哈希值
  Future<bool> verifyFingerprint(String fingerprintHash) {
    return FlutterBiometricPlatform.instance.verifyFingerprint(fingerprintHash);
  }
  
  /// 设置测试指纹（清除所有指纹并添加一个测试指纹）
  Future<bool> setupTestFingerprint() {
    return FlutterBiometricPlatform.instance.setupTestFingerprint();
  }
  
  /// 测试指纹验证
  Future<bool> testFingerprintVerification() {
    return FlutterBiometricPlatform.instance.testFingerprintVerification();
  }
  
  /// 显示原生指纹管理界面
  Future<bool> showFingerprintManager() {
    return FlutterBiometricPlatform.instance.showFingerprintManager();
  }
}
