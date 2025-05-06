import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_biometric/flutter_biometric.dart';
import 'package:flutter_biometric/flutter_biometric_platform_interface.dart';
import 'package:flutter_biometric/flutter_biometric_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBiometricPlatform
    with MockPlatformInterfaceMixin
    implements FlutterBiometricPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterBiometricPlatform initialPlatform = FlutterBiometricPlatform.instance;

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
