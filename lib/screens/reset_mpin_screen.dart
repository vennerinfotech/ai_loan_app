import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../controller/reset_mpin_controller.dart';
import '../theme/theme.dart';

/// Screen: Reset MPIN (Set New MPIN)
/// Navigated to after successful OTP verification in the Forgot MPIN flow.
/// Clean light theme with validation chips, numeric pad, and "Set MPIN" button.
class ResetMpinScreen extends StatelessWidget {
  final String? phoneNumber;

  const ResetMpinScreen({super.key, this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResetMpinController());
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      controller.setPhoneNumber(phoneNumber!);
    }

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
                    const SizedBox(height: 6),

                    // Lock icon badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.fieldUnfocusedBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.backButtonBorder,
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.primaryPurple,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    const Text(
                      'Set New MPIN',
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
                      'A 6-digit PIN for quick, secure sign-ins.',
                      style: TextStyle(
                        color: AppColors.textDarkSecondary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // New MPIN entry row
                    Obx(
                      () => _buildMpinFieldRow(
                        label: 'New MPIN',
                        pin: controller.newMpin.value,
                        isActive: controller.activeMpinField.value == 'new',
                        onTap: () => controller.selectMpinField('new'),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Confirm MPIN entry row
                    Obx(
                      () => _buildMpinFieldRow(
                        label: 'Confirm MPIN',
                        pin: controller.confirmMpin.value,
                        isActive: controller.activeMpinField.value == 'confirm',
                        onTap: () => controller.selectMpinField('confirm'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Validation rule chips
                    _buildValidationRules(controller),
                  ],
                ),
              ),
            ),

            // Light Keypad & Set MPIN button (fixed at bottom)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildLightKeypad(controller),
                  const SizedBox(height: 16),
                  _buildSetMpinButton(controller),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// MPIN row container displaying label on the left and 4 dots on the right
  Widget _buildMpinFieldRow({
    required String label,
    required String pin,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.fieldFocusedBackground
              : AppColors.fieldUnfocusedBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppColors.fieldFocusedBorder
                : AppColors.inputBorder,
            width: isActive ? 1.8 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            // 6 Indicator dots (13px diameter)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(6, (index) {
                final isFilled = index < pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled
                        ? AppColors.primaryButtonBackground
                        : Colors.transparent,
                    border: Border.all(
                      color: isFilled
                          ? AppColors.primaryButtonBackground
                          : AppColors.inputHintIcon.withValues(alpha: 0.5),
                      width: 1.8,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Validation criteria pills matching light theme styling
  Widget _buildValidationRules(ResetMpinController controller) {
    return Obx(() {
      final pin = controller.newMpin.value;
      final hasLength = controller.has6Digits;
      final noSeq = controller.hasNoSequence && pin.length >= 2;
      final noRep = controller.hasNoRepeats && pin.length >= 2;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildRuleChip(
                label: '6 digits',
                isValid: hasLength,
                isCheckmark: true,
              ),
              const SizedBox(width: 8),
              _buildRuleChip(
                label: 'No sequence (123456)',
                isValid: noSeq,
                isCheckmark: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRuleChip(
            label: 'No repeats (111111)',
            isValid: noRep,
            isCheckmark: false,
          ),
        ],
      );
    });
  }

  /// Single rule capsule in light theme
  Widget _buildRuleChip({
    required String label,
    required bool isValid,
    required bool isCheckmark,
  }) {
    final prefix = isCheckmark ? '✓ ' : '• ';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isValid ? AppColors.indigoTint : AppColors.canvas,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isValid
              ? AppColors.primaryPurple.withValues(alpha: 0.35)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Text(
        '$prefix$label',
        style: TextStyle(
          color: isValid
              ? AppColors.primaryPurple
              : AppColors.textDarkSecondary,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Light keypad matching Verify OTP and Create MPIN screens (3x4 grid)
  Widget _buildLightKeypad(ResetMpinController controller) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];

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
              controller.deleteMpinDigit();
            } else {
              controller.enterMpinDigit(key);
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
                  : Border.all(color: AppColors.numPadKeyBorder, width: 1),
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

  /// "Set MPIN" Primary button (deep navy with white text)
  Widget _buildSetMpinButton(ResetMpinController controller) {
    return Obx(() {
      final enabled = controller.canSetMpin;
      final isSubmitting = controller.isSubmitting.value;

      return InkWell(
        onTap: (enabled && !isSubmitting) ? controller.setMpin : null,
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
          child: isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              : Text(
                  'Set MPIN',
                  style: TextStyle(
                    color: enabled
                        ? AppColors.primaryButtonText
                        : AppColors.primaryButtonText.withValues(alpha: 0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      );
    });
  }
}
