import 'package:flutter/material.dart';

class AppTokens {
  AppTokens._();

  // Radii
  static const double radiusOuterFrame = 32.0;
  static const double radiusBubble = 24.0;
  static const double radiusCard = 20.0;
  static const double radiusTile = 16.0;
  static const double radiusPill = 28.0;
  static const double radiusInput = 22.0;

  static List<BoxShadow> frameShadow = [
    BoxShadow(
      color: const Color(0xFF1E293B).withValues(alpha: 0.06),
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> medallionShadow = [
    BoxShadow(
      color: const Color(0xFF1E293B).withValues(alpha: 0.08),
      blurRadius: 18,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> bubbleShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF1E293B).withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
