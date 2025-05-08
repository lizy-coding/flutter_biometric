import 'package:flutter/services.dart';

/// 人脸预览管理器 - 负责与原生通信，获取纹理ID
class FacePreviewManager {
  static const MethodChannel _channel = MethodChannel('face_channel');
  int? _textureId;

  /// 启动人脸预览，返回纹理ID
  /// 如果返回null，表示启动失败
  Future<int?> startFacePreview() async {
    try {
      final int? id = await _channel.invokeMethod<int>('startFacePreview');
      
      // Android原生端返回-1表示错误
      if (id == null || id < 0) {
        return null;
      }
      
      _textureId = id;
      return _textureId;
    } catch (e) {
      // 调用失败时返回null
      return null;
    }
  }

  /// 停止人脸预览，释放资源
  Future<void> stopFacePreview() async {
    try {
      await _channel.invokeMethod('stopFacePreview');
    } catch (e) {
      // 忽略错误
    } finally {
      _textureId = null;
    }
  }

  /// 获取当前纹理ID
  int? get textureId => _textureId;
}