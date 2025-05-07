import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Flutter侧：支持直接绘制Uint8List图像（如原生返回的JPEG/PNG数据）
class FaceImageOutput extends StatelessWidget {
  final Uint8List imageBytes;
  final double size;

  const FaceImageOutput({
    super.key,
    required this.imageBytes,
    this.size = 240,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image.memory(
              imageBytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
          IgnorePointer(
            child: CustomPaint(
              size: Size(size, size),
              painter: _CircleBorderPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
