import 'dart:typed_data';
import 'dart:ui' show ImageByteFormat;
import 'package:flutter/material.dart';
import 'package:flutter_biometric/src/face/face_image_output.dart';
import 'dart:async';
import 'package:flutter/services.dart';

/// 示例页面：演示如何用Flutter绘制原生采集到的人脸图像
class FaceImageDemoPage extends StatefulWidget {
  const FaceImageDemoPage({super.key});

  @override
  State<FaceImageDemoPage> createState() => _FaceImageDemoPageState();
}

class _FaceImageDemoPageState extends State<FaceImageDemoPage> {
  Uint8List? _imageBytes;

  // 模拟原生返回的图像数据（实际应通过PlatformChannel获取）
  Future<void> _loadDemoImage() async {
    // 这里用网络图片做演示，实际应替换为原生采集到的Uint8List
    final networkImage = NetworkImage('https://avatars.githubusercontent.com/u/14101776?v=4');
    final completer = Completer<ImageInfo>();
    final stream = networkImage.resolve(const ImageConfiguration());
    final listener = ImageStreamListener((info, _) => completer.complete(info));
    stream.addListener(listener);
    final imageInfo = await completer.future;
    final byteData = await imageInfo.image.toByteData(format: ImageByteFormat.png);
    setState(() {
      _imageBytes = byteData!.buffer.asUint8List();
    });
    stream.removeListener(listener);
  }

  @override
  void initState() {
    super.initState();
    _loadDemoImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('人脸图像输出演示')),
      body: Center(
        child: _imageBytes == null
            ? const CircularProgressIndicator()
            : FaceImageOutput(imageBytes: _imageBytes!),
      ),
    );
  }
}
