import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_biometric_platform_interface.dart';

/// An implementation of [FlutterBiometricPlatform] that uses method channels.
class MethodChannelFlutterBiometric extends FlutterBiometricPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_biometric');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
  
  @override
  Future<bool> isBiometricSupported() async {
    return await methodChannel.invokeMethod<bool>('isBiometricSupported') ?? false;
  }
  
  @override
  Future<bool> authenticate({
    String? title,
    String? subtitle,
    String? description,
    String? negativeButtonText,
  }) async {
    try {
      return await methodChannel.invokeMethod<bool>('authenticate', {
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'negativeButtonText': negativeButtonText,
      }) ?? false;
    } on PlatformException catch (e) {
      debugPrint('生物识别认证失败: ${e.message}');
      return false;
    }
  }
  
  @override
  Future<int> getFingerprintCount() async {
    return await methodChannel.invokeMethod<int>('getFingerprintCount') ?? 0;
  }
  
  @override
  Future<List<String>> getAllFingerprints() async {
    final List<dynamic>? result = await methodChannel.invokeMethod<List<dynamic>>('getAllFingerprints');
    return result?.map((e) => e.toString()).toList() ?? [];
  }
  
  @override
  Future<bool> addFingerprint({String? fingerprintHash}) async {
    return await methodChannel.invokeMethod<bool>('addFingerprint', {
      'fingerprintHash': fingerprintHash,
    }) ?? false;
  }
  
  @override
  Future<bool> deleteFingerprint(int index) async {
    return await methodChannel.invokeMethod<bool>('deleteFingerprint', {
      'index': index,
    }) ?? false;
  }
  
  @override
  Future<bool> clearAllFingerprints() async {
    return await methodChannel.invokeMethod<bool>('clearAllFingerprints') ?? false;
  }
  
  @override
  Future<bool> verifyFingerprint(String fingerprintHash) async {
    return await methodChannel.invokeMethod<bool>('verifyFingerprint', {
      'fingerprintHash': fingerprintHash,
    }) ?? false;
  }
  
  @override
  Future<bool> setupTestFingerprint() async {
    return await methodChannel.invokeMethod<bool>('setupTestFingerprint') ?? false;
  }
  
  @override
  Future<bool> testFingerprintVerification() async {
    return await methodChannel.invokeMethod<bool>('testFingerprintVerification') ?? false;
  }
  
  @override
  Future<bool> showFingerprintManager() async {
    return await methodChannel.invokeMethod<bool>('showFingerprintManager') ?? false;
  }
}
