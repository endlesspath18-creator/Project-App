import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPainter(_controller.value),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;
  BackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background color
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFFFFFFF));

    // Blob 1 (Top Left)
    final offset1 = Offset(
      size.width * 0.1 + math.sin(animationValue * 2 * math.pi) * 20,
      size.height * 0.1 + math.cos(animationValue * 2 * math.pi) * 20,
    );

    _drawBlob(canvas, size, offset1, 150, const Color(0xFF2563EB).withValues(alpha: 0.05));

    // Blob 2 (Bottom Right)
    final offset2 = Offset(
      size.width * 0.8 + math.cos(animationValue * 2 * math.pi) * 30,
      size.height * 0.8 + math.sin(animationValue * 2 * math.pi) * 30,
    );
    _drawBlob(canvas, size, offset2, 200, const Color(0xFF7C3AED).withValues(alpha: 0.05));

    // Blob 3 (Middle Right)
    final offset3 = Offset(
      size.width * 0.9 + math.sin(animationValue * 2 * math.pi + 1) * 25,
      size.height * 0.4 + math.cos(animationValue * 2 * math.pi + 1) * 25,
    );
    _drawBlob(canvas, size, offset3, 120, const Color(0xFF2563EB).withValues(alpha: 0.03));
  }

  void _drawBlob(Canvas canvas, Size size, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}
