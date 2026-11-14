import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../controller/splash_controller.dart';
import '../theme/theme.dart';

/// Clean, responsive, and stateless Splash Screen UI for Finsphere.AI.
/// Features a realistic planetarium (taramandal) animation:
/// Orbit positions remain completely fixed, while smooth celestial light sweeps
/// and streaming stardust travel around the planet (like Earth revolving around the Sun).
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
              // 1. Background custom paint: Fixed orbits with taramandal traveling beam animation
              Positioned.fill(
                child: CustomPaint(
                  painter: _BackgroundOrbitPainter(
                    animation: controller.orbitAnimation,
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
        // App icon container with glow and Saturn-style planet emblem (stationary)
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

/// Custom painter: Taramandal (Planetarium-style) celestial orbit animation.
/// - Orbit positions are 100% FIXED in their signature design positions (-18° and +18°).
/// - White Orbit: Luminous beam with a glowing planetary head sweeps around the track (like Earth orbiting the Sun).
/// - Yellow Dotted Orbit: Golden stardust dots stream smoothly along the track in the opposite direction.
class _BackgroundOrbitPainter extends CustomPainter {
  final Animation<double> animation;
  final Offset center;
  final double screenWidth;

  _BackgroundOrbitPainter({
    required this.animation,
    required this.center,
    required this.screenWidth,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;

    // 1. Soft halo glow centered behind the logo
    final haloGlow = Paint()
      ..color = AppColors.splashHaloGlow.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55);
    canvas.drawCircle(center, 75, haloGlow);

    // 2. Faint concentric circular guide rings proportional to screenWidth
    final ringPaint = Paint()
      ..color = AppColors.splashGuideRing.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, screenWidth * 0.28, ringPaint);
    canvas.drawCircle(center, screenWidth * 0.50, ringPaint);
    canvas.drawCircle(center, screenWidth * 0.72, ringPaint);

    // Exact original oval dimensions (fixed position, never changes)
    final ovalWidth = screenWidth * 1.10;
    final ovalHeight = screenWidth * 0.36;

    // =========================================================================
    // 3. White Orbit (FIXED at -18°): Luminous beam orbiting like Earth around Sun
    // =========================================================================
    const violetAngle = -18 * math.pi / 180;

    final whiteOvalPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: ovalWidth,
          height: ovalHeight,
        ),
      );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(violetAngle);

    // Faint full base track (always visible)
    final baseWhitePaint = Paint()
      ..color = AppColors.orbitWhite.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(whiteOvalPath, baseWhitePaint);

    // Animated luminous beam sweeping along the track (like Earth revolving around Sun)
    final beamPaint = Paint()
      ..color = AppColors.orbitWhite
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.4;

    Offset? headPosition;
    for (final metric in whiteOvalPath.computeMetrics()) {
      final total = metric.length;
      final trailLen = total * 0.35; // 35% trailing light arc
      final head = progress * total;
      final tail = head - trailLen;

      if (tail >= 0) {
        final arc = metric.extractPath(tail, head);
        canvas.drawPath(arc, beamPaint);
      } else {
        final arc1 = metric.extractPath(tail + total, total);
        final arc2 = metric.extractPath(0, head);
        canvas.drawPath(arc1, beamPaint);
        canvas.drawPath(arc2, beamPaint);
      }

      // Leading planetary head position
      final tangent = metric.getTangentForOffset(head);
      if (tangent != null) {
        headPosition = tangent.position;
      }
    }

    // Glowing planetary head node (Earth) at the front of the beam
    if (headPosition != null) {
      final headGlow = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(headPosition, 6.0, headGlow);

      final headCore = Paint()..color = Colors.white;
      canvas.drawCircle(headPosition, 3.2, headCore);
    }

    canvas.restore();

    // =========================================================================
    // 4. Yellow Dotted Orbit (FIXED at +18°): Golden stardust streaming smoothly
    // =========================================================================
    const goldAngle = 18 * math.pi / 180;
    final goldPaint = Paint()
      ..color = AppColors.splashDottedOrbit
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
    // Streams smoothly along the path in the opposite direction
    _drawDashedPath(
      canvas,
      goldOvalPath,
      goldPaint,
      dashLength: 1.0,
      spaceLength: 6.5,
      phase: 1.0 - progress,
    );
    canvas.restore();
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double spaceLength,
    required double phase,
  }) {
    final period = dashLength + spaceLength;
    for (final metric in path.computeMetrics()) {
      var distance = (phase * period) % period;
      while (distance < metric.length) {
        final length = math.min(dashLength, metric.length - distance);
        final extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += period;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundOrbitPainter oldDelegate) => false;
}
