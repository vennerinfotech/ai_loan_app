import 'package:material_ui/material_ui.dart';

/// Central theme colors definition for Finsphere AI.
/// All color codes across the entire application are defined here.
/// Derived strictly from the official Design Tokens:
/// - Navy: #252484
/// - Gradient top / Indigo: #5856D1
/// - Amber: #FFC857
/// - Text: #212529
/// - Muted: #5B6075
/// - Line: #E1E6F2
/// - Canvas: #F3F6FC
/// - Indigo tint: #ECEBFB
/// - Input fill: #E8F0FE
class AppColors {
  AppColors._();

  // ==========================================
  // Canonical Design Tokens (from Figma / Design System)
  // ==========================================
  /// Deep Navy: #252484 (Used for primary CTA buttons, dark card gradient bottom, hero card base)
  static const Color navy = Color(0xFF252484);

  /// Primary Indigo: #5856D1 (Used for brand primary, active states, icons)
  static const Color indigo = Color(0xFF5856D1);

  /// Gradient Top: #5856D1
  static const Color gradientTop = Color(0xFF5856D1);

  /// Gradient Bottom: #252484
  static const Color gradientBottom = navy;

  /// Amber: #FFC857 (Accent warm gold for ratings, badges, CIBIL highlight, warning dots)
  static const Color amber = Color(0xFFFFC857);

  /// Text: #212529 (Primary dark typography)
  static const Color text = Color(0xFF212529);

  /// Muted Text: #5B6075 (Subtitles, captions, inactive labels)
  static const Color muted = Color(0xFF5B6075);

  /// Line / Border: #E1E6F2 (Card borders, dividers, outlines)
  static const Color line = Color(0xFFE1E6F2);

  /// Canvas / Background: #F3F6FC (Screen scaffold background)
  static const Color canvas = Color(0xFFF3F6FC);

  /// Indigo Tint: #ECEBFB (Very soft indigo tint for icon circles, pills, chips)
  static const Color indigoTint = Color(0xFFECEBFB);

  /// Input Fill: #E8F0FE (Light soft input fill for text fields, inactive chips)
  static const Color inputFill = Color(0xFFE8F0FE);

  // ==========================================
  // Standard Gradient Tokens (Dashboard Card Gradient: #3835A8 -> #242278)
  // ==========================================
  /// Rich Hero Card Gradients (Deep Royal Indigo #3835A8 & Midnight Navy #242278)
  static const Color cardGradientStart = Color(0xFF3835A8);
  static const Color cardGradientEnd = Color(0xFF242278);
  static const Color cardOrbitLine = Color(0xFF8B88EF);

  /// Golden Card Orbit Lines (Original visible amber contrast on gold cards)
  static const Color goldenOrbitInner = Color(0xFFE2A428);
  static const Color goldenOrbitMiddle = Color(0xFFD69415);
  static const Color goldenOrbitDashed = Color(0xFFC78510);

