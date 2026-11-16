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
                const SizedBox(height: 10),

                // Phone disconnected icon in light peach circular badge
                _buildDisconnectedPhoneBadge(),
                const SizedBox(height: 24),

                // Heading
                const Text(
                  'Aadhaar isn\'t linked\nto a mobile number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'No problem — upload a photo of your Aadhaar card instead and we\'ll verify it manually.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textDarkSecondary,
                      fontSize: 13,
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
        _buildBottomSection(controller),
      ],
    );
  }

  /// Circular badge with disconnected phone icon
  Widget _buildDisconnectedPhoneBadge() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFED7AA),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF2E6),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.phone_disabled_outlined,
              color: Color(0xFFC2410C),
              size: 38,
            ),
          ),
        ),
      ),
    );
  }

  /// 3-step numbered card
  Widget _buildManualStepsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
          const Divider(color: Color(0xFFF1F4FA), height: 20, thickness: 1),
          _buildStepRow(2, 'Review the details we read'),
          const Divider(color: Color(0xFFF1F4FA), height: 20, thickness: 1),
          _buildStepRow(3, 'Our team confirms it'),
        ],
      ),
    );
  }

  Widget _buildStepRow(int number, String label) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF212074),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
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
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom buttons
  Widget _buildBottomSection(AadhaarKycController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
      child: Column(
        children: [
          // Upload Aadhaar instead button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.uploadAadhaarManually,
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
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Upload Aadhaar instead',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
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
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
