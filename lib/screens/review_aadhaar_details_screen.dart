import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/aadhaar_kyc_controller.dart';
import '../widgets/kyc_stepper.dart';

/// Screen 4: "Check your details" (Review Aadhaar Details - Reference Image 5)
class ReviewAadhaarDetailsScreen extends StatelessWidget {
  const ReviewAadhaarDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: const [
            KycHeaderWithStepper(activeStep: 1),
            SizedBox(height: 12),
            Expanded(child: ReviewAadhaarDetailsBody()),
          ],
        ),
      ),
    );
  }
}

/// Content body of "Check your details" (used within sticky-header KYC flow)
class ReviewAadhaarDetailsBody extends StatelessWidget {
  const ReviewAadhaarDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AadhaarKycController>();

    return Column(
      children: [
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Heading
                const Text(
                  'Check your details',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                const Text(
                  'Pulled from UIDAI. Tap Edit only if something is wrong.',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Top Banner Card: Aarav Mehta & Masked Aadhaar
                _buildUserBannerCard(controller),
                const SizedBox(height: 16),

                // Details Card (DOB, Gender, Address, Mobile)
                _buildDetailsCard(controller),
                const SizedBox(height: 18),

                // Confirmation Checkbox Row
                _buildConfirmationCheckbox(controller),
              ],
            ),
          ),
        ),

        // Bottom Actions: Edit & Confirm & Continue Buttons
        _buildBottomSection(controller),
      ],
    );
  }

  /// Dark banner card with avatar, masked Aadhaar, and cosmic orbit bg pattern
  Widget _buildUserBannerCard(AadhaarKycController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradientDiagonal,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background cosmic orbit design pattern at top right / right edge
          const Positioned.fill(
            child: CustomPaint(
              painter: _UserCardCosmicPatternPainter(),
            ),
          ),

          // Foreground Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Yellow square avatar AM
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Obx(
                      () => Text(
                        controller.userInitials.value,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // User Name & Masked Aadhaar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          controller.userName.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          controller.maskedAadhaarDisplay.value,
                          style: const TextStyle(
                            color: AppColors.indigoTint,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
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

  /// White details card with 4 items
  Widget _buildDetailsCard(AadhaarKycController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dashboardCardBorder, width: 1.2),
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
          // 1: Date of birth
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date of birth',
            value: controller.dob.value,
          ),
          const Divider(color: AppColors.line, height: 16, thickness: 1),

          // 2: Gender
          _buildDetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Gender',
            value: controller.gender.value,
          ),
          const Divider(color: AppColors.line, height: 16, thickness: 1),

          // 3: Address
          _buildDetailRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: controller.address.value,
          ),
          const Divider(color: AppColors.line, height: 16, thickness: 1),

          // 4: Mobile (linked)
          _buildDetailRow(
            icon: Icons.smartphone_rounded,
            label: 'Mobile (linked)',
            value: controller.linkedMobile.value,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Soft purple icon square
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.indigoTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, color: AppColors.primaryPurple, size: 18),
            ),
          ),
          const SizedBox(width: 14),

          // Label & Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Confirmation checkbox
  Widget _buildConfirmationCheckbox(AadhaarKycController controller) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.isConfirmChecked.value = !controller.isConfirmChecked.value,
        behavior: HitTestBehavior.opaque,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: controller.isConfirmChecked.value
                    ? AppColors.primaryButtonBackground
                    : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: controller.isConfirmChecked.value
                      ? AppColors.primaryButtonBackground
                      : AppColors.line,
                  width: 1.5,
                ),
              ),
              child: controller.isConfirmChecked.value
                  ? const Center(
                      child: Icon(Icons.check_rounded, color: Colors.white, size: 16),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'I confirm these details are correct and belong to me.',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Edit & Confirm & Continue Buttons
  Widget _buildBottomSection(AadhaarKycController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
      child: Row(
        children: [
          // Edit Button
          GestureDetector(
            onTap: controller.editDetails,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line, width: 1.2),
              ),
              child: const Center(
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Confirm & Continue Button
          Expanded(
            child: Obx(
              () => SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isConfirmChecked.value
                      ? controller.confirmAndContinue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonBackground,
                    disabledBackgroundColor: AppColors.navy.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirm & continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
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
          ),
        ],
      ),
    );
  }
}

/// Tilted cosmic orbit elliptical pattern for user info card matching Figma (single line only)
class _UserCardCosmicPatternPainter extends CustomPainter {
  const _UserCardCosmicPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width - 45, size.height * 0.48);
    canvas.rotate(-25 * math.pi / 180);

    // Single distinct loop stroke matching reference
    final orbitPaint = Paint()
      ..color = AppColors.indigo.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 145,
        height: 60,
      ),
      orbitPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
