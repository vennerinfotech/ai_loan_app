
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controller/forgot_mpin_controller.dart';
import '../theme/theme.dart';

/// Screen: Forgot MPIN
/// Allows users to recover/reset their MPIN via registered mobile number OTP.
/// Features top back button, clean key badge icon container (no animation),
/// clean mobile number input with no bottom dividers, security notice card,
/// "Send OTP →" CTA button, and "Back to login" link.
/// Pixel-perfect match to Figma reference design.
class ForgotMpinScreen extends StatelessWidget {
  final String? initialPhone;

  const ForgotMpinScreen({
    super.key,
    this.initialPhone,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotMpinController());

    if (initialPhone != null && initialPhone!.isNotEmpty) {
      String clean = initialPhone!.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.length > 10) {
        clean = clean.substring(clean.length - 10);
      }
      if (clean.length == 10 && controller.mobileNumber.value.isEmpty) {
        controller.mobileController.text = clean;
        controller.mobileNumber.value = clean;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Back Button Squircle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: GestureDetector(
                onTap: controller.backToLogin,
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
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // Golden Key Badge Container (simple clean container with key icon)
                    _buildKeyBadge(),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Forgot your MPIN?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle
                    const Text(
                      'No worries. Enter your registered mobile number and we\'ll send a code to reset it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textDarkSecondary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Registered Mobile Number Input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Registered mobile number',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // +91 | 98765 43210 Input Container (clean native TextFormField)
                        _buildMobileInputField(controller),
                        const SizedBox(height: 16),

                        // Security notice card
                        _buildSecurityNotice(),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Actions: "Send OTP →" + "Back to login"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSendOtpButton(controller),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: controller.backToLogin,
                    child: const Text(
                      'Back to login',
                      style: TextStyle(
                        color: AppColors.linkText,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Simple clean badge container with tilted golden key icon (no animation)
  Widget _buildKeyBadge() {
    return Container(
      width: 108,
      height: 108,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.key_outlined,
        color: AppColors.accentGold,
        size: 42,
      ),
    );
  }

  /// Mobile Number input field using native TextFormField directly (no wrapped container, no bottom divider)
  Widget _buildMobileInputField(ForgotMpinController controller) {
    return TextFormField(
      controller: controller.mobileController,
      onChanged: controller.onMobileChanged,
      keyboardType: TextInputType.phone,
      enableSuggestions: false,
      autocorrect: false,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      style: const TextStyle(
        color: AppColors.inputText,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        decoration: TextDecoration.none,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputBackground,
        hintText: '98765 43210',
        hintStyle: const TextStyle(
          color: AppColors.inputLabel,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          decoration: TextDecoration.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 16),
            const Text(
              '+91',
              style: TextStyle(
                color: AppColors.inputText,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Container(
              height: 24,
              width: 1.2,
              color: AppColors.inputBorder,
              margin: const EdgeInsets.symmetric(horizontal: 14),
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.fieldFocusedBorder,
            width: 1.8,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  /// Security notice box
  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.securityBoxBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 1.0),
            child: Icon(
              Icons.shield_outlined,
              color: AppColors.primaryPurple,
              size: 19,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your loan applications and documents stay safe — only the MPIN changes.',
              style: TextStyle(
                color: AppColors.securityText,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Send OTP →" Primary Action Button
  Widget _buildSendOtpButton(ForgotMpinController controller) {
    return Obx(() {
      final canSubmit = controller.canSubmit && !controller.isSendingOtp.value;
      final isSending = controller.isSendingOtp.value;

      return InkWell(
        onTap: canSubmit ? controller.sendOtp : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: canSubmit
                ? AppColors.primaryButtonBackground
                : AppColors.primaryButtonBackground.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: isSending
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Send OTP',
                      style: TextStyle(
                        color: AppColors.primaryButtonText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.accentGold,
                      size: 18,
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
