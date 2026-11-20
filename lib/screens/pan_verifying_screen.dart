import 'dart:async';
import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/pan_kyc_controller.dart';
import '../controller/aadhaar_kyc_controller.dart';
import '../controller/kyc_flow_controller.dart';
import 'upload_pan_screen.dart';

/// Loading phases for PAN verification
enum PanVerifyingPhase {
  validatingFormat, // Step 1 completed, Step 2 in-progress (Live)
  matchingTaxRecords, // Step 2 live with pulse, Step 3 pending
  allComplete, // All complete -> triggers popup dialog
}

/// "PAN Verifying" Screen matching the design specification.
/// Features an animated circular gauge, cosmic orbit lines, live progress stages,
/// dynamic user name & masked PAN, followed by the "PAN not linked with mobile" popup dialog.
class PanVerifyingScreen extends StatefulWidget {
  const PanVerifyingScreen({super.key});

  @override
  State<PanVerifyingScreen> createState() => _PanVerifyingScreenState();
}

class _PanVerifyingScreenState extends State<PanVerifyingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  PanVerifyingPhase _currentPhase = PanVerifyingPhase.matchingTaxRecords;
  int _displayPercentage = 15;

  Timer? _phaseTimer1;
  Timer? _phaseTimer2;

  @override
  void initState() {
    super.initState();

    // 1. Cosmic orbit slow rotation animation
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // 2. Main circular progress gauge animation (0% -> ~68% -> 100%)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _progressAnimation = Tween<double>(begin: 0.15, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ),
    )..addListener(() {
        setState(() {
          _displayPercentage = (_progressAnimation.value * 100).toInt().clamp(0, 100);
        });
      });

    _progressController.forward();

    // 3. Start progressive animation after first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startVerificationProcess();
      }
    });
  }

  Future<void> _startVerificationProcess() async {
    // Phase 1: format validated, matching tax records is Live (~68% around 1.4s)
    _phaseTimer1 = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _currentPhase = PanVerifyingPhase.matchingTaxRecords;
        });
      }
    });

    // Smooth animation duration for verifying visual
    await Future.delayed(const Duration(milliseconds: 3200));

    if (!mounted) return;

    // Phase 2: All complete
    setState(() {
      _currentPhase = PanVerifyingPhase.allComplete;
      _displayPercentage = 100;
    });

    // Brief delay to show 100% completion before opening popup dialog
    _phaseTimer2 = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _showPanNotLinkedDialog();
      }
    });
  }

  /// Displays the "PAN not linked with mobile" popup dialog
  void _showPanNotLinkedDialog() {
    final panController = Get.isRegistered<PanKycController>()
        ? Get.find<PanKycController>()
        : Get.put(PanKycController());

    bool isSubmitting = false;

    Get.dialog(
      PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Layered warning / phone badge
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFE0B2),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.contact_phone_outlined,
                          color: Color(0xFFE65100),
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Dialog Title
                    const Text(
                      'PAN not linked with mobile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Dialog Subtitle / explanation
                    const Text(
                      'Your PAN is not linked to your registered mobile number for instant verification. Please upload a clear photo or PDF of your PAN card to proceed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons: "Cancel" & "Continue"
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () {
                                      Get.back(); // close dialog
                                      Get.back(); // return to enter PAN screen
                                    },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.line, width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Continue Button (triggers store PAN API and navigates to upload screen)
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      setDialogState(() {
                                        isSubmitting = true;
                                      });

                                      // Call store PAN API on tap continue button from dialogue box
                                      await panController.storePanCardApi();

                                      Get.back(); // close dialog
                                      if (Get.isRegistered<KycFlowController>()) {
                                        Get.back(); // close PanVerifyingScreen
                                        Get.find<KycFlowController>().setStep(KycSubStep.panUpload);
                                      } else {
                                        Get.off(() => const UploadPanScreen());
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navy,
                                disabledBackgroundColor: AppColors.navy.withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Upload PAN card',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: AppColors.amber,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _progressController.dispose();
    _phaseTimer1?.cancel();
    _phaseTimer2?.cancel();
    super.dispose();
  }

  /// Resolves the user's display name dynamically (e.g. "Aarav" or "Rahul")
  String _getUserFirstName() {
    if (Get.isRegistered<AadhaarKycController>()) {
      final name = Get.find<AadhaarKycController>().userName.value.trim();
      if (name.isNotEmpty) {
        return name.split(RegExp(r'\s+')).first;
      }
    }
    return 'User';
  }

  /// Formats the PAN as masked e.g. "ABCDE••••F"
  String _getMaskedPan(String rawPan) {
    final clean = rawPan.trim().toUpperCase();
    if (clean.length == 10) {
      return '${clean.substring(0, 5)}••••${clean.substring(9)}';
    }
    return clean.isNotEmpty ? clean : '••••••••••';
  }

  @override
  Widget build(BuildContext context) {
    final panController = Get.isRegistered<PanKycController>()
        ? Get.find<PanKycController>()
        : Get.put(PanKycController());

    final firstName = _getUserFirstName();
    final maskedPan = _getMaskedPan(panController.panNumber.value);

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 14),

              // 1. Top Capsule Badge: "Step 2 of 3 · PAN verification"
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Step 2 of 3 · PAN verification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // 2. Central Animated Gauge with Cosmic Orbit and Traveling Amber Dot
              SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Faint Cosmic background orbits
                    AnimatedBuilder(
                      animation: _orbitController,
                      builder: (context, _) {
                        return CustomPaint(
                          size: const Size(250, 250),
                          painter: _PanCosmicOrbitPainter(
                            rotation: _orbitController.value,
                          ),
                        );
                      },
                    ),

                    // Main circular gauge with progress arc & glowing amber dot tip
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, _) {
                        return CustomPaint(
                          size: const Size(200, 200),
                          painter: _CircularProgressGaugePainter(
                            progress: _progressAnimation.value,
                          ),
                        );
                      },
                    ),

                    // Center percentage & "Verifying identity" subtitle
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$_displayPercentage',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const Text(
                              '%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Verifying identity',
                          style: TextStyle(
                            color: AppColors.indigoTint,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Heading: "Hang tight, [Name]"
              Text(
                'Hang tight, $firstName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),

              // 4. Subtitle: "Securely checking PAN [ABCDE••••F]"
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    color: AppColors.indigoTint,
                    fontSize: 13.5,
                  ),
                  children: [
                    const TextSpan(text: 'Securely checking PAN '),
                    TextSpan(
                      text: maskedPan,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // 5. Checklist Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1A66).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Step 1: PAN format validated (always Done)
                    _buildChecklistRow(
                      title: 'PAN format validated',
                      status: _StepState.done,
                    ),
                    _buildDivider(),

                    // Step 2: Matching with Income Tax records (Live)
                    _buildChecklistRow(
                      title: 'Matching with Income Tax records',
                      status: _currentPhase == PanVerifyingPhase.allComplete
                          ? _StepState.done
                          : _StepState.live,
                    ),
                    _buildDivider(),

                    // Step 3: Cross-checking with Aadhaar name (Next / Done)
                    _buildChecklistRow(
                      title: 'Cross-checking with Aadhaar name',
                      status: _currentPhase == PanVerifyingPhase.allComplete
                          ? _StepState.done
                          : _StepState.next,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // 6. Footer Note: "Please keep the app open" with padlock icon
              const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.indigoTint,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Please keep the app open',
                      style: TextStyle(
                        color: AppColors.indigoTint,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildChecklistRow({
    required String title,
    required _StepState status,
  }) {
    return Row(
      children: [
        // Left Icon
        _buildStepIcon(status),
        const SizedBox(width: 14),

        // Title
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: status == _StepState.next
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.white,
              fontSize: 13.5,
              fontWeight: status == _StepState.next ? FontWeight.w500 : FontWeight.w700,
            ),
          ),
        ),

        // Right Status Badge
        _buildRightStatusBadge(status),
      ],
    );
  }

  Widget _buildStepIcon(_StepState status) {
    switch (status) {
      case _StepState.done:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.amber,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: AppColors.navy,
              size: 15,
            ),
          ),
        );

      case _StepState.live:
        return SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            backgroundColor: AppColors.indigo.withValues(alpha: 0.35),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amber),
          ),
        );

      case _StepState.next:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.indigo.withValues(alpha: 0.6),
              width: 1.8,
            ),
          ),
        );
    }
  }

  Widget _buildRightStatusBadge(_StepState status) {
    switch (status) {
      case _StepState.done:
        return const Text(
          'Done',
          style: TextStyle(
            color: AppColors.indigoTint,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
      case _StepState.live:
        return const Text(
          'Live',
          style: TextStyle(
            color: AppColors.amber,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        );
      case _StepState.next:
        return Text(
          'Next',
          style: TextStyle(
            color: AppColors.indigoTint.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        );
    }
  }
}

enum _StepState { done, live, next }

/// Custom painter for circular progress ring gauge with glowing amber dot at the tip
class _CircularProgressGaugePainter extends CustomPainter {
  final double progress;

  const _CircularProgressGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.width * 0.42;
    const strokeWidth = 12.0;

    // 1. Background full circular track
    final trackPaint = Paint()
      ..color = const Color(0xFF262477)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Active Progress Arc (starts from -90 degrees / top)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    final progressPaint = Paint()
      ..color = const Color(0xFF5D5FEF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // 3. Glowing amber/yellow dot at the tip of the progress arc
    if (progress > 0.02) {
      final tipAngle = startAngle + sweepAngle;
      final tipX = center.dx + radius * math.cos(tipAngle);
      final tipY = center.dy + radius * math.sin(tipAngle);
      final tipCenter = Offset(tipX, tipY);

      // Subtle glow
      final glowPaint = Paint()
        ..color = AppColors.amber.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(tipCenter, 9, glowPaint);

      // Solid amber circle
      final dotPaint = Paint()
        ..color = AppColors.amber
        ..style = PaintingStyle.fill;
      canvas.drawCircle(tipCenter, 6.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Painter for background cosmic orbits and faint ellipse lines around the gauge
class _PanCosmicOrbitPainter extends CustomPainter {
  final double rotation;

  const _PanCosmicOrbitPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.5);

    // Concentric faint guide circles
    final faintCirclePaint = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, size.width * 0.48, faintCirclePaint);

    // Tilted ellipse
    const double tilt = -22 * math.pi / 180;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);

    final ellipsePaint = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 1.05,
        height: size.height * 0.52,
      ),
      ellipsePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PanCosmicOrbitPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}
