// 导出生物识别组件
export 'biometric/biometric_service.dart';
export 'biometric/biometric_manager.dart';
export 'ui/fingerprint_management_page.dart';
export 'utils/biometric_utils.dart';

// 导出人脸识别组件
export 'face/face_service.dart';
export 'face/face_manager.dart';
export 'face/face_preview_manager.dart';
export 'face/face_image_output.dart';
export 'face/face_mask_overlay.dart';
export 'face/face_preview_page.dart';

// 重新导出local_auth的类型，便于使用
export 'package:local_auth/local_auth.dart' show BiometricType;
