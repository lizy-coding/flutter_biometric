import 'package:flutter/material.dart';

/// 人脸验证遮罩 - 圆形透明区域
class FaceMaskOverlay extends StatelessWidget {
  final Color maskColor;
  final double circleRadius;
  final double strokeWidth;
  final Color strokeColor;

  const FaceMaskOverlay({
    super.key,
    this.maskColor = Colors.black,
    this.circleRadius = 0.38, // 占宽度的比例
    this.strokeWidth = 4.0,
    this.strokeColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FaceMaskPainter(
        maskColor: maskColor,
        circleRadius: circleRadius,
        strokeWidth: strokeWidth,
        strokeColor: strokeColor,
      ),
      size: Size.infinite,
    );
  }
}

/// 人脸遮罩绘制器
class _FaceMaskPainter extends CustomPainter {
  final Color maskColor;
  final double circleRadius;
  final double strokeWidth;
  final Color strokeColor;

  _FaceMaskPainter({
    required this.maskColor,
    required this.circleRadius,
    required this.strokeWidth,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = maskColor.withOpacity(0.7);
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2);
    final radius = width * circleRadius;

    // 画全屏遮罩
    canvas.drawRect(Offset.zero & size, paint);

    // 用clear模式抠出圆形区域
    paint.blendMode = BlendMode.clear;
    canvas.drawCircle(center, radius, paint);

    // 画圆边框
    paint
      ..blendMode = BlendMode.srcOver
      ..color = strokeColor.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, paint);

    // 可选：绘制提示文字
    const String text = "请将脸部放入圆圈内";
    final TextSpan span = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + radius + 30));
  }

  @override
  bool shouldRepaint(covariant _FaceMaskPainter oldDelegate) =>
      maskColor != oldDelegate.maskColor ||
      circleRadius != oldDelegate.circleRadius ||
      strokeWidth != oldDelegate.strokeWidth ||
      strokeColor != oldDelegate.strokeColor;
}
