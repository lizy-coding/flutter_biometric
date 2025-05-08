import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_biometric/flutter_biometric.dart' show FaceImageOutput;

class FaceImageCapturePage extends StatefulWidget {
  const FaceImageCapturePage({super.key});

  @override
  State<FaceImageCapturePage> createState() => _FaceImageCapturePageState();
}

class _FaceImageCapturePageState extends State<FaceImageCapturePage> {
  Uint8List? _imageBytes;
  bool _loading = false;

  Future<void> _captureFace() async {
    setState(() => _loading = true);
    try {
      final bytes = await const MethodChannel(
        'face_channel',
      ).invokeMethod<Uint8List>('captureFaceImage');
      if (bytes != null) {
        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('采集失败: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('人脸采集')),
      body: Center(
        child:
            _imageBytes == null
                ? _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('采集人脸'),
                      onPressed: _captureFace,
                    )
                : FaceImageOutput(imageBytes: _imageBytes!),
      ),
      floatingActionButton:
          _imageBytes != null
              ? FloatingActionButton(
                child: const Icon(Icons.refresh),
                onPressed: () => setState(() => _imageBytes = null),
              )
              : null,
    );
  }
}
