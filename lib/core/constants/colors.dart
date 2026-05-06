import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF060B14);
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryTeal = Color(0xFF14B8A6);
  static const Color glassBackground = Color(0x0FFFFFFF);
  static const Color glassBorder = Color(0x24FFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
}

class AppGradients {
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x12FFFFFF), Color(0x07FFFFFF)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryPurple, AppColors.primaryTeal],
  );

  static const RadialGradient backgroundGradient = RadialGradient(
    center: Alignment.topRight,
    radius: 1.5,
    colors: [Color(0x337C3AED), Color(0x0014B8A6), AppColors.background],
  );

  static const RadialGradient backgroundGradientLeft = RadialGradient(
    center: Alignment.bottomLeft,
    radius: 1.2,
    colors: [Color(0x2214B8A6), Color(0x00000000), AppColors.background],
  );
}