  /// Standard Dashboard CIBIL card gradient: #3835A8 -> #242278
  static const LinearGradient dashboardCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardGradientStart, cardGradientEnd],
  );

  /// Consistent card gradient alias used across all cards
  static const LinearGradient cardGradient = dashboardCardGradient;
  static const LinearGradient profileCardGradient = dashboardCardGradient;

  /// Primary 2-color brand gradient across cards
  static const LinearGradient primaryGradient = dashboardCardGradient;
  static const LinearGradient primaryGradientDiagonal = dashboardCardGradient;

  // ==========================================
  // Brand Core Aliases (Mapped to Canonical Tokens)
  // ==========================================
  static const Color primaryPurple = indigo;
  static const Color primaryButtonBackground = navy;
  static const Color accentGold = amber;
  static const Color accentLime = amber;
  static const Color lightBackground = canvas;
  static const Color darkCardBackground = navy;
  static const Color background = navy;
  static const Color backgroundSecondary = navy;

  // Typography
  static const Color textDark = text;
  static const Color textDarkSecondary = muted;
  static const Color textMuted = muted;
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = muted;
  /// Light grey secondary text color for dark cards / secondary subtitles
  static const Color textSecondary2 = Color(0xFFBAC2D6);
  static const Color secondaryTextColor2 = textSecondary2;
  static const Color headingHighlight = indigo;

  // Borders & Cards
  static const Color border = line;
  static const Color dashboardCardBorder = line;
  static const Color backButtonBorder = line;
  static const Color inputBorder = line;
  static const Color lightButtonBorder = line;

  // Splash & Hero Gradients (Original Midnight/Cosmic Theme)
  static const Color splashGradientTop = Color(0xFF4846C2);
  static const Color splashGradientBottom = Color(0xFF2D2C91);
  static const Color heroCardGradientTop = Color(0xFF4846C2);
  static const Color heroCardGradientBottom = Color(0xFF2D2C91);
  static const Color splashHaloGlow = Color(0xFF524FBA);
  static const Color splashOrbitViolet = Color(0xFF6B67C6);
  static const Color splashDottedOrbit = amber;
  static const Color splashGuideRing = Color(0xFF3835A0);
  static const Color orbitWhite = Color(0xB3FFFFFF);
  static const Color splashSatellite = Colors.white;
  static const Color pillBackground = Color(0xFF26257C);
  static const Color pillBorder = Color(0xFF42419B);
  static const Color pillDot = amber;
  static const Color progressActive = amber;
  static const Color progressInactive = Color(0xFF2C288A);
  static const Color splashStatusText = Color(0xFF6E719B);

  /// Splash screen full background gradient
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [splashGradientTop, splashGradientBottom],
  );

  // Hero Card Elements
  static const Color globeColor = indigo;
  static const Color heroConcentricRings = indigo;
  static const Color orbitViolet = indigo;
  static const Color saturnPlanetColor = Colors.white;
  static const Color saturnRingColor = amber;
  static const Color featurePillBackground = navy;
  static const Color featurePillBorder = indigo;
  static const Color featurePillText = Colors.white;

  // Floating Cards
  static const Color loanApprovedCardBackground = Colors.white;
  static const Color checkmarkBox = amber;
  static const Color checkmarkIcon = navy;
  static const Color cardTextDark = text;
  static const Color cardAmountText = navy;
  static const Color cardSubtitleText = muted;

  static const Color cibilCardBackground = amber;
  static const Color cibilCardText = navy;
  static const Color cibilProgressTrack = Color(0x33252484);
  static const Color cibilProgressFill = navy;

  // Page Indicator
  static const Color indicatorActive = indigo;
  static const Color indicatorInactive = line;

  // Buttons
  static const Color primaryButtonText = Colors.white;
  static const Color primaryButtonArrowCircle = amber;
  static const Color primaryButtonArrowIcon = navy;
  static const Color lightButtonBackground = inputFill;
  static const Color secondaryButtonText = text;

  // Stepper & Inputs
  static const Color stepperActive = indigo;
  static const Color stepperInactive = line;
  static const Color backButtonBackground = Colors.white;
  static const Color backButtonIcon = text;
  static const Color stepCounterText = text;

  static const Color fieldFocusedBackground = Colors.white;
  static const Color fieldFocusedBorder = indigo;
  static const Color fieldUnfocusedBackground = inputFill;
  static const Color fieldUnfocusedBorder = Colors.transparent;

  static const Color inputBackground = Colors.white;
  static const Color inputHintIcon = muted;
  static const Color inputText = text;
  static const Color inputLabel = muted;

  // Referral
  static const Color referralCardBackground = indigoTint;
  static const Color referralCardBorder = line;
  static const Color referralIcon = indigo;
  static const Color referralText = text;
  static const Color referralAddButtonBg = Colors.white;
  static const Color referralAddButtonText = indigo;
  static const Color referralAddButtonBorder = line;

  // Checkbox & Links
  static const Color checkboxActive = navy;
  static const Color linkText = indigo;

  // OTP
  static const Color otpFilledBackground = navy;
  static const Color otpFilledText = Colors.white;
  static const Color otpActiveBorder = indigo;
  static const Color otpActiveBackground = Colors.white;
  static const Color otpEmptyBackground = Colors.white;
  static const Color otpEmptyBorder = line;

  // Security box
  static const Color securityBoxBackground = indigoTint;
  static const Color securityIcon = muted;
  static const Color securityText = muted;

  // Number Pad
  static const Color numPadKeyBackground = Colors.white;
  static const Color numPadKeyBorder = line;
  static const Color numPadKeyText = text;
  static const Color numPadActionKeyBackground = inputFill;
  static const Color resendTimerText = muted;
  static const Color resendLinkText = indigo;

  // MPIN Screens
  static const Color mpinDarkBackgroundTop = gradientTop;
  static const Color mpinDarkBackgroundBottom = gradientBottom;
  static const Color mpinCardSubtitle = textSecondary2;
  static const Color mpinFieldBackground = navy;
  static const Color mpinFieldBorder = indigo;
  static const Color mpinDotFilled = amber;
  static const Color mpinDotEmpty = Color(0x335856D1);
  static const Color mpinDotEmptyBorder = indigo;
  static const Color mpinRuleActiveBg = Color(0x33FFC857);
  static const Color mpinRuleInactiveBg = Color(0x22FFFFFF);
  static const Color mpinRuleActiveText = Colors.white;
  static const Color mpinRuleInactiveText = indigoTint;
  static const Color mpinDarkKeyBackground = navy;
  static const Color mpinDarkKeyBorder = indigo;
  static const Color mpinDarkKeyText = Colors.white;
  static const Color mpinDarkActionKeyBackground = navy;
  static const Color mpinSetButtonBackground = amber;
  static const Color mpinSetButtonText = navy;
  static const Color mpinAvatarBackground = amber;
  static const Color mpinAvatarText = navy;
  static const Color mpinBiometricBackground = indigo;
  static const Color mpinBiometricIcon = Colors.white;

  // Dashboard & Bottom Nav
  static const Color bottomNavBackground = navy;
  static const Color bottomNavSelected = amber;
  static const Color bottomNavUnselected = Color(0xFF8C90C2);
  static const Color bottomNavCenterButton = amber;
  static const Color bottomNavCenterIcon = navy;
  static const Color cibilGoodTagBg = amber;
  static const Color cibilGoodTagText = navy;
  static const Color reviewPillBg = Color(0xFFFEEEDB);
  static const Color reviewPillText = Color(0xFFB45309);

  // KYC
  static const Color kycStepperActivePill = navy;
  static const Color kycStepperActivePillText = Colors.white;
  static const Color kycStepperActiveBadge = amber;
  static const Color kycStepperActiveBadgeText = navy;
  static const Color kycStepperInactivePill = Colors.white;
  static const Color kycStepperInactivePillBorder = line;
  static const Color kycStepperInactivePillText = muted;
  static const Color kycStepperInactiveBadge = indigoTint;
  static const Color kycStepperInactiveBadgeText = indigo;
  static const Color kycStepperLine = line;

  static const Color kycUploadCardBg = Colors.white;
  static const Color kycUploadCardBorder = line;
  static const Color kycUploadIconBg = indigoTint;
  static const Color kycUploadIcon = indigo;
  static const Color kycSuccessGreen = Color(0xFF22C55E);
  static const Color kycSuccessGreenBg = Color(0xFFDCFCE7);

  static const Color kycNotLinkedCircleBg = Color(0xFFFFF2E6);
  static const Color kycNotLinkedCircleBorder = Color(0xFFFED7AA);
  static const Color kycNotLinkedIcon = Color(0xFFC2410C);

  static const Color kycDetailsCardBg = Colors.white;
  static const Color kycDetailsCardBorder = line;
  static const Color kycDetailsItemIconBg = indigoTint;
  static const Color kycDetailsItemIcon = indigo;

  // ==========================================
  // Semantic State Colors
  // ==========================================
  static const Color successGreen = Color(0xFF22C55E);
  static const Color successGreenBg = Color(0xFFDCFCE7);
  static const Color warningAmber = Color(0xFFD97706);
  static const Color warningAmberBg = Color(0xFFFEF3C7);
  static const Color errorRed = Color(0xFFDC2626);
  static const Color errorRedBg = Color(0xFFFFF1EE);

  // PAN
  static const Color panCardGold = amber;
  static const Color panErrorCircleBg = errorRedBg;
  static const Color panErrorCircleBorder = Color(0xFFFED7D2);
  static const Color panErrorIcon = errorRed;
  static const Color panCaptureBg = navy;
  static const Color panFrameDashedBorder = amber;
}
