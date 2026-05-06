import 'package:flutter/material.dart';

class GlassTheme extends ThemeExtension<GlassTheme> {
  final Color glassBackground;
  final Color glassBorder;
  final double blurSigma;
  final double saturation;

  const GlassTheme({
    this.glassBackground = const Color(0x0FFFFFFF),
    this.glassBorder = const Color(0x24FFFFFF),
    this.blurSigma = 20.0,
    this.saturation = 1.8,
  });

  @override
  ThemeExtension<GlassTheme> copyWith({
    Color? glassBackground,
    Color? glassBorder,
    double? blurSigma,
    double? saturation,
  }) {
    return GlassTheme(
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorder: glassBorder ?? this.glassBorder,
      blurSigma: blurSigma ?? this.blurSigma,
      saturation: saturation ?? this.saturation,
    );
  }

  @override
  ThemeExtension<GlassTheme> lerp(ThemeExtension<GlassTheme>? other, double t) {
    if (other is! GlassTheme) return this;
    return GlassTheme(
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      blurSigma: blurSigma + (other.blurSigma - blurSigma) * t,
      saturation: saturation + (other.saturation - saturation) * t,
    );
  }
}