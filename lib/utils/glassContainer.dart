import 'package:flutter/material.dart';
import 'dart:ui';

class ClassContainer extends StatelessWidget {
  const ClassContainer({
    super.key,
    required this.child,
    required this.width,
    required this.height,
  });
  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 20;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(borderRadius),
        topRight: Radius.circular(borderRadius),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            // **تصحيح: استخدام withOpacity بدلاً من withValues غير الموجودة**
            color: Colors.white.withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(borderRadius),
              topRight: Radius.circular(borderRadius),
            ),
            border: Border.all(
              // **تصحيح: استخدام withOpacity بدلاً من withValues غير الموجودة**
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
