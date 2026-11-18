import 'dart:async';
import 'dart:math' as math;
import 'package:ai_loan_app/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'cibil_score_screen.dart';

/// Loading phase progression for fetching CIBIL & CRIF report
enum FetchingPhase {
  readingHistory, // Step 1 completed, Step 2 in-progress (spinner)
  buildingSummary, // Step 1 & 2 completed, Step 3 in-progress (spinner)
  allComplete, // All 3 completed (success checkmarks)
}

/// "Fetching your report" screen matching Reference Image 1
class FetchingReportScreen extends StatefulWidget {
  const FetchingReportScreen({super.key});

  @override
  State<FetchingReportScreen> createState() => _FetchingReportScreenState();
}

class _FetchingReportScreenState extends State<FetchingReportScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orbitController;
  FetchingPhase _currentPhase = FetchingPhase.readingHistory;

  Timer? _phaseTimer1;
  Timer? _phaseTimer2;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // 1. Cosmic orbit animation controller
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    // 2. Simulated multi-step API loading progression
    // Phase 1 -> Phase 2: After 1.8 seconds, "Reading credit history" succeeds and "Building your score summary" starts
    _phaseTimer1 = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _currentPhase = FetchingPhase.buildingSummary;
        });
      }
    });

    // Phase 2 -> Phase 3: After 3.4 seconds, all 3 steps show success tick marks
    _phaseTimer2 = Timer(const Duration(milliseconds: 3400), () {
      if (mounted) {
        setState(() {
          _currentPhase = FetchingPhase.allComplete;
        });
      }
    });

    // Phase 3 -> Navigate to CIBIL Score Screen after 4.2 seconds
    _navigationTimer = Timer(const Duration(milliseconds: 4200), () {
      if (mounted) {
        Get.off(() => const CibilScoreScreen());
      }
    });
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _phaseTimer1?.cancel();
    _phaseTimer2?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            // Top capsule badge: "Step 3 of 3 • Credit check"
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Step 3 of 3 · Credit check',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 1),

            // Animated Cosmic Orbit Illustration with Center Disc
            AnimatedBuilder(
              animation: _orbitController,
              builder: (context, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 270,
                  child: CustomPaint(
                    painter: _FetchingCosmicOrbitPainter(
                      progress: _orbitController.value,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // Heading & Subtitle
            const Text(
              'Fetching your report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connecting to CIBIL & CRIF bureaus...',
              style: TextStyle(
                color: AppColors.indigoTint,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),

            const Spacer(flex: 1),

            // Bottom Progress Status Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Step 1: Identity matched (always completed)
                    _buildStepRow(
                      label: 'Identity matched',
                      status: _StepStatus.completed,
                    ),
                    _buildDivider(),

                    // Step 2: Reading credit history
                    _buildStepRow(
                      label: 'Reading credit history',
                      status: _currentPhase == FetchingPhase.readingHistory
                          ? _StepStatus.loading
                          : _StepStatus.completed,
                    ),
                    _buildDivider(),

                    // Step 3: Building your score summary
                    _buildStepRow(
                      label: 'Building your score summary',
                      status: _currentPhase == FetchingPhase.readingHistory
                          ? _StepStatus.pending
                          : (_currentPhase == FetchingPhase.buildingSummary
                              ? _StepStatus.loading
                              : _StepStatus.completed),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 1),

            // Footer note
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'Please keep the app open · View summary',
                style: TextStyle(
                  color: AppColors.indigoTint,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        color: Colors.white.withValues(alpha: 0.08),
        height: 1,
        thickness: 1,
      ),
    );
  }

  Widget _buildStepRow({
    required String label,
    required _StepStatus status,
  }) {
    return Row(
      children: [
        // Indicator: Completed (Check), Loading (Spinner), Pending (Empty circle)
        _buildStatusIndicator(status),
        const SizedBox(width: 14),

        // Text
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: status == _StepStatus.pending
                  ? AppColors.indigoTint.withValues(alpha: 0.6)
                  : Colors.white,
              fontSize: 14.5,
              fontWeight: status == _StepStatus.pending
                  ? FontWeight.w500
                  : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(_StepStatus status) {
    switch (status) {
      case _StepStatus.completed:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.amber,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: AppColors.navy,
              size: 16,
            ),
          ),
        );

      case _StepStatus.loading:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            backgroundColor: AppColors.indigo.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amber),
          ),
        );

      case _StepStatus.pending:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.indigo.withValues(alpha: 0.5),
              width: 1.8,
            ),
          ),
        );
    }
  }
}

enum _StepStatus { completed, loading, pending }

/// Custom painter for the cosmic orbit illustration with animated traveling planet
class _FetchingCosmicOrbitPainter extends CustomPainter {
  final double progress;

  const _FetchingCosmicOrbitPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);

    // 1. Concentric guide circles
    final guideCirclePaint1 = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, 96, guideCirclePaint1);

    final guideCirclePaint2 = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, 140, guideCirclePaint2);

    // 2. Faint solid continuous tilted ellipse
    const double tilt1 = -18 * math.pi / 180;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt1);
    final faintEllipsePaint = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 300, height: 100),
      faintEllipsePaint,
    );

    // Soft celestial dot on the left side of the continuous orbit (matching reference)
    const double tDot = 0.82 * math.pi;
    final dotX = 150.0 * math.cos(tDot);
    final dotY = 50.0 * math.sin(tDot);
    final faintDotPaint = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(dotX, dotY), 3.5, faintDotPaint);
    canvas.restore();

    // 3. Tilted Dashed Golden Orbit with traveling amber planet dot (flatter with reduced height)
    const double tilt2 = 18 * math.pi / 180;
    const double rx = 152.0;
    const double ry = 38.0;

    final dashedPaint = Paint()
      ..color = AppColors.amber.withValues(alpha: 0.52)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;

    _drawDashedOval(
      canvas: canvas,
      center: center,
      width: rx * 2,
      height: ry * 2,
      angle: tilt2,
      paint: dashedPaint,
      dashOffset: progress * 8.0,
    );

    // Traveling glowing golden planet on the dashed orbit
    final double angle = progress * 2 * math.pi;
    final double xUnrot = rx * math.cos(angle);
    final double yUnrot = ry * math.sin(angle);
    final double xRot = xUnrot * math.cos(tilt2) - yUnrot * math.sin(tilt2);
    final double yRot = xUnrot * math.sin(tilt2) + yUnrot * math.cos(tilt2);
    final planetPos = Offset(center.dx + xRot, center.dy + yRot);

    // Planet outer soft glow
    final planetGlowPaint = Paint()
      ..color = AppColors.amber.withValues(alpha: 0.32)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(planetPos, 10, planetGlowPaint);

    // Planet core
    final planetCorePaint = Paint()
      ..color = AppColors.amber
      ..style = PaintingStyle.fill;
    canvas.drawCircle(planetPos, 5.0, planetCorePaint);

    // 4. Central circular disc with subtle shadow and white bar chart icon (larger size)
    final discShadowPaint = Paint()
      ..color = AppColors.navy.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(center, 58, discShadowPaint);

    final discPaint = Paint()
      ..color = AppColors.indigo
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 58, discPaint);

    // Central disc subtle border
    final discBorderPaint = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawCircle(center, 58, discBorderPaint);

    // Draw Bar Chart icon manually for crisp vector alignment
    _drawBarChartIcon(canvas, center);
  }

  void _drawBarChartIcon(Canvas canvas, Offset center) {
    final barPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const double barWidth = 4.2;
    const double radius = 2.0;
    final baseline = center.dy + 15;

    // Base horizontal line
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 20, baseline, 40, 3.0),
        const Radius.circular(1.5),
      ),
      barPaint,
    );

    // Bar 1 (left: height 20)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 12.5, baseline - 20, barWidth, 20),
        const Radius.circular(radius),
      ),
      barPaint,
    );

    // Bar 2 (center: height 30)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 2.1, baseline - 30, barWidth, 30),
        const Radius.circular(radius),
      ),
      barPaint,
    );

    // Bar 3 (right: height 15)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx + 8.3, baseline - 15, barWidth, 15),
        const Radius.circular(radius),
      ),
      barPaint,
    );
  }

  void _drawDashedOval({
    required Canvas canvas,
    required Offset center,
    required double width,
    required double height,
    required double angle,
    required Paint paint,
    required double dashOffset,
  }) {
    final path = Path();
    final rx = width / 2;
    final ry = height / 2;

    const int steps = 140;
    for (int i = 0; i <= steps; i++) {
      final t = (i / steps) * 2 * math.pi;
      final xUnrot = rx * math.cos(t);
      final yUnrot = ry * math.sin(t);
      final xRot = xUnrot * math.cos(angle) - yUnrot * math.sin(angle);
      final yRot = xUnrot * math.sin(angle) + yUnrot * math.cos(angle);
      final pt = Offset(center.dx + xRot, center.dy + yRot);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }

    final dashedPath = Path();
    const double dashWidth = 5.0;
    const double dashSpace = 4.5;
    double currentDistance = dashOffset % (dashWidth + dashSpace);

    for (final metric in path.computeMetrics()) {
      while (currentDistance < metric.length) {
        final start = currentDistance;
        final end = math.min(start + dashWidth, metric.length);
        dashedPath.addPath(
          metric.extractPath(start, end),
          Offset.zero,
        );
        currentDistance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _FetchingCosmicOrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
