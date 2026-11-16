import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../controller/registration_controller.dart';
import '../theme/theme.dart';

/// Step 1: Create Account form — Full name, Mobile number, Email,
/// referral code (optional), terms checkbox, and "Continue with OTP →" button.
/// Dynamic focus borders & backgrounds matching the Figma design.
class CreateAccountStep extends StatelessWidget {
  final RegistrationController controller;

  const CreateAccountStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Title
          const Text(
            "Let's get you\nstarted",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          const Text(
            "Takes under a minute. We'll verify your\nnumber next.",
            style: TextStyle(
              color: AppColors.textDarkSecondary,
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),

          // Full name label
          const Text(
            'Full name',
            style: TextStyle(
              color: AppColors.inputLabel,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Full name input with dynamic focus border
          _FocusableTextField(
            controller: controller.fullNameController,
            hintText: 'Aarav Mehta',
            prefixIcon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            onChanged: (val) => controller.fullName.value = val,
          ),
          const SizedBox(height: 20),

          // Mobile number label
          const Text(
            'Mobile number',
            style: TextStyle(
              color: AppColors.inputLabel,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Mobile number input with +91 prefix and digits-only number keyboard
          _MobileNumberField(
            controller: controller.mobileNumberController,
            onChanged: (val) => controller.mobileNumber.value = val,
          ),
          const SizedBox(height: 20),

          // Email (optional) label
          const Text(
            'Email (optional)',
            style: TextStyle(
              color: AppColors.inputLabel,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Email input with dynamic focus border
          _FocusableTextField(
            controller: controller.emailController,
            hintText: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) => controller.email.value = val,
          ),
          const SizedBox(height: 16),

          // Referral code row (Optional)
          _buildReferralRow(),
          const SizedBox(height: 16),

          // Terms checkbox
          _buildTermsCheckbox(),
          const SizedBox(height: 24),

          // Continue with OTP button
          Obx(() => _buildContinueButton(
                enabled: controller.isFormValid,
              )),
          const SizedBox(height: 16),

          // Already have an account? Sign in
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(
                      color: AppColors.linkText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// "Have a referral code?" container with gift icon and "Add" button
  Widget _buildReferralRow() {
    return Obx(() {
      if (controller.showReferralField.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.referralCardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.referralCardBorder,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.card_giftcard_rounded,
                    color: AppColors.referralIcon,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Referral code (optional)',
                      style: TextStyle(
                        color: AppColors.referralText,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.toggleReferralField,
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.inputLabel,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _FocusableTextField(
              controller: controller.referralCodeController,
              hintText: 'Enter referral code',
              prefixIcon: Icons.confirmation_number_outlined,
              onChanged: (val) => controller.referralCode.value = val,
            ),
          ],
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.referralCardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.referralCardBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.card_giftcard_rounded,
              color: AppColors.referralIcon,
              size: 20,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Have a referral code?',
                style: TextStyle(
                  color: AppColors.referralText,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: controller.toggleReferralField,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.referralAddButtonBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.referralAddButtonBorder,
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: AppColors.referralAddButtonText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Terms & conditions checkbox with linked text
  Widget _buildTermsCheckbox() {
    return Obx(() => GestureDetector(
          onTap: controller.toggleTerms,
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: controller.agreedToTerms.value
                      ? AppColors.checkboxActive
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: controller.agreedToTerms.value
                        ? AppColors.checkboxActive
                        : AppColors.inputBorder,
                    width: 1.5,
                  ),
                ),
                child: controller.agreedToTerms.value
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(
                          color: AppColors.textDarkSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                      TextSpan(
                        text: 'Terms & Privacy Policy',
                        style: const TextStyle(
                          color: AppColors.linkText,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const TextSpan(
                        text: ' and consent to KYC checks.',
                        style: TextStyle(
                          color: AppColors.textDarkSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  /// "Continue with OTP →" primary button matching Figma reference
  Widget _buildContinueButton({required bool enabled}) {
    return InkWell(
      onTap: enabled ? controller.submitForm : null,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primaryButtonBackground
              : AppColors.primaryButtonBackground.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Continue with OTP',
              style: TextStyle(
                color: enabled
                    ? AppColors.primaryButtonText
                    : AppColors.primaryButtonText.withValues(alpha: 0.7),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              color: enabled
                  ? AppColors.accentGold
                  : AppColors.accentGold.withValues(alpha: 0.7),
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}

/// Focusable text field directly using native TextFormField (no wrapped container)
class _FocusableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _FocusableTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppColors.inputText,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.fieldUnfocusedBackground,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.inputHintIcon,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.inputHintIcon,
          size: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.fieldFocusedBorder,
            width: 1.8,
          ),
        ),
      ),
    );
  }
}

/// Mobile number input field directly using native TextFormField (no wrapped container)
class _MobileNumberField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _MobileNumberField({
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 10,
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      style: const TextStyle(
        color: AppColors.inputText,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.fieldUnfocusedBackground,
        counterText: '',
        hintText: '98765 43210',
        hintStyle: const TextStyle(
          color: AppColors.inputHintIcon,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(width: 16),
            Text(
              '+91',
              style: TextStyle(
                color: AppColors.inputHintIcon,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 12),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.fieldFocusedBorder,
            width: 1.8,
          ),
        ),
      ),
    );
  }
}
