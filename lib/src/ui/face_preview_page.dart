import 'package:flutter/material.dart';
import '../face/face_preview_manager.dart';
import 'face_mask_overlay.dart';

/// 人脸预览页面 - 显示相机预览和圆形遮罩
class FacePreviewPage extends StatefulWidget {
  final Color backgroundColor;
  final double aspectRatio;
  final Function(bool)? onVerificationComplete;

  const FacePreviewPage({
    super.key,
    this.backgroundColor = Colors.black,
    this.aspectRatio = 3 / 4,
    this.onVerificationComplete,
  });

  @override
  State<FacePreviewPage> createState() => _FacePreviewPageState();
}

class _FacePreviewPageState extends State<FacePreviewPage> {
  int? _textureId;
  bool _isLoading = true;
  String? _errorMessage;
  
  final FacePreviewManager _manager = FacePreviewManager();

  @override
  void initState() {
    super.initState();
    _initPreview();
  }

  Future<void> _initPreview() async {
    try {
      final id = await _manager.startFacePreview();
      setState(() {
        _textureId = id;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '无法启动相机预览: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _manager.stopFacePreview();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('人脸验证', style: TextStyle(color: Colors.white)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _initPreview();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 相机预览
            if (_textureId != null)
              Texture(textureId: _textureId!),
              
            // 遮罩层
            const FaceMaskOverlay(),
            
            // 底部按钮
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: _onVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('验证'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onVerify() {
    // 实际应用中，这里可以调用原生人脸识别API
    // 示例中，我们模拟验证成功
    if (widget.onVerificationComplete != null) {
      widget.onVerificationComplete!(true);
    }
    
    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('人脸验证成功')),
    );
    
    // 返回上一页
    Navigator.of(context).pop(true);
  }
}