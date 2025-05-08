import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_biometric/flutter_biometric.dart';
import 'package:flutter_biometric/flutter_biometric_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBiometricPlatform
    with MockPlatformInterfaceMixin
    implements FlutterBiometricPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> addFingerprint({String? fingerprintHash}) {
    // TODO: implement addFingerprint
    throw UnimplementedError();
  }

  @override
  Future<bool> authenticate({
    String? title,
    String? subtitle,
    String? description,
    String? negativeButtonText,
  }) {
    // TODO: implement authenticate
    throw UnimplementedError();
  }

  @override
  Future<bool> clearAllFingerprints() {
    // TODO: implement clearAllFingerprints
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteFingerprint(int index) {
    // TODO: implement deleteFingerprint
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getAllFingerprints() {
    // TODO: implement getAllFingerprints
    throw UnimplementedError();
  }

  @override
  Future<int> getFingerprintCount() {
    // TODO: implement getFingerprintCount
    throw UnimplementedError();
  }

  @override
  Future<bool> isBiometricSupported() {
    // TODO: implement isBiometricSupported
    throw UnimplementedError();
  }

  @override
  Future<bool> setupTestFingerprint() {
    // TODO: implement setupTestFingerprint
    throw UnimplementedError();
  }

  @override
  Future<bool> showFingerprintManager() {
    // TODO: implement showFingerprintManager
    throw UnimplementedError();
  }

  @override
  Future<bool> testFingerprintVerification() {
    // TODO: implement testFingerprintVerification
    throw UnimplementedError();
  }

  @override
  Future<bool> verifyFingerprint(String fingerprintHash) {
    // TODO: implement verifyFingerprint
    throw UnimplementedError();
  }
}

void main() {
  final FlutterBiometricPlatform initialPlatform =
      FlutterBiometricPlatform.instance;

  test('$MethodChannelFlutterBiometric is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterBiometric>());
  });

  test('getPlatformVersion', () async {
    FlutterBiometric flutterBiometricPlugin = FlutterBiometric();
    MockFlutterBiometricPlatform fakePlatform = MockFlutterBiometricPlatform();
    FlutterBiometricPlatform.instance = fakePlatform;

    expect(await flutterBiometricPlugin.getPlatformVersion(), '42');
  });
}
