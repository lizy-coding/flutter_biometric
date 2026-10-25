import 'flutter_biometric_platform_interface.dart';
import 'flutter_biometric_result.dart';

export 'flutter_biometric_method_channel.dart';
export 'flutter_biometric_platform_interface.dart';
export 'flutter_biometric_result.dart';
export 'src/biometric_channel_contract.dart';

/// Entry point of the plugin: consumers talk to [FlutterBiometricPlatform]
/// and typed results only, never to the method channel directly.
class FlutterBiometric {
  FlutterBiometric({FlutterBiometricPlatform? platform})
    : _platform = platform ?? FlutterBiometricPlatform.instance;

  final FlutterBiometricPlatform _platform;

  /// Runtime adapter capabilities, complementary to any static platform
  /// matrix: static rules gate the feature entry, this gate decides which
  /// sensors are usable on the actual device.
  Future<BiometricCapabilities> queryCapabilities() =>
      _platform.queryCapabilities();

  Future<BiometricAuthOutcome> authenticate(BiometricAuthRequest request) =>
      _platform.authenticate(request);
}
