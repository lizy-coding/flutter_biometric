import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_biometric/src/face/face_manager.dart';
import 'face_circle_painter.dart';

class FaceCapturePage extends StatefulWidget {
  const FaceCapturePage({super.key});

  @override
  State<FaceCapturePage> createState() => _FaceCapturePageState();
}

class _FaceCapturePageState extends State<FaceCapturePage> {
  int? _textureId;
  final FaceManager _manager = FaceManager();

  @override
  void initState() {
    super.initState();
    _initFaceCapture();
  }

  Future<void> _initFaceCapture() async {
    try {
      final id = await _manager.startFaceCapture();
      setState(() => _textureId = id);
    } on PlatformException catch (e) {
      // 处理权限或硬件异常
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('启动人脸采集失败: ${e.message}')),
      );
    }
  }

  @override
  void dispose() {
    _manager.stopFaceCapture();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('人脸采集')),
      body: Center(
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_textureId != null)
                Texture(textureId: _textureId!),
              IgnorePointer(
                child: CustomPaint(
                  size: const Size(240, 320),
                  painter: FaceCirclePainter(),
                ),
              ),
              // 可加采集按钮、提示等
            ],
          ),
        ),
      ),
    );
  }
}
