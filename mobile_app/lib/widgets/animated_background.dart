import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile_app/core/design_system.dart';

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
      duration: const Duration(seconds: 15),
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
    // Fill deep background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = AppColors.background);

    // Dynamic Blobs - Soft and subtle for light theme
    _drawBlob(
      canvas, 
      size, 
      Offset(
        size.width * 0.2 + math.sin(animationValue * 2 * math.pi) * 40,
        size.height * 0.2 + math.cos(animationValue * 2 * math.pi) * 40,
      ), 
      200, 
      AppColors.primary.withValues(alpha: 0.05)
    );

    _drawBlob(
      canvas, 
      size, 
      Offset(
        size.width * 0.8 + math.cos(animationValue * 2 * math.pi) * 60,
        size.height * 0.7 + math.sin(animationValue * 2 * math.pi) * 60,
      ), 
      250, 
      AppColors.secondary.withValues(alpha: 0.03)
    );
  }

  void _drawBlob(Canvas canvas, Size size, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100); // Higher blur for light theme
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}
