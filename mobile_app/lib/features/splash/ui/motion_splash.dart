import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/core/app_routes.dart';
import 'package:mobile_app/core/design_system.dart';

class ServiceMotionSplash extends StatefulWidget {
  const ServiceMotionSplash({super.key});

  @override
  State<ServiceMotionSplash> createState() => _ServiceMotionSplashState();
}

class _ServiceMotionSplashState extends State<ServiceMotionSplash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Perform auth check while animation plays
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 3500)),
      context.read<AuthProvider>().checkAuthStatus(),
    ]);

    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    
    // Smooth transition
    if (auth.isAuthenticated) {
      if (auth.isAdmin) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
      } else if (auth.isProvider) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.providerHome);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.userHome);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Theme Color & White Mix Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        AppColors.primaryLight.withValues(alpha: 0.3),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 2. Animated Abstract Background Motion (Teal Lines)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ServicePathPainter(
                    progress: _controller.value,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ),
          
          // 3. Center Content: Animated Name & Icons
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFloatingIcons(),
                const SizedBox(height: 80),
                
                // Animated Name: EndlessPath
                FadeInDown(
                  duration: const Duration(milliseconds: 1200),
                  child: Column(
                    children: [
                      Text(
                        "EndlessPath",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          foreground: Paint()
                            ..shader = AppGradients.premium.createShader(
                              const Rect.fromLTWH(0, 0, 300, 50),
                            ),
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeIn(
                        delay: const Duration(milliseconds: 800),
                        child: Text(
                          "SERVICES",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 10,
                            color: AppColors.primary.withValues(alpha: 0.4),
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 4. Subtle Bottom Indicator
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: FadeIn(
                delay: const Duration(seconds: 1),
                child: SizedBox(
                  width: 100,
                  height: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withValues(alpha: 0.2)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcons() {
    return SizedBox(
      height: 140,
      width: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Orbital Rings
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              );
            },
          ),
          
          // Floating Icons
          _AnimatedIcon(
            icon: Icons.home_repair_service_rounded,
            angle: 0,
            delay: 0,
            controller: _controller,
            color: AppColors.primary,
          ),
          _AnimatedIcon(
            icon: Icons.cleaning_services_rounded,
            angle: 120 * math.pi / 180,
            delay: 0.3,
            controller: _controller,
            color: AppColors.accent,
          ),
          _AnimatedIcon(
            icon: Icons.handyman_rounded,
            angle: 240 * math.pi / 180,
            delay: 0.6,
            controller: _controller,
            color: AppColors.primary,
          ),
          
          // Center Pulse
          ElasticIn(
            duration: const Duration(seconds: 2),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedIcon extends StatelessWidget {
  final IconData icon;
  final double angle;
  final double delay;
  final AnimationController controller;
  final Color color;

  const _AnimatedIcon({
    required this.icon,
    required this.angle,
    required this.delay,
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value + delay) % 1.0;
        final orbitRadius = 45.0 + 3.0 * math.sin(t * 4 * math.pi);
        final x = orbitRadius * math.cos(angle + t * 0.5 * math.pi);
        final y = orbitRadius * math.sin(angle + t * 0.5 * math.pi);
        final opacity = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
        
        return Transform.translate(
          offset: Offset(x, y),
          child: Opacity(
            opacity: opacity,
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}

class _ServicePathPainter extends CustomPainter {
  final double progress;
  final Color color;
  _ServicePathPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final center = Offset(size.width / 2, size.height / 2);
    
    for (var i = 0; i < 4; i++) {
      final radius = 80.0 + i * 50.0;
      final wave = 5.0 * math.sin(progress * 2 * math.pi + i);
      canvas.drawCircle(center, radius + wave, paint);
    }
    
    final streakPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.transparent, color.withValues(alpha: 0.1), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.2 + i * 0.3);
      final xOffset = size.width * ((progress + i * 0.3) % 1.0);
      path.moveTo(xOffset - 150, y + 30 * math.sin(progress * 2 * math.pi + i));
      path.quadraticBezierTo(
        xOffset, 
        y - 60 * math.cos(progress * 2 * math.pi + i), 
        xOffset + 150, 
        y + 30 * math.sin(progress * 2 * math.pi + i)
      );
    }
    canvas.drawPath(path, streakPaint);
  }


  @override
  bool shouldRepaint(covariant _ServicePathPainter oldDelegate) => true;
}
