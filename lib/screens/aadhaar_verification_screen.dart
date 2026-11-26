import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/aadhaar_kyc_controller.dart';
import '../widgets/kyc_stepper.dart';

/// Screen 1 of Aadhaar KYC Flow: "Verify your Aadhaar" (Reference Image 2)
class AadhaarVerificationScreen extends StatelessWidget {
  const AadhaarVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: const [
            KycHeaderWithStepper(activeStep: 1),
            SizedBox(height: 12),
            Expanded(child: AadhaarVerificationBody()),
          ],
        ),
      ),
    );
  }
}

/// Content body of "Verify your Aadhaar" (used within sticky-header KYC flow)
class AadhaarVerificationBody extends StatelessWidget {
  const AadhaarVerificationBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AadhaarKycController>()
        ? Get.find<AadhaarKycController>()
        : Get.put(AadhaarKycController(), permanent: true);

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
                  'Verify your Aadhaar',
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
                  'We\'ll send an OTP to the mobile number linked with your Aadhaar.',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Aadhaar Number Input Label
                const Text(
                  'Aadhaar number',
                  style: TextStyle(
                    color: AppColors.inputLabel,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Aadhaar Number TextFormField
                _buildAadhaarInputField(controller),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Bottom Actions & Security Notice
        _buildBottomSection(controller),
      ],
    );
  }

  /// Aadhaar number input field with green checkmark when 12 digits are valid
  Widget _buildAadhaarInputField(AadhaarKycController controller) {
    return TextFormField(
      controller: controller.aadhaarController,
      onChanged: controller.onAadhaarChanged,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        color: AppColors.inputText,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: '4821 7730 1234',
        hintStyle: const TextStyle(
          color: AppColors.inputHintIcon,
          fontSize: 17,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.fieldFocusedBorder, width: 2.0),
        ),
        suffixIcon: Obx(() {
          if (controller.isAadhaarValid) {
            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.successGreenBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.successGreen.withValues(alpha: 0.45),
                      width: 1.2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: AppColors.successGreen,
                      size: 13,
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }

  /// Bottom section: Security notice + "Send OTP" button
  Widget _buildBottomSection(AadhaarKycController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
      child: Column(
        children: [
          // Security note
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, color: AppColors.successGreen, size: 15),
              SizedBox(width: 6),
              Text(
                'Bank-grade encryption • UIDAI compliant',
                style: TextStyle(
                  color: AppColors.successGreen,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Send OTP Button
          Obx(
            () {
              final isValid = controller.isAadhaarValid;

              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      isValid ? controller.initiateAadhaarVerification : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonBackground,
                    disabledBackgroundColor:
                        AppColors.navy.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Send OTP',
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
              );
            },
          ),
        ],
      ),
    );
  }
}
