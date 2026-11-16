import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../controller/otp_verification_controller.dart';
import '../theme/theme.dart';

/// Screen: OTP Verification (Reusable for both "Forgot MPIN" & "Login with Mobile")
/// Pixel-perfect consistency with the app's OTP design:
/// 6-digit Pinput cells, custom number pad, resend countdown, security notice, and verify button.
class OtpVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  final OtpVerificationType type;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.type = OtpVerificationType.forgotMpin,
  });

  @override
  Widget build(BuildContext context) {
    // Unique controller tag per phone number to prevent state collisions
    final controller = Get.put(
      OtpVerificationController(
        phoneNumber: phoneNumber,
        type: type,
      ),
      tag: '${type.name}_$phoneNumber',
    );

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header: Back Button Squircle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.backButtonBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.backButtonBorder,
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.backButtonIcon,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable top portion
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Title
                    const Text(
                      'Enter the code',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle with masked phone & Edit link
                    Row(
                      children: [
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'We sent a 6-digit code to ',
                                  style: TextStyle(
                                    color: AppColors.textDarkSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: controller.maskedPhone,
                                  style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(text: ' '),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.linkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 6 OTP cells using Pinput package
                    _buildPinput(controller),
                    const SizedBox(height: 16),

                    // Resend timer row
                    _buildResendRow(controller),
                    const SizedBox(height: 20),

                    // Security notice inside tinted container
                    _buildSecurityNotice(),
                  ],
                ),
              ),
            ),

            // Number pad + Verify button (fixed at bottom)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildNumberPad(controller),
                  const SizedBox(height: 16),
                  _buildVerifyButton(controller),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 6 OTP input cells powered by the Pinput package
  Widget _buildPinput(OtpVerificationController controller) {
    // Default / Empty Pin Theme
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 54,
      textStyle: const TextStyle(
        color: AppColors.inputText,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: AppColors.otpEmptyBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.otpEmptyBorder,
          width: 1.2,
        ),
      ),
    );

    // Focused / Active Pin Theme
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.otpActiveBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.otpActiveBorder,
          width: 2.0,
        ),
      ),
    );

    // Submitted / Filled Pin Theme
    final submittedPinTheme = defaultPinTheme.copyWith(
      textStyle: const TextStyle(
        color: AppColors.otpFilledText,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: AppColors.otpFilledBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.otpFilledBackground,
          width: 1.2,
        ),
      ),
    );

    return Pinput(
      length: 6,
      controller: controller.otpController,
      focusNode: controller.otpFocusNode,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      followingPinTheme: defaultPinTheme,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      useNativeKeyboard: false,
      showCursor: true,
      onChanged: controller.onOtpChanged,
      cursor: Container(
        width: 2,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.otpActiveBorder,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
      onCompleted: (pin) => controller.verifyOtp(),
    );
  }

  /// Resend timer: clock icon + "Resend in 00:57" + "Resend code" link
  Widget _buildResendRow(OtpVerificationController controller) {
    return Obx(() => Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 16,
              color: AppColors.resendTimerText,
            ),
            const SizedBox(width: 6),
            const Text(
              'Resend in ',
              style: TextStyle(
                color: AppColors.resendTimerText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '00:${controller.resendCountdown.value.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: controller.canResend.value ? controller.resendCode : null,
              child: Text(
                'Resend code',
                style: TextStyle(
                  color: controller.canResend.value
                      ? AppColors.resendLinkText
                      : AppColors.resendTimerText.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ));
  }

  /// Security notice container
  Widget _buildSecurityNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.securityBoxBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.shield_outlined,
              size: 18,
              color: AppColors.securityIcon,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Never share your verification code with anyone. Finsphere AI will never call to ask for it.',
              style: TextStyle(
                color: AppColors.securityText,
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3x4 Custom keypad matching Figma design
  Widget _buildNumberPad(OtpVerificationController controller) {
    final keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '', '0', '⌫',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];

        if (key.isEmpty) {
          return const SizedBox.shrink();
        }

        final isBackspace = key == '⌫';

        return GestureDetector(
          onTap: () {
            if (isBackspace) {
              controller.deleteOtpDigit();
            } else {
              controller.enterOtpDigit(key);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isBackspace
                  ? AppColors.numPadActionKeyBackground
                  : AppColors.numPadKeyBackground,
              borderRadius: BorderRadius.circular(14),
              border: isBackspace
                  ? null
                  : Border.all(
                      color: AppColors.numPadKeyBorder,
                      width: 1,
                    ),
            ),
            alignment: Alignment.center,
            child: isBackspace
                ? const Icon(
                    Icons.backspace_outlined,
                    color: AppColors.numPadKeyText,
                    size: 22,
                  )
                : Text(
                    key,
                    style: const TextStyle(
                      color: AppColors.numPadKeyText,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// "Verify & continue" primary button
  Widget _buildVerifyButton(OtpVerificationController controller) {
    return Obx(() {
      final allFilled = controller.otpCode.value.length >= 6;
      final isVerifying = controller.isVerifying.value;

      return InkWell(
        onTap: (allFilled && !isVerifying) ? controller.verifyOtp : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: allFilled
                ? AppColors.primaryButtonBackground
                : AppColors.primaryButtonBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: isVerifying
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              : Text(
                  'Verify & continue',
                  style: TextStyle(
                    color: allFilled
                        ? AppColors.primaryButtonText
                        : AppColors.primaryButtonText.withValues(alpha: 0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
        ),
      );
    });
  }
}
