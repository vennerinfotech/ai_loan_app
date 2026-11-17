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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Heading
                const Text(
                  'Enter your PAN',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                const Text(
                  'Needed to check your credit profile and tax records.',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),

                // Label
                const Text(
                  'PAN number',
                  style: TextStyle(
                    color: AppColors.inputLabel,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                // PAN Text Field
                _buildPanInputField(controller),
                const SizedBox(height: 5),

                // Help caption
                const Text(
                  '10 characters • 5 letters, 4 numbers, 1 letter',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 16),

                // PREVIEW Container
                _buildPreviewCard(controller),
                const SizedBox(height: 14),

                // "Upload PAN card instead" Button
                _buildUploadInsteadButton(controller),
                const SizedBox(height: 16),

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
        fontSize: 17,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'ABCDE1234F',
        hintStyle: const TextStyle(
          color: AppColors.inputHintIcon,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC7D0EE), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC7D0EE), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.fieldFocusedBorder, width: 1.8),
        ),
      ),
    );
  }

  /// PREVIEW card with "AARAV MEHTA" and "Matches Aadhaar" badge
  Widget _buildPreviewCard(PanKycController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dashboardCardBorder, width: 1.0),
  
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PREVIEW',
            style: TextStyle(
              color: AppColors.textDarkSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          // Lavender preview box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF1FD),
              borderRadius: BorderRadius.circular(10),
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
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(
                      () => Text(
                        controller.nameAsPerPan.value,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),

                // Matches Aadhaar badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
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
                      fontSize: 10.5,
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
        height: 46,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFB8C2EC),
            width: 1.1,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.badge_outlined,
              color: AppColors.primaryPurple,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Upload PAN card instead',
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontSize: 13,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6DCF6), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, color: AppColors.primaryPurple, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulation: PAN matches Income Tax records?',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Toggle to test Verified vs Not Verified flows',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 10,
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
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: controller.verifyPan,
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
                'Verify PAN',
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
    );
  }
}
