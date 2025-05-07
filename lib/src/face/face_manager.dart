import 'face_service.dart';

/// Manager层：业务流程与状态管理
class FaceManager {
  final FaceService _service = FaceService();
  int? _textureId;

  /// 启动人脸采集，返回纹理ID
  Future<int?> startFaceCapture() async {
    _textureId = await _service.startFaceCapture();
    return _textureId;
  }

  /// 停止人脸采集
  Future<void> stopFaceCapture() async {
    await _service.stopFaceCapture();
    _textureId = null;
  }

  int? get textureId => _textureId;
}
