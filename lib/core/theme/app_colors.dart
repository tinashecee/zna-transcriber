import 'package:flutter/material.dart';

/// Design tokens from the Stitch organic glassmorphism system.
class AppColors {
  AppColors._();

  // Ambient canvas & scaffolding
  static const Color scaffoldBackground = Color(0xFFF1F5F3);
  static const Color canvasGradientStart = Color(0xFFE5EFE9);
  static const Color canvasGradientEnd = Color(0xFFFAF7F2);

  // Surfaces & glassmorphic cards
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceGlass = Color(0xE6FFFFFF);
  static const Color surfaceGlassSubtle = Color(0x99FFFFFF);
  static const Color surfaceSelectedTile = Color(0xFFEBF3EE);
  static const Color surfaceSearchInput = Color(0xFFF3F5F4);
  static const Color surfaceGlassBorder = Color(0xCCFFFFFF);

  // Dark obsidian blocks
  static const Color primaryDark = Color(0xFF0F141A);
  static const Color primaryDarkCard = Color(0xFF13181F);
  static const Color darkPillBorder = Color(0xFF222B35);

  // Brand accent (mint — bridges legacy green with design system)
  static const Color brandMint = Color(0xFF3F7166);
  static const Color brandDeep = Color(0xFF115343);

  // Interactive accents & badges
  static const Color onlineGreen = Color(0xFF22C55E);
  static const Color badgeOrange = Color(0xFFF59E0B);
  static const Color checkmarkGreen = Color(0xFF34D399);
  static const Color danger = Color(0xFFE53935);
  static const Color warningBg = Color(0xFFFFF3CD);
  static const Color warningText = Color(0xFF856404);

  // Typography hierarchy
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLightPrimary = Color(0xFFF9FAFB);
  static const Color textLightSecondary = Color(0xFF9CA3AF);

  // Borders
  static const Color borderSubtle = Color(0xFFE5E7EB);
}
