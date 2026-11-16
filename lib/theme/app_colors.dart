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
  static const Color orbitWhite = Color(0xB3FFFFFF);
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

  /// Central Globe/Circle inside Hero Card (visible light violet/indigo circle)
  static const Color globeColor = Color(0xFF4845B6);

  /// Orbits & Concentric Rings inside Hero Card (luminous cosmic violet lines matching Figma)
  static const Color heroConcentricRings = Color(0xFF6B68D8);
  static const Color orbitViolet = Color(0xFF7E7BE6);

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

  // ==========================================
  // Registration / Create Account & OTP Screen
  // ==========================================
  /// Stepper pill active (Primary Purple #524FBA)
  static const Color stepperActive = Color(0xFF524FBA);
  /// Stepper pill inactive
  static const Color stepperInactive = Color(0xFFDDE3F0);

  /// Back button squircle
  static const Color backButtonBackground = Colors.white;
  static const Color backButtonBorder = Color(0xFFE2E7F4);
  static const Color backButtonIcon = Color(0xFF1E2127);

  /// Step counter text (e.g. "1/3")
  static const Color stepCounterText = Color(0xFF1E2127);

  /// Input fields - Focused vs Unfocused
  static const Color fieldFocusedBackground = Colors.white;
  static const Color fieldFocusedBorder = Color(0xFF524FBA);
  static const Color fieldUnfocusedBackground = Color(0xFFEEF3FC);
  static const Color fieldUnfocusedBorder = Colors.transparent;

  static const Color inputBorder = Color(0xFFE2E7F4);
  static const Color inputBackground = Colors.white;
  static const Color inputHintIcon = Color(0xFF98A6D4);
  static const Color inputText = Color(0xFF1E2127);
  static const Color inputLabel = Color(0xFF727681);

  /// Referral container & Add button
  static const Color referralCardBackground = Color(0xFFEEF2FA);
  static const Color referralCardBorder = Color(0xFFDCE4F5);
  static const Color referralIcon = Color(0xFF524FBA);
  static const Color referralText = Color(0xFF1E2127);
  static const Color referralAddButtonBg = Colors.white;
  static const Color referralAddButtonText = Color(0xFF524FBA);
  static const Color referralAddButtonBorder = Color(0xFFDCE4F5);

  /// Checkbox active fill
  static const Color checkboxActive = Color(0xFF212074);
  /// Terms & link text
  static const Color linkText = Color(0xFF524FBA);

  /// OTP cells
  static const Color otpFilledBackground = Color(0xFF212074);
  static const Color otpFilledText = Colors.white;
  static const Color otpActiveBorder = Color(0xFF524FBA);
  static const Color otpActiveBackground = Colors.white;
  static const Color otpEmptyBackground = Colors.white;
  static const Color otpEmptyBorder = Color(0xFFE2E7F4);

  /// Security notice container
  static const Color securityBoxBackground = Color(0xFFEEF1FD);
  static const Color securityIcon = Color(0xFF6C74A6);
  static const Color securityText = Color(0xFF6C74A6);

  /// Number pad keys
  static const Color numPadKeyBackground = Colors.white;
  static const Color numPadKeyBorder = Color(0xFFE8EEF8);
  static const Color numPadKeyText = Color(0xFF1E2127);
  static const Color numPadActionKeyBackground = Color(0xFFEEF2F8);

  /// Resend timer text
  static const Color resendTimerText = Color(0xFF727681);
  /// Resend link active text
  static const Color resendLinkText = Color(0xFF524FBA);

  // ==========================================
  // MPIN Screens (Create MPIN & Login with MPIN)
  // ==========================================
  /// Create MPIN dark gradient
  static const Color mpinDarkBackgroundTop = Color(0xFF4846C2);
  static const Color mpinDarkBackgroundBottom = Color(0xFF242378);

  /// MPIN row container
  static const Color mpinFieldBackground = Color(0xFF26257C);
  static const Color mpinFieldBorder = Color(0xFF3E3D9C);

  /// MPIN indicator dots
  static const Color mpinDotFilled = Color(0xFFFBC14E);
  static const Color mpinDotEmpty = Color(0x336B68D8);
  static const Color mpinDotEmptyBorder = Color(0xFF6B68D8);

  /// Criteria rule pills
  static const Color mpinRuleActiveBg = Color(0x33FBC14E);
  static const Color mpinRuleInactiveBg = Color(0x22FFFFFF);
  static const Color mpinRuleActiveText = Colors.white;
  static const Color mpinRuleInactiveText = Color(0xFFB0B3D6);

  /// Dark keypad for Create MPIN
  static const Color mpinDarkKeyBackground = Color(0xFF26257C);
  static const Color mpinDarkKeyBorder = Color(0xFF383792);
  static const Color mpinDarkKeyText = Colors.white;
  static const Color mpinDarkActionKeyBackground = Color(0xFF363590);

  /// "Set MPIN" Button (Golden Amber with Navy Text)
  static const Color mpinSetButtonBackground = Color(0xFFFBC14E);
  static const Color mpinSetButtonText = Color(0xFF212074);

  /// Login with MPIN Top Card & Avatar
  static const Color mpinAvatarBackground = Color(0xFFFBC14E);
  static const Color mpinAvatarText = Color(0xFF212074);
  static const Color mpinBiometricBackground = Color(0xFF524FBA);
  static const Color mpinBiometricIcon = Colors.white;

  // ==========================================
  // Dashboard & Bottom Navigation Bar
  // ==========================================
  static const Color bottomNavBackground = Color(0xFF212074);
  static const Color bottomNavSelected = Color(0xFFFBC14E);
  static const Color bottomNavUnselected = Color(0xFF8C90C2);
  static const Color bottomNavCenterButton = Color(0xFFFBC14E);
  static const Color bottomNavCenterIcon = Color(0xFF212074);

  static const Color dashboardCardBorder = Color(0xFFEAEFF8);
  static const Color cibilGoodTagBg = Color(0xFFFBC14E);
  static const Color cibilGoodTagText = Color(0xFF212074);
  static const Color reviewPillBg = Color(0xFFFEEEDB);
  static const Color reviewPillText = Color(0xFFB45309);

  // ==========================================
  // Aadhaar KYC Verification Screens
  // ==========================================
  static const Color kycStepperActivePill = Color(0xFF212074);
  static const Color kycStepperActivePillText = Colors.white;
  static const Color kycStepperActiveBadge = Color(0xFFFBC14E);
  static const Color kycStepperActiveBadgeText = Color(0xFF212074);
  static const Color kycStepperInactivePill = Colors.white;
  static const Color kycStepperInactivePillBorder = Color(0xFFE2E7F4);
  static const Color kycStepperInactivePillText = Color(0xFF727681);
  static const Color kycStepperInactiveBadge = Color(0xFFEEF1FD);
  static const Color kycStepperInactiveBadgeText = Color(0xFF524FBA);
  static const Color kycStepperLine = Color(0xFFDDE3F0);

  static const Color kycUploadCardBg = Colors.white;
  static const Color kycUploadCardBorder = Color(0xFFE2E7F4);
  static const Color kycUploadIconBg = Color(0xFFEEF1FD);
  static const Color kycUploadIcon = Color(0xFF524FBA);
  static const Color kycSuccessGreen = Color(0xFF22C55E);
  static const Color kycSuccessGreenBg = Color(0xFFDCFCE7);

  static const Color kycNotLinkedCircleBg = Color(0xFFFEEEDB);
  static const Color kycNotLinkedCircleBorder = Color(0xFFFBD38D);
  static const Color kycNotLinkedIcon = Color(0xFFC05621);

  static const Color kycDetailsCardBg = Colors.white;
  static const Color kycDetailsCardBorder = Color(0xFFEAEFF8);
  static const Color kycDetailsItemIconBg = Color(0xFFEEF1FD);
  static const Color kycDetailsItemIcon = Color(0xFF524FBA);

  // ==========================================
  // PAN KYC Verification Screens
  // ==========================================
  static const Color panCardGold = Color(0xFFFBBF46);
  static const Color panErrorCircleBg = Color(0xFFFFF0ED);
  static const Color panErrorCircleBorder = Color(0xFFFED7AA);
  static const Color panErrorIcon = Color(0xFFB91C1C);
  static const Color panCaptureBg = Color(0xFF333099);
  static const Color panFrameDashedBorder = Color(0xFFFBC14E);
}
