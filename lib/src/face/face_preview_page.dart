import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'face_mask_overlay.dart';
import 'face_preview_manager.dart';

/// 人脸预览页面
/// 包含相机预览、遮罩、验证按钮等，支持画质选择
class FacePreviewPage extends StatefulWidget {
  /// 成功回调
  final Function(bool result)? onResult;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 提示文本
  final String hintText;

  /// 画质参数，影响相机分辨率和渲染质量
  final FacePreviewQuality quality;

  const FacePreviewPage({
    super.key,
    this.onResult,
    this.onCancel,
    this.hintText = '请将脸部放在框内',
    this.quality = FacePreviewQuality.medium,
  });

  @override
  State<FacePreviewPage> createState() => _FacePreviewPageState();
}

class _FacePreviewPageState extends State<FacePreviewPage> {
  final FacePreviewManager _previewManager = FacePreviewManager();
  int? _textureId; // 当前相机纹理ID
  bool _isLoading = true; // 是否正在加载预览
  bool _isProcessing = false; // 是否正在处理验证

  @override
  void initState() {
    super.initState();
    // 启动相机预览
    _startPreview();
  }

  @override
  void dispose() {
    // 页面销毁时释放相机资源
    _stopPreview();
    super.dispose();
  }

  /// 启动相机预览，获取纹理ID
  Future<void> _startPreview() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final textureId = await _previewManager.startFacePreview(
        quality: widget.quality,
      );
      setState(() {
        _textureId = textureId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('无法启动相机预览: $e');
    }
  }

  /// 停止相机预览，释放资源
  Future<void> _stopPreview() async {
    await _previewManager.stopFacePreview();
  }

  /// 模拟人脸验证流程（可扩展为实际检测）
  Future<void> _verifyFace() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 这里可以添加实际的人脸验证逻辑
      // 目前简单返回成功
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        widget.onResult?.call(true);
      }
    } catch (e) {
      if (mounted) {
        _showError('人脸验证失败: $e');
        widget.onResult?.call(false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// 显示错误信息（SnackBar）
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// 画质枚举到 FilterQuality 的映射，便于 Texture 渲染
  FilterQuality _filterQualityFor(FacePreviewQuality quality) {
    switch (quality) {
      case FacePreviewQuality.high:
        return FilterQuality.high;
      case FacePreviewQuality.medium:
        return FilterQuality.medium;
      case FacePreviewQuality.low:
      default:
        return FilterQuality.low;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          },
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 相机预览
          if (_textureId != null)
            Texture(
              textureId: _textureId!,
              filterQuality: _filterQualityFor(widget.quality),
            ),

          // 加载指示器
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // 人脸识别遮罩
          FaceMaskOverlay(hintText: widget.hintText),

          // 底部按钮
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _isLoading || _isProcessing ? null : _verifyFace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(_isProcessing ? '验证中...' : '开始验证'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
