import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/pan_kyc_controller.dart';
import '../widgets/kyc_stepper.dart';

/// Screen 4: "Review PAN details" (Reference Image 4)
class ReviewPanDetailsScreen extends StatelessWidget {
  const ReviewPanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: const [
            KycHeaderWithStepper(activeStep: 2),
            SizedBox(height: 12),
            Expanded(child: ReviewPanDetailsBody()),
          ],
        ),
      ),
    );
  }
}

/// Content body of "Review PAN details" (used within sticky-header KYC flow)
class ReviewPanDetailsBody extends StatelessWidget {
  const ReviewPanDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PanKycController>();

    return Column(
      children: [
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Heading
                const Text(
                  'Review PAN details',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 5),

                // Subtitle
                const Text(
                  'Read from your PAN card. Edit anything that looks off.',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),

                // Golden Amber PAN Card Display
                _buildGoldenPanCard(controller),
                const SizedBox(height: 14),

                // Extracted Details White Card
                _buildExtractedDetailsCard(controller),
                const SizedBox(height: 14),

                // Match Notice Box: "Name on PAN matches your Aadhaar..."
                _buildMatchNoticeBox(),
              ],
            ),
          ),
        ),

        // Bottom Actions: "Edit" & "Confirm & submit ->"
        _buildBottomSection(controller),
      ],
    );
  }

  /// Golden Amber PAN Card with orbit curves, PAN number, and "Format valid" badge
  Widget _buildGoldenPanCard(PanKycController controller) {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.accentGold,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background orbit ring painter
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: _PanCardOrbitPainter(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Permanent Account Number',
                  style: TextStyle(
                    color: Color(0xFF212074),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Obx(
                  () => Text(
                    controller.panNumber.value,
                    style: const TextStyle(
                      color: Color(0xFF212074),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),

                // "Format valid" pill badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF212074),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_rounded,
                        color: AppColors.accentGold,
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Format valid',
                        style: TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Extracted Details Card (Name on PAN, Father's name, Date of birth)
  Widget _buildExtractedDetailsCard(PanKycController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dashboardCardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1: Name on PAN
          _buildDetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Name on PAN',
            value: controller.nameAsPerPan.value,
          ),
          const Divider(color: Color(0xFFF1F4FA), height: 14, thickness: 1),

          // 2: Father's name
          _buildDetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Father\'s name',
            value: controller.fathersName.value,
          ),
          const Divider(color: Color(0xFFF1F4FA), height: 14, thickness: 1),

          // 3: Date of birth
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date of birth',
            value: controller.dob.value,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Soft purple icon square
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF1FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(icon, color: AppColors.primaryPurple, size: 16),
            ),
          ),
          const SizedBox(width: 12),

          // Label & Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Match notice container
  Widget _buildMatchNoticeBox() {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6DCF6), width: 1),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppColors.primaryPurple,
            size: 18,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Name on PAN matches your Aadhaar. You\'re good to go.',
              style: TextStyle(
                color: Color(0xFF333099),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Edit & Confirm & submit buttons
  Widget _buildBottomSection(PanKycController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: Row(
        children: [
          // Edit Button
          GestureDetector(
            onTap: controller.editDetails,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDE3F0), width: 1.2),
              ),
              child: const Center(
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Confirm & submit Button
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: controller.submitPanDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButtonBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Confirm & submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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
          ),
        ],
      ),
    );
  }
}

/// Custom painter for orbit curves on PAN card
class _PanCardOrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5A62E).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path();
    path.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.85, size.height * 0.4),
      width: size.width * 0.8,
      height: size.height * 1.2,
    ));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
