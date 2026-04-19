import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;
import '../../providers/auth_provider.dart';
import '../../core/app_routes.dart';
import '../../core/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  String _statusMessage = 'Initializing essentials…';
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Fix: Await the first frame before starting logic to prevent 'setState during build' error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startStartupSequence();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _startStartupSequence() async {
    final minSplashFuture = Future.delayed(const Duration(milliseconds: 2500));
    
    bool isAuthenticated = false;
    AuthProvider? authProvider;

    try {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Auth check with timeout
      isAuthenticated = await authProvider.checkAuthStatus().timeout(
        const Duration(seconds: 4),
        onTimeout: () {
          debugPrint('[Splash] Auth check timed out.');
          return false; 
        },
      );
    } catch (e) {
      debugPrint('[Splash] Error: $e');
      isAuthenticated = false;
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none) || connectivity.isEmpty) {
      _setStatus('Checking connection…');
      await Future.delayed(const Duration(milliseconds: 500));
    }

    await minSplashFuture;

    if (!mounted) return;

    if (isAuthenticated && authProvider != null) {
      Navigator.of(context).pushReplacementNamed(
        authProvider.isProvider ? AppRoutes.providerHome : AppRoutes.userHome,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  void _setStatus(String message) {
    if (mounted) setState(() => _statusMessage = message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ─── Phase 1: Ambient Background Shapes ──────────────────────────────
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Stack(
                children: [
                  _PositionedShape(
                    top: -100 + (20 * math.sin(_bgController.value * 2 * math.pi)),
                    right: -50,
                    size: 300,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.03),
                  ),
                  _PositionedShape(
                    bottom: -150 + (30 * math.cos(_bgController.value * 2 * math.pi)),
                    left: -100,
                    size: 400,
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.02),
                  ),
                ],
              );
            },
          ),

          // ─── Main Content ──────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium Logo Scale & Fade
                FadeInDown(
                  duration: const Duration(milliseconds: 1200),
                  child: Pulse(
                    infinite: true,
                    duration: const Duration(seconds: 4),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: 200,
                      height: 150,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // App Name with stagger
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    AppConstants.appName.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                          color: const Color(0xFF1E293B),
                        ),
                  ),
                ),

                const SizedBox(height: 12),

                // Premium Tagline
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 800),
                  child: Text(
                    '“Trusted Services at Your Doorstep”',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 1.2,
                      fontStyle: FontStyle.italic,
                      color: Colors.black.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Bottom Loading Section ────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: FadeIn(
                delay: const Duration(milliseconds: 1500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 140,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1,
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionedShape extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;
  final Color color;

  const _PositionedShape({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
