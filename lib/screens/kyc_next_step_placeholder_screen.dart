import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import 'main_nav_screen.dart';
import '../widgets/kyc_stepper.dart';

/// Placeholder screen for the next KYC step (Step 3: Credit Profile / Docs).
class KycNextStepPlaceholderScreen extends StatelessWidget {
  final String targetFeature;

  const KycNextStepPlaceholderScreen({
    super.key,
    required this.targetFeature,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Stepper with Step 1 & 2 completed, Step 3 upcoming
            KycHeaderWithStepper(
              activeStep: 3,
              onBack: () => Get.offAll(() => const MainNavScreen()),
            ),
            const SizedBox(height: 12),
            Expanded(child: KycNextStepPlaceholderBody(targetFeature: targetFeature)),
          ],
        ),
      ),
    );
  }
}

/// Content body of Step 3 placeholder (used within sticky-header KYC flow)
class KycNextStepPlaceholderBody extends StatelessWidget {
  final String targetFeature;

  const KycNextStepPlaceholderBody({
    super.key,
    required this.targetFeature,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Verified Badge
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: AppColors.kycSuccessGreenBg,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.verified_user_rounded,
                color: AppColors.kycSuccessGreen,
                size: 46,
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'PAN Verification Complete!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),

          const Text(
            'Your PAN details have been verified against Income Tax Department records. 2 of 3 KYC steps completed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDarkSecondary,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),

          // Placeholder card for next step
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.dashboardCardBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF1FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.query_stats_rounded,
                          color: AppColors.primaryPurple,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step 3: Credit Assessment',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Next KYC step placeholder',
                            style: TextStyle(
                              color: AppColors.textDarkSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Up Next',
                        style: TextStyle(
                          color: Color(0xFFB45309),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Final step to check eligibility and finalize loan limits. Implementation will follow in the next release.',
                  style: TextStyle(
                    color: AppColors.textDarkSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Return to Dashboard Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Get.offAll(() => const MainNavScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Return to Dashboard',
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
