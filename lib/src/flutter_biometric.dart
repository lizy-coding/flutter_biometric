// 导出生物识别组件
export 'biometric/biometric_service.dart';
export 'biometric/biometric_manager.dart';
export 'ui/fingerprint_management_page.dart';
export 'utils/biometric_utils.dart';

// 重新导出local_auth的类型，便于使用
export 'package:local_auth/local_auth.dart' show BiometricType; 