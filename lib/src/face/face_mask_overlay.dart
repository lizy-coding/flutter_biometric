import 'package:flutter/material.dart';

/// 人脸识别遮罩层
/// 
/// 提供一个圆形透明区域，周围是半透明遮罩，类似微信的人脸识别界面
class FaceMaskOverlay extends StatelessWidget {
  /// 圆形区域直径
  final double size;
  
  /// 边框颜色
  final Color borderColor;
  
  /// 边框宽度
  final double borderWidth;
  
  /// 遮罩颜色
  final Color maskColor;
  
  /// 提示文本
  final String? hintText;
  
  /// 提示文本样式
  final TextStyle? hintTextStyle;

  const FaceMaskOverlay({
    super.key,
    this.size = 280,
    this.borderColor = Colors.white,
    this.borderWidth = 3,
    this.maskColor = Colors.black54,
    this.hintText,
    this.hintTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 自定义画布绘制圆形遮罩
        CustomPaint(
          painter: _CircleMaskPainter(
            circleSize: size,
            borderColor: borderColor,
            borderWidth: borderWidth,
            maskColor: maskColor,
          ),
          child: Container(),
        ),
        
        // 中心圆形区域
        Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
              ),
            ),
          ),
        ),
        
        // 提示文本
        if (hintText != null)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                hintText!,
                style: hintTextStyle ?? const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 圆形遮罩绘制器
class _CircleMaskPainter extends CustomPainter {
  final double circleSize;
  final Color borderColor;
  final double borderWidth;
  final Color maskColor;

  _CircleMaskPainter({
    required this.circleSize,
    required this.borderColor,
    required this.borderWidth,
    required this.maskColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint maskPaint = Paint()..color = maskColor;
    
    // 绘制整个屏幕的遮罩
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      maskPaint,
    );
    
    // 计算圆心位置
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = circleSize / 2;
    
    // 使用BlendMode.clear擦除圆形区域，使其透明
    final Paint clearPaint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear;
    
    // 绘制透明圆形
    canvas.drawCircle(center, radius, clearPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 