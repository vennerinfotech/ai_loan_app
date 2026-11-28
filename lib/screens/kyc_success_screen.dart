import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/aadhaar_kyc_controller.dart';
import '../controller/pan_kyc_controller.dart';
import '../controller/kyc_flow_controller.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import 'credit_check_screen.dart';
import 'loan_flow/choose_loan_type_screen.dart';

/// Screen: "KYC success" (Reference Image 1)
/// Displayed upon successful completion of Aadhaar and PAN verification.
class KycSuccessScreen extends StatelessWidget {
  const KycSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: KycSuccessBody(),
      ),
    );
  }
}

/// Body content of "KYC success" (used within step flow)
class KycSuccessBody extends StatefulWidget {
  const KycSuccessBody({super.key});

  @override
  State<KycSuccessBody> createState() => _KycSuccessBodyState();
}

class _KycSuccessBodyState extends State<KycSuccessBody> {
  late final AadhaarKycController _aadhaarController;
  late final PanKycController _panController;

  @override
  void initState() {
    super.initState();
    _aadhaarController = Get.isRegistered<AadhaarKycController>()
        ? Get.find<AadhaarKycController>()
        : Get.put(AadhaarKycController());

    _panController = Get.isRegistered<PanKycController>()
        ? Get.find<PanKycController>()
        : Get.put(PanKycController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKycDetails();
    });
  }

  Future<void> _loadKycDetails() async {
    // 1. Get user ID directly from previous PAN upload or saved session
    final userId = _panController.uploadedPanData.value?.userId ??
        int.tryParse(await SessionManager.getUserId());
    if (userId == null) return;

    // 2. Fetch applicant details for this user ID
    final data = await ApiService.getApplicantDetailModel(userId: userId);
    if (data == null) return;

    // 3. Populate Name & Date of Birth
    final name =
        (data.kyc?.aadhaar?.nameOnCard ?? data.applicant?.name ?? '').trim();
    if (name.isNotEmpty) {
      _aadhaarController.userName.value = name;
    }

    final dob = (data.applicant?.dateOfBirth ?? '').trim();
    if (dob.isNotEmpty) {
      _aadhaarController.dob.value = dob;
    }

    // 4. Format and populate Aadhaar Number
    final rawAadhaar = (data.kyc?.aadhaar?.number ??
            data.applicant?.aadhaarCardNumber ??
            '')
        .trim();
    final digits = rawAadhaar.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12) {
      _aadhaarController.maskedAadhaarDisplay.value =
          'XXXX XXXX ${digits.substring(8)}';
    } else if (rawAadhaar.isNotEmpty) {
      _aadhaarController.maskedAadhaarDisplay.value = rawAadhaar;
    }
  }

  @override
  Widget build(BuildContext context) {
    final aadhaarController = _aadhaarController;
    final panController = _panController;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // 1. Top Golden Hero Card: "You're verified!" (Animated & Perfectly Centered)
          const _AnimatedGoldenHeroCard(),
          const SizedBox(height: 16),

          // 2. Summary Details Card (Full name, DOB, Aadhaar, PAN)
          Obx(
            () {
              final rawName = aadhaarController.userName.value.trim();
              final name = rawName.isNotEmpty ? rawName : 'N/A';

              final rawDob = aadhaarController.dob.value.trim();
              final dob = rawDob.isNotEmpty ? rawDob : 'N/A';

              final rawAadhaar = aadhaarController.maskedAadhaarDisplay.value.trim();
              final aadhaar = rawAadhaar.isNotEmpty ? rawAadhaar : 'N/A';

              final rawPan = panController.panNumber.value.trim().toUpperCase();
              final pan = rawPan.length == 10
                  ? '${rawPan.substring(0, 5)}••••${rawPan.substring(9)}'
                  : (rawPan.isNotEmpty ? rawPan : 'N/A');

              return _buildSummaryDetailsCard(
                name: name,
                dob: dob,
                aadhaar: aadhaar,
                pan: pan,
              );
            },
          ),
          const SizedBox(height: 14),

          // 3. Privacy & Encryption Note
          _buildPrivacyNote(),
          const SizedBox(height: 20),

          // 4. Action Buttons ("Check my credit score ->" & "Download receipt")
          _buildActionButtons(context),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// White summary details card
  Widget _buildSummaryDetailsCard({
    required String name,
    required String dob,
    required String aadhaar,
    required String pan,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Full name
          _buildInfoRow(label: 'Full name', value: name),
          const Divider(color: AppColors.line, height: 18, thickness: 1),

          // 2. Date of birth
          _buildInfoRow(label: 'Date of birth', value: dob),
          const Divider(color: AppColors.line, height: 18, thickness: 1),

          // 3. Aadhaar
          _buildInfoRow(label: 'Aadhaar', value: aadhaar),
          const Divider(color: AppColors.line, height: 18, thickness: 1),

          // 4. PAN with "Verified" badge
          _buildPanRow(pan: pan),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildPanRow({required String pan}) {
    final isVerified = pan != 'N/A';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'PAN',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pan,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            if (isVerified) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successGreenBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Privacy & Encryption note with shield icon
  Widget _buildPrivacyNote() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppColors.primaryPurple,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your data is encrypted and used only for this loan application, as per RBI KYC norms.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom action buttons
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // 1. Primary Button: "Choose loan type" (Proceed directly to apply for loan)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Get.offAll(() => const ChooseLoanTypeScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButtonBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Choose loan type',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.accentGold,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // 2. Secondary Button: "Check my credit score"
        GestureDetector(
          onTap: () {
            if (Get.isRegistered<KycFlowController>()) {
              Get.find<KycFlowController>().setStep(KycSubStep.creditCheck);
            } else {
              Get.to(() => const CreditCheckScreen());
            }
          },
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line, width: 1.2),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.speed_rounded,
                  color: AppColors.navy,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Check my credit score',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated Top Golden Amber Hero Card with cosmic orbits, moving particles, and central checkmark
class _AnimatedGoldenHeroCard extends StatefulWidget {
  const _AnimatedGoldenHeroCard();

  @override
  State<_AnimatedGoldenHeroCard> createState() => _AnimatedGoldenHeroCardState();
}

class _AnimatedGoldenHeroCardState extends State<_AnimatedGoldenHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 350,
      decoration: BoxDecoration(
        color: AppColors.accentGold,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // 1. Animated background cosmic orbit rings & particles
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _SuccessCardCosmicPainter(
                  progress: _controller.value,
                ),
              );
            },
          ),

          // 2. Foreground content - Perfectly centered horizontally & vertically
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Big Deep Blue Checkmark Circle
                  Container(
                    width: 98,
                    height: 98,
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navy.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: AppColors.accentGold,
                        size: 52,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Heading with left triangle accent & right white dot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Small deep blue triangle pointing right
                      CustomPaint(
                        size: const Size(10, 12),
                        painter: _LeftTrianglePainter(),
                      ),
                      const SizedBox(width: 8),

                      const Text(
                        "You're verified!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // White circular dot
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),

                  // Subtitle: "Aadhaar & PAN matched successfully"
                  const Text(
                    'Aadhaar & PAN matched successfully',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter that draws concentric orbit rings and animated cosmic particles revolving along the orbit
class _SuccessCardCosmicPainter extends CustomPainter {
  final double progress;

  const _SuccessCardCosmicPainter({this.progress = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    // Aligns mathematically with the checkmark circle center
    final center = Offset(size.width * 0.5, size.height * 0.387);
    final pulse = math.sin(progress * 2 * math.pi);

    // 1. Inner solid guide circle in warm amber with subtle breathing glow
    final innerOrbitPaint = Paint()
      ..color = AppColors.goldenOrbitInner.withValues(alpha: 0.48 + 0.08 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(center, 78, innerOrbitPaint);

    // 2. Middle solid guide circle in warm amber
    final middleOrbitPaint = Paint()
      ..color = AppColors.goldenOrbitMiddle.withValues(alpha: 0.36 + 0.06 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(center, 114, middleOrbitPaint);

    // 3. Outer tilted DASHED / DOTTED elliptical orbit
    const double rx = 160.0;
    const double ry = 67.5;
    const double tilt = -24 * math.pi / 180;

    final dashedOrbitPaint = Paint()
      ..color = AppColors.goldenOrbitDashed.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;

    _drawDashedOval(
      canvas: canvas,
      center: center,
      width: rx * 2,
      height: ry * 2,
      angle: tilt,
      paint: dashedOrbitPaint,
      dashOffset: progress * 9.0,
    );

    // Helper functions to calculate orbital position and tangent along the tilted ellipse
    Offset getOrbitPoint(double phaseOffset) {
      final double angle = (progress + phaseOffset) * 2 * math.pi;
      final double xUnrot = rx * math.cos(angle);
      final double yUnrot = ry * math.sin(angle);
      final double xRot = xUnrot * math.cos(tilt) - yUnrot * math.sin(tilt);
      final double yRot = xUnrot * math.sin(tilt) + yUnrot * math.cos(tilt);
      return Offset(center.dx + xRot, center.dy + yRot);
    }

    double getTangent(double phaseOffset) {
      final double angle = (progress + phaseOffset) * 2 * math.pi;
      final double dx = -rx * math.sin(angle);
      final double dy = ry * math.cos(angle);
      final double dxRot = dx * math.cos(tilt) - dy * math.sin(tilt);
      final double dyRot = dx * math.sin(tilt) + dy * math.cos(tilt);
      return math.atan2(dyRot, dxRot);
    }

    // 4. Floating cosmic particles orbiting around the central circle along the track
    // Particle A: Deep blue rotated squircle / diamond (initial phase 0.40)
    final posA = getOrbitPoint(0.40);
    final tangentA = getTangent(0.40);
    canvas.save();
    canvas.translate(posA.dx, posA.dy);
    canvas.rotate(tangentA + (math.pi / 4));
    final blueSquarePaint = Paint()..color = AppColors.navy;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 13, height: 13),
        const Radius.circular(3.5),
      ),
      blueSquarePaint,
    );
    canvas.restore();

    // Particle B: White slanted pill capsule (initial phase 0.125)
    final posB = getOrbitPoint(0.125);
    final tangentB = getTangent(0.125);
    canvas.save();
    canvas.translate(posB.dx, posB.dy);
    canvas.rotate(tangentB);
    final whitePillPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 7, height: 20),
        const Radius.circular(4),
      ),
      whitePillPaint,
    );
    canvas.restore();

    // Particle C: Blue circular dot (initial phase 0.95)
    final posC = getOrbitPoint(0.95);
    final blueDotPaint = Paint()..color = AppColors.navy;
    canvas.drawCircle(posC, 6.5, blueDotPaint);
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
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final path = Path()..addOval(Rect.fromCenter(center: Offset.zero, width: width, height: height));
    final dashedPath = Path();

    const dashWidth = 3.5;
    const dashSpace = 5.5;
    const patternLength = dashWidth + dashSpace;

    for (final metric in path.computeMetrics()) {
      double distance = dashOffset % patternLength;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length) ? dashWidth : metric.length - distance;
        dashedPath.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        distance += patternLength;
      }
    }

    canvas.drawPath(dashedPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SuccessCardCosmicPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Small blue triangle accent to the left of "You're verified!"
class _LeftTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.navy
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
