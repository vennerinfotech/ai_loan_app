import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/aadhaar_kyc_controller.dart';
import '../widgets/kyc_stepper.dart';

/// Screen 3 (Branch A): "Aadhaar isn't linked to a mobile number" (Reference Image 4)
class AadhaarNotLinkedScreen extends StatelessWidget {
  const AadhaarNotLinkedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: const [
            KycHeaderWithStepper(activeStep: 1),
            SizedBox(height: 12),
            Expanded(child: AadhaarNotLinkedBody()),
          ],
        ),
      ),
    );
  }
}

/// Content body of "Aadhaar isn't linked to mobile" (used within sticky-header KYC flow)
class AadhaarNotLinkedBody extends StatelessWidget {
  const AadhaarNotLinkedBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AadhaarKycController>();

    return Column(
      children: [
        // Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Phone disconnected icon in light peach circular badge with dotted ring
                _buildDisconnectedPhoneBadge(),
                const SizedBox(height: 24),

                // Heading (increased size & bold weight)
                const Text(
                  'Aadhaar isn\'t linked\nto a mobile number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.22,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle (clearer & balanced size)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'No problem — upload a photo of your Aadhaar card instead and we\'ll verify it manually.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 3-step manual verification info card
                _buildManualStepsCard(),
              ],
            ),
          ),
        ),

        // Bottom Actions: "Upload Aadhaar instead" & "Do it later"
        _buildBottomSection(context, controller),
      ],
    );
  }

  /// Circular badge with disconnected phone icon
  Widget _buildDisconnectedPhoneBadge() {
    return Container(
      width: 108,
      height: 108,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.kycNotLinkedCircleBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.kycNotLinkedCircleBorder,
          width: 1.5,
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.kycNotLinkedCircleBg,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.mobile_off_rounded,
            color: AppColors.kycNotLinkedIcon,
            size: 46,
          ),
        ),
      ),
    );
  }

  /// 3-step numbered card
  Widget _buildManualStepsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          _buildStepRow(1, 'Upload front & back of Aadhaar'),
          const Divider(color: AppColors.line, height: 22, thickness: 1),
          _buildStepRow(2, 'Review the details we read'),
          const Divider(color: AppColors.line, height: 22, thickness: 1),
          _buildStepRow(3, 'Our team confirms it'),
        ],
      ),
    );
  }

  Widget _buildStepRow(int number, String label) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: AppColors.navy,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.amber,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom buttons
  Widget _buildBottomSection(BuildContext context, AadhaarKycController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
      child: Column(
        children: [
          // Upload Aadhaar instead button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.navigateToManualUpload,
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
                  Icon(
                    Icons.badge_outlined,
                    color: AppColors.accentGold,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Upload Aadhaar instead',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // "Do it later" button
          GestureDetector(
            onTap: () => Get.back(),
            child: const Text(
              'Do it later',
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
