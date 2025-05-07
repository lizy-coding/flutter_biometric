import 'package:flutter/services.dart';

/// Service层：与原生Android通信，管理人脸采集与纹理ID
class FaceService {
  static const MethodChannel _channel = MethodChannel('face_channel');

  /// 启动人脸采集，返回TextureId
  Future<int?> startFaceCapture() async {
    return await _channel.invokeMethod<int>('startFaceCapture');
  }

  /// 停止人脸采集
  Future<void> stopFaceCapture() async {
    await _channel.invokeMethod('stopFaceCapture');
  }
}
