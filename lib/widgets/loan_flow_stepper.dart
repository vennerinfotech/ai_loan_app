import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

/// Header stepper matching the exact reference image:
/// - Left: White rounded squircle with '<' back arrow
/// - Center: Segmented pill dashes progress indicator (▬ ▬ ▬ ▬)
/// - Right: 'X/4' step indicator
class LoanFlowHeaderWithStepper extends StatelessWidget {
  final int activeStep; // 1, 2, 3, or 4
  final int totalSteps; // 4
  final VoidCallback? onBack;

  const LoanFlowHeaderWithStepper({
    super.key,
    required this.activeStep,
    this.totalSteps = 4,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Back button in rounded white squircle
          GestureDetector(
            onTap: onBack ?? () => Get.back(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.line,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),

          // Center: Segmented horizontal pill dashes (▬ ▬ ▬ ▬)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalSteps, (index) {
              final isActive = index < activeStep;
              return Container(
                width: 20,
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.indigo
                      : AppColors.line,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),

          // Right: "X/4" text (e.g. 1/4, 2/4, 3/4, 4/4)
          Text(
            '$activeStep/$totalSteps',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
