import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import 'kyc_help_bottom_sheet.dart';

/// Reusable KYC Top Bar & Stepper Indicator.
/// Matches reference screens (Images 2, 3, 4, 5):
/// - Back arrow in white squircle
/// - "KYC verification" center title
/// - Help `?` icon in white squircle
/// - 3-step pill bar: (1) Aadhaar, (2) PAN, (3) Docs / Credit
class KycHeaderWithStepper extends StatelessWidget {
  final int activeStep; // 1 = Aadhaar, 2 = PAN, 3 = Docs
  final VoidCallback? onBack;
  final VoidCallback? onHelp;

  const KycHeaderWithStepper({
    super.key,
    this.activeStep = 1,
    this.onBack,
    this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Bar Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button Squircle
              GestureDetector(
                onTap: onBack ?? () => Get.back(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.backButtonBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textDark,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Title
              const Text(
                'KYC verification',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),

              // Help / Info Button Squircle
              GestureDetector(
                onTap: onHelp ?? () => KycHelpBottomSheet.show(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.backButtonBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.help_outline_rounded,
                      color: AppColors.textDark,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Stepper Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Step 1: Aadhaar
              _buildStepPill(
                stepNumber: 1,
                label: 'Aadhaar',
                isActive: activeStep == 1,
                isDone: activeStep > 1,
              ),

              // Connector Line 1-2
              _buildConnector(isFilled: activeStep > 1),

              // Step 2: PAN
              _buildStepPill(
                stepNumber: 2,
                label: 'PAN',
                isActive: activeStep == 2,
                isDone: activeStep > 2,
              ),

              // Connector Line 2-3
              _buildConnector(isFilled: activeStep > 2),

              // Step 3: Credit
              _buildStepPill(
                stepNumber: 3,
                label: 'Credit',
                isActive: activeStep == 3,
                isDone: activeStep > 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepPill({
    required int stepNumber,
    required String label,
    required bool isActive,
    required bool isDone,
  }) {
    if (isActive) {
      // Active pill: Dark indigo container with yellow circular badge
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.kycStepperActivePill,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: AppColors.kycStepperActiveBadge,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(
                    color: AppColors.kycStepperActiveBadgeText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.kycStepperActivePillText,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    if (isDone) {
      // Completed pill: Light lime green with yellow checkmark badge (as seen in PAN reference images)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFE2F7D8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFFFBC14E),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.check_rounded, color: Color(0xFF212074), size: 12),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    // Inactive pill: White with subtle border and light purple circle
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.kycStepperInactivePill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.kycStepperInactivePillBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.kycStepperInactiveBadge,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  color: AppColors.kycStepperInactiveBadgeText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.kycStepperInactivePillText,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector({required bool isFilled}) {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isFilled ? AppColors.primaryPurple : AppColors.kycStepperLine,
    );
  }
}
