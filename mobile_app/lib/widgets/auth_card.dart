import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  const AuthCard({
    super.key,
    required this.child,
    this.elevation = 0,
    this.padding = const EdgeInsets.all(24.0),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
