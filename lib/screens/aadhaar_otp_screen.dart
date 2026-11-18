import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../theme/app_colors.dart';
import '../controller/aadhaar_kyc_controller.dart';
import '../widgets/kyc_stepper.dart';

/// Screen 2 of Aadhaar KYC Flow: "Enter Aadhaar OTP" (Reference Image 3)
class AadhaarOtpScreen extends StatelessWidget {
  const AadhaarOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: const [
            KycHeaderWithStepper(activeStep: 1),
            SizedBox(height: 12),
            Expanded(child: AadhaarOtpBody()),
          ],
        ),
      ),
    );
  }
}

/// Content body of "Enter Aadhaar OTP" (used within sticky-header KYC flow)
class AadhaarOtpBody extends StatelessWidget {
  const AadhaarOtpBody({super.key});

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
                  'Enter Aadhaar OTP',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle with masked Aadhaar
                Obx(
                  () => RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppColors.textDarkSecondary,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(text: 'Sent by UIDAI to the mobile linked with Aadhaar '),
                        TextSpan(
                          text: controller.maskedAadhaarDisplay.value,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 6-digit Pinput
                _buildOtpPinput(controller),
                const SizedBox(height: 18),

                // Resend countdown & "Didn't get it?" link
                _buildResendRow(controller),
                const SizedBox(height: 28),

                // Info Card 1: Dark Indigo "Fastest way to verify"
                _buildFastestWayCard(),
                const SizedBox(height: 14),

                // Info Card 2: Light Purple "UIDAI privacy & biometrics notice"
                _buildPrivacyNoticeCard(),
              ],
            ),
          ),
        ),

        // Bottom Actions: Verify OTP Button
        _buildBottomSection(controller),
      ],
    );
  }

  /// 6-digit OTP Input using Pinput
  Widget _buildOtpPinput(AadhaarKycController controller) {
    // Default Empty Box Theme
    final defaultTheme = PinTheme(
      width: 48,
      height: 54,
      textStyle: const TextStyle(
        color: AppColors.inputText,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.line,
          width: 1.2,
        ),
      ),
    );

    // Active / Focused Box Theme
    final focusedTheme = defaultTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryPurple,
          width: 2.0,
        ),
      ),
    );

    // Filled Box Theme
    final submittedTheme = defaultTheme.copyWith(
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryButtonBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryButtonBackground,
          width: 1.2,
        ),
      ),
    );

    return Pinput(
      length: 6,
      controller: controller.otpController,
      focusNode: controller.otpFocusNode,
      defaultPinTheme: defaultTheme,
      focusedPinTheme: focusedTheme,
      submittedPinTheme: submittedTheme,
      followingPinTheme: defaultTheme,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      onChanged: controller.onOtpChanged,
      onCompleted: (pin) => controller.verifyOtp(),
    );
  }

  /// Resend countdown row
  Widget _buildResendRow(AadhaarKycController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
          () => Text(
            controller.canResend.value
                ? 'OTP expired'
                : 'Resend in 00:${controller.resendCountdown.value.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: AppColors.textDarkSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        GestureDetector(
          onTap: controller.resendOtp,
          child: const Text(
            'Didn\'t get it?',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  /// Dark indigo card: "Fastest way to verify"
  Widget _buildFastestWayCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradientDiagonal,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.speed_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fastest way to verify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'OTP e-KYC fills your details automatically — no photos needed.',
                  style: TextStyle(
                    color: AppColors.indigoTint,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Light purple card: "We only read name, DOB..."
  Widget _buildPrivacyNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.indigoTint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: AppColors.primaryPurple,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'We only read name, DOB, gender and address from UIDAI. Your biometrics are never accessed.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Verify OTP Button
  Widget _buildBottomSection(AadhaarKycController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: controller.isOtpValid ? controller.verifyOtp : null,
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
                  'Verify OTP',
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
      ),
    );
  }
}
