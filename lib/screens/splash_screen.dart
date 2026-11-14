import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../controller/splash_controller.dart';
import '../theme/theme.dart';

/// Clean, responsive, and stateless Splash Screen UI for Finsphere.AI.
/// Uses SplashController (GetX) for automatic navigation after 5 seconds.
/// All colors are sourced directly from AppColors for centralized theming.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize SplashController which auto-navigates after 5 seconds
    final controller = Get.put(SplashController());

    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    // Responsive sizing tokens
    final logoSize = (screenWidth * 0.22).clamp(72.0, 88.0);
    final titleFontSize = (screenWidth * 0.082).clamp(26.0, 34.0);
    final subtitleFontSize = (screenWidth * 0.034).clamp(12.0, 13.5);
    final logoToTitleGap = (screenHeight * 0.065).clamp(42.0, 60.0);
    final progressBarWidth = (screenWidth * 0.35).clamp(110.0, 140.0);

    // Unified vertical center anchor for both the logo and the background orbits
    final logoCenterY = (screenHeight * 0.44).clamp(
      topPadding + 110.0,
      screenHeight - bottomPadding - 230.0,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.splashGradientTop,
              AppColors.splashGradientBottom,
            ],
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.navigateToOnboarding,
          child: Stack(
            children: [
              // 1. Background custom paint anchored to the exact logoCenterY
              Positioned.fill(
                child: CustomPaint(
                  painter: _BackgroundOrbitPainter(
                    center: Offset(screenWidth * 0.5, logoCenterY),
                    screenWidth: screenWidth,
                  ),
                ),
              ),

              // 2. Top Section: Pill Badge (anchored below safe area / notch)
              Positioned(
                top: topPadding + 14,
                left: 0,
                right: 0,
                child: Center(child: _buildTopBadge()),
              ),

              // 3. Center Section: Saturn Logo, Title, and Subtitle (anchored to logoCenterY)
              Positioned(
                top: logoCenterY - (logoSize / 2),
                left: 0,
                right: 0,
                child: _buildCenterBrand(
                  logoSize: logoSize,
                  titleFontSize: titleFontSize,
                  subtitleFontSize: subtitleFontSize,
                  gap: logoToTitleGap,
                ),
              ),

              // 4. Bottom Section: LinearProgressIndicator & Status Text (anchored above home indicator)
              Positioned(
                bottom: bottomPadding + 24,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildBottomSection(barWidth: progressBarWidth),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top pill badge: "Your financial partner" with glowing golden dot
  Widget _buildTopBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.pillBackground.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.pillBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.pillDot,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.pillDot.withValues(alpha: 0.7),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Your financial partner',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Center brand section (Saturn Logo, Finsphere.AI Title, Tagline)
  Widget _buildCenterBrand({
    required double logoSize,
    required double titleFontSize,
    required double subtitleFontSize,
    required double gap,
  }) {
    final sphereSize = logoSize * 0.32;
    final ringWidth = logoSize * 0.54;
    final ringHeight = logoSize * 0.23;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // App icon container with glow and Saturn-style planet emblem
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple,
            borderRadius: BorderRadius.circular(logoSize * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.45),
                blurRadius: 30,
                spreadRadius: 3,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Planet Sphere
                Container(
                  width: sphereSize,
                  height: sphereSize,
                  decoration: const BoxDecoration(
                    color: AppColors.saturnPlanetColor,
                    shape: BoxShape.circle,
                  ),
                ),
                // Tilted Accent Gold Ring
                Transform.rotate(
                  angle: -30 * math.pi / 180,
                  child: Container(
                    width: ringWidth,
                    height: ringHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(ringWidth / 2, ringHeight / 2),
                      ),
                      border: Border.all(
                        color: AppColors.saturnRingColor,
                        width: 3.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: gap),

        // Brand title: Finsphere.AI with accent gold dot
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Finsphere'),
              const TextSpan(
                text: '.',
                style: TextStyle(
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const TextSpan(text: 'AI'),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),

        const SizedBox(height: 10),

        // Subtitle / Tagline
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Keep smiling — quick loans for every need.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom section: Standard LinearProgressIndicator & Status text
  Widget _buildBottomSection({required double barWidth}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          child: SizedBox(
            width: barWidth,
            height: 3.5,
            child: const LinearProgressIndicator(
              backgroundColor: AppColors.progressInactive,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.progressActive,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'SECURING YOUR SESSION',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.splashStatusText,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}

/// Custom painter rendering crossed tilted oval orbits with switched angles and reduced height
class _BackgroundOrbitPainter extends CustomPainter {
  final Offset center;
  final double screenWidth;

  _BackgroundOrbitPainter({
    required this.center,
    required this.screenWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Soft purple halo glow centered behind the logo
    final haloGlow = Paint()
      ..color = AppColors.splashHaloGlow.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55);
    canvas.drawCircle(center, 75, haloGlow);

    // 2. Faint concentric circular guide rings proportional to screenWidth
    final ringPaint = Paint()
      ..color = AppColors.splashGuideRing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, screenWidth * 0.28, ringPaint);
    canvas.drawCircle(center, screenWidth * 0.50, ringPaint);
    canvas.drawCircle(center, screenWidth * 0.72, ringPaint);

    // Sleeker, reduced-height oval dimensions proportional to screenWidth
    final ovalWidth = screenWidth * 1.10;
    final ovalHeight = screenWidth * 0.36;

    // 3. Purple continuous oval orbit (tilted at -18 degrees: rising from bottom-left to top-right)
    final violetAngle = -18 * math.pi / 180;
    final violetPaint = Paint()
      ..color = AppColors.splashOrbitViolet.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(violetAngle);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: ovalWidth,
        height: ovalHeight,
      ),
      violetPaint,
    );
    canvas.restore();

    // 4. Gold dotted oval orbit (tilted at +18 degrees: dipping from top-left to bottom-right, crossing in an "X")
    final goldAngle = 18 * math.pi / 180;
    final goldPaint = Paint()
      ..color = AppColors.splashDottedOrbit.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2;

    final goldOvalPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: ovalWidth,
          height: ovalHeight,
        ),
      );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(goldAngle);
    _drawDashedPath(canvas, goldOvalPath, goldPaint, dashLength: 1.0, spaceLength: 6.5);
    canvas.restore();

    // 5. Glowing white satellite dot resting precisely on the purple orbit path
    const t = 52 * math.pi / 180;
    final a = ovalWidth / 2;
    final b = ovalHeight / 2;
    final x0 = a * math.cos(t);
    final y0 = b * math.sin(t);
    final dotX = center.dx + (x0 * math.cos(violetAngle) - y0 * math.sin(violetAngle));
    final dotY = center.dy + (x0 * math.sin(violetAngle) + y0 * math.cos(violetAngle));
    final dotPosition = Offset(dotX, dotY + 65);

    final dotGlow = Paint()
      ..color = AppColors.splashSatellite.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(dotPosition, 6.0, dotGlow);

    final dotPaint = Paint()..color = AppColors.splashSatellite;
    canvas.drawCircle(dotPosition, 3.0, dotPaint);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double spaceLength,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final length = math.min(dashLength, metric.length - distance);
        final extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dashLength + spaceLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundOrbitPainter oldDelegate) =>
      oldDelegate.center != center || oldDelegate.screenWidth != screenWidth;
}
