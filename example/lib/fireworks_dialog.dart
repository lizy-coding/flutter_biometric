import 'dart:math';
import 'package:flutter/material.dart';

class FireworksDialog extends StatefulWidget {
  const FireworksDialog({super.key});

  @override
  State<FireworksDialog> createState() => _FireworksDialogState();
}

class _FireworksDialogState extends State<FireworksDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const int particleCount = 30;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.of(context).pop();
        }
      });

    final random = Random();
    for (int i = 0; i < particleCount; i++) {
      final angle = 2 * pi * i / particleCount;
      final speed = 80 + random.nextDouble() * 40;
      final color = Colors.primaries[random.nextInt(Colors.primaries.length)];
      _particles.add(_Particle(
        angle: angle,
        speed: speed,
        color: color,
      ));
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(200, 200),
            painter: _FireworksPainter(
              _particles,
              _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final Color color;

  _Particle({
    required this.angle,
    required this.speed,
    required this.color,
  });
}

class _FireworksPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _FireworksPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final p in particles) {
      final distance = p.speed * progress;
      final dx = cos(p.angle) * distance;
      final dy = sin(p.angle) * distance;
      final paint = Paint()
        ..color = p.color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center + Offset(dx, dy), 6 * (1 - progress) + 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter oldDelegate) =>
      oldDelegate.progress != progress;
}