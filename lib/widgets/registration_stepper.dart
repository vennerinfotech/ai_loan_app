import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/theme.dart';

/// Clean top header widget for the registration flow.
/// Shows a white squircle back button, 3-step pill indicator, and step counter.
/// Exactly matches the Figma reference design.
class RegistrationStepper extends StatelessWidget {
  final RxInt currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  const RegistrationStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Back button squircle with subtle border
          GestureDetector(
            onTap: onBack,
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

          const Spacer(),

          // 3-step pill indicator
          Obx(() => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(totalSteps, (index) {
                  final isActive = index <= currentStep.value;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 22,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.stepperActive
                          : AppColors.stepperInactive,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  );
                }),
              )),

          const Spacer(),

          // Step counter "1/3"
          Obx(() => Text(
                '${currentStep.value + 1}/$totalSteps',
                style: const TextStyle(
                  color: AppColors.stepCounterText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )),
        ],
      ),
    );
  }
}
