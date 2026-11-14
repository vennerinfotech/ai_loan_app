import 'package:material_ui/material_ui.dart';

/// Central theme colors definition for Finsphere AI.
/// All color codes across Splash Screen and Onboarding Screen are defined here.
/// Modifying this single file will update the entire app theme.
class AppColors {
  AppColors._();

  // ==========================================
  // Brand Core Colors (Royal Indigo & Golden Amber)
  // ==========================================
  /// Primary brand indigo/purple (used for logo box, active indicator, heading highlights)
  static const Color primaryPurple = Color(0xFF524FBA);

  /// Primary accent color: Warm Golden Amber (replaces lime, used for CIBIL card, Saturn ring, accent dots)
  static const Color accentGold = Color(0xFFFBC14E);

  /// Backward-compatibility alias
  static const Color accentLime = accentGold;

  // ==========================================
  // Splash Screen Gradients & Background
  // ==========================================
  static const Color splashGradientTop = Color(0xFF4846C2);
  static const Color splashGradientBottom = Color(0xFF2D2C91);
  static const Color background = Color(0xFF2D2C91);
  static const Color backgroundSecondary = Color(0xFF24227E);

  // Splash Orbits & Cosmic Effects
  static const Color splashHaloGlow = Color(0xFF524FBA);
  static const Color splashOrbitViolet = Color(0xFF6B67C6);
  static const Color splashDottedOrbit = Color(0xFFFBC14E);
  static const Color splashGuideRing = Color(0xFF3835A0);
  static const Color splashSatellite = Colors.white;

  // Splash Pill / Badge ("Your financial partner")
  static const Color pillBackground = Color(0xFF26257C);
  static const Color pillBorder = Color(0xFF42419B);
  static const Color pillDot = Color(0xFFFBC14E);

  // Splash Progress Indicator & Text
  static const Color progressActive = Color(0xFFFBC14E);
  static const Color progressInactive = Color(0xFF2C288A);
  static const Color splashStatusText = Color(0xFF6E719B);

  // ==========================================
  // Onboarding Screen Colors
  // ==========================================
  /// Screen overall background (Light grey/white)
  static const Color lightBackground = Color(0xFFF8F9FE);

  /// Hero Card Top Container Gradient
  static const Color heroCardGradientTop = Color(0xFF4846C2);
  static const Color heroCardGradientBottom = Color(0xFF2D2C91);
  static const Color darkCardBackground = Color(0xFF2D2C91);

  /// Central Globe inside Hero Card
  static const Color globeColor = Color(0xFF4845B6);

  /// Orbits & Concentric Rings inside Hero Card
  static const Color heroConcentricRings = Color(0xFF3835A0);
  static const Color orbitViolet = Color(0xFF6B67C6);

  /// Saturn Planet & Ring
  static const Color saturnPlanetColor = Colors.white;
  static const Color saturnRingColor = Color(0xFFFBC14E);

  /// Feature Pills at bottom of Hero Card ("Instant approval", etc.)
  static const Color featurePillBackground = Color(0xFF272683);
  static const Color featurePillBorder = Color(0xFF3E3D9C);
  static const Color featurePillText = Colors.white;

  /// Floating Card 1: "Loan approved" (White card)
  static const Color loanApprovedCardBackground = Colors.white;
  static const Color checkmarkBox = Color(0xFFFBC14E);
  static const Color checkmarkIcon = Color(0xFF212074);
  static const Color cardTextDark = Color(0xFF1E2127);
  static const Color cardAmountText = Color(0xFF212074);
  static const Color cardSubtitleText = Color(0xFF787E9E);

  /// Floating Card 2: "CIBIL score" (Golden Amber card)
  static const Color cibilCardBackground = Color(0xFFFBC14E);
  static const Color cibilCardText = Color(0xFF212074);
  static const Color cibilProgressTrack = Color(0x33212074);
  static const Color cibilProgressFill = Color(0xFF212074);

  /// Page Indicator
  static const Color indicatorActive = Color(0xFF524FBA);
  static const Color indicatorInactive = Color(0xFFD8DCED);

  /// Onboarding Body Text
  static const Color textDark = Color(0xFF1E2127);
  static const Color textDarkSecondary = Color(0xFF727681);
  static const Color headingHighlight = Color(0xFF524FBA);

  /// Primary Button ("Create free account")
  static const Color primaryButtonBackground = Color(0xFF212074);
  static const Color primaryButtonText = Colors.white;
  static const Color primaryButtonArrowCircle = Color(0xFFFBC14E);
  static const Color primaryButtonArrowIcon = Color(0xFF212074);

  /// Secondary Button ("I already have an account")
  static const Color lightButtonBackground = Color(0xFFF1F6FC);
  static const Color lightButtonBorder = Color(0xFFE2E7F4);
  static const Color secondaryButtonText = Color(0xFF1E2127);

  // General Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B3D6);
  static const Color textMuted = Color(0xFF6E719B);
}
