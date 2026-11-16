import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/pan_kyc_controller.dart';
import '../widgets/kyc_stepper.dart';

/// Screen 1 of PAN KYC Flow: "Enter your PAN" (Reference Image 1)
class EnterPanScreen extends StatelessWidget {
  const EnterPanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: const [
            KycHeaderWithStepper(activeStep: 2),
            SizedBox(height: 12),
            Expanded(child: EnterPanBody()),
          ],
        ),
      ),
    );
  }
}

/// Content body of "Enter your PAN" (used within sticky-header KYC flow)
class EnterPanBody extends StatelessWidget {
  const EnterPanBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PanKycController());

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
                  'Enter your PAN',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                const Text(
                  'Needed to check your credit profile and tax records.',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Label
                const Text(
                  'PAN number',
                  style: TextStyle(
                    color: AppColors.inputLabel,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // PAN Text Field
                _buildPanInputField(controller),
                const SizedBox(height: 6),

                // Help caption
                const Text(
                  '10 characters • 5 letters, 4 numbers, 1 letter',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 24),

                // PREVIEW Container
                _buildPreviewCard(controller),
                const SizedBox(height: 18),

                // "Upload PAN card instead" Button
                _buildUploadInsteadButton(controller),
                const SizedBox(height: 24),

                // Branching simulation switch
                _buildSimulationToggle(controller),
              ],
            ),
          ),
        ),

        // Bottom Action: Verify PAN Button
        _buildBottomSection(controller),
      ],
    );
  }

  /// PAN input text field
  Widget _buildPanInputField(PanKycController controller) {
    return TextFormField(
      controller: controller.panController,
      onChanged: controller.onPanChanged,
      textCapitalization: TextCapitalization.characters,
      style: const TextStyle(
        color: AppColors.inputText,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'ABCDE1234F',
        hintStyle: const TextStyle(
          color: AppColors.inputHintIcon,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC7D0EE), width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFC7D0EE), width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.fieldFocusedBorder, width: 2.0),
        ),
      ),
    );
  }

  /// PREVIEW card with "AARAV MEHTA" and "Matches Aadhaar" badge
  Widget _buildPreviewCard(PanKycController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dashboardCardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PREVIEW',
            style: TextStyle(
              color: AppColors.textDarkSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          // Lavender preview box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF1FD),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Name as per PAN',
                      style: TextStyle(
                        color: AppColors.textDarkSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Obx(
                      () => Text(
                        controller.nameAsPerPan.value,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),

                // Matches Aadhaar badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Matches Aadhaar',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "Upload PAN card instead" Button
  Widget _buildUploadInsteadButton(PanKycController controller) {
    return GestureDetector(
      onTap: controller.uploadPanCardInstead,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFB8C2EC),
            width: 1.2,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.badge_outlined,
              color: AppColors.primaryPurple,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Upload PAN card instead',
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Simulation toggle to test both branches (PAN Verified vs PAN Not Verified)
  Widget _buildSimulationToggle(PanKycController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6DCF6), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, color: AppColors.primaryPurple, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulation: PAN matches Income Tax records?',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Toggle to test Verified vs Not Verified flows',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: controller.isPanVerified.value,
              activeThumbColor: AppColors.primaryPurple,
              activeTrackColor: AppColors.primaryPurple.withValues(alpha: 0.3),
              onChanged: (val) => controller.isPanVerified.value = val,
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Verify PAN Button
  Widget _buildBottomSection(PanKycController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: controller.verifyPan,
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
                'Verify PAN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
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
    );
  }
}
