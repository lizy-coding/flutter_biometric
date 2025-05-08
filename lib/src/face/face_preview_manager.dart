import 'package:flutter/services.dart';

/// 画质枚举，控制相机预览分辨率
/// low: 640x480, medium: 1280x960, high: 1920x1080
enum FacePreviewQuality { low, medium, high }

/// 枚举转字符串，便于与原生通信
String _qualityToString(FacePreviewQuality quality) {
  switch (quality) {
    case FacePreviewQuality.high:
      return 'high';
    case FacePreviewQuality.medium:
      return 'medium';
    case FacePreviewQuality.low:
    default:
      return 'low';
  }
}

/// 人脸预览管理器
/// 负责与原生通信，启动/停止相机预览，获取纹理ID
class FacePreviewManager {
  static const MethodChannel _channel = MethodChannel('face_channel');
  int? _textureId; // 当前预览纹理ID

  /// 启动人脸预览，返回纹理ID
  /// [quality] 画质参数，默认 FacePreviewQuality.low
  /// 返回null表示启动失败
  Future<int?> startFacePreview({FacePreviewQuality quality = FacePreviewQuality.low}) async {
    try {
      final int? id = await _channel.invokeMethod<int>('startFacePreview', {
        'quality': _qualityToString(quality),
      });
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
      // 忽略错误，保证资源释放
    } finally {
      _textureId = null;
    }
  }

  /// 获取当前纹理ID
  int? get textureId => _textureId;
}
