import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/pan_kyc_controller.dart';
import '../widgets/kyc_stepper.dart';

/// Screen 2 (Branch A): "We couldn't verify your PAN" (Reference Image 2)
class PanNotVerifiedScreen extends StatelessWidget {
  const PanNotVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: const [
            KycHeaderWithStepper(activeStep: 2),
            SizedBox(height: 12),
            Expanded(child: PanNotVerifiedBody()),
          ],
        ),
      ),
    );
  }
}

/// Content body of "PAN not verified" (used within sticky-header KYC flow)
class PanNotVerifiedBody extends StatelessWidget {
  const PanNotVerifiedBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PanKycController>();

    return Column(
      children: [
        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Red warning triangle icon in light peach squircle
                _buildWarningIconBadge(),
                const SizedBox(height: 24),

                // Main Heading
                const Text(
                  'We couldn\'t verify your PAN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle with bold PAN number
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Obx(
                    () => RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13.5,
                          height: 1.45,
                        ),
                        children: [
                          const TextSpan(text: 'The name on PAN '),
                          TextSpan(
                            text: controller.panNumber.value,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const TextSpan(text: ' didn\'t match the Income Tax records.'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // "Common fixes" Card
                _buildCommonFixesCard(),
              ],
            ),
          ),
        ),

        // Bottom Actions: "Try again" & "Upload PAN card"
        _buildBottomSection(controller),
      ],
    );
  }

  /// Warning badge: red triangle icon in light peach squircle container with soft border
  Widget _buildWarningIconBadge() {
    return Container(
      width: 114,
      height: 114,
      decoration: BoxDecoration(
        color: AppColors.panErrorCircleBg,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: AppColors.panErrorCircleBorder,
          width: 1.5,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.warning_amber_rounded,
          color: AppColors.panErrorIcon,
          size: 54,
        ),
      ),
    );
  }

  /// "Common fixes" white card with 3 checklist items
  Widget _buildCommonFixesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Common fixes',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),

          // 1: Re-check character
          _buildFixRow('Re-check each character (0 vs O, 1 vs I)'),
          const SizedBox(height: 14),

          // 2: PAN linked with Aadhaar
          _buildFixRow('Make sure PAN is linked with Aadhaar'),
          const SizedBox(height: 14),

          // 3: Upload card
          _buildFixRow('Upload the card if the problem continues'),
        ],
      ),
    );
  }

  Widget _buildFixRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_rounded,
          color: AppColors.primaryPurple,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom Buttons: "Try again" (Navy) & "Upload PAN card" (Light outlined with camera icon in primary color)
  Widget _buildBottomSection(PanKycController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
      child: Column(
        children: [
          // Primary "Try again" button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.tryAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButtonBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Try again',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary "Upload PAN card" button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: controller.uploadPanCardInstead,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.line, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.primaryPurple,
                    size: 19,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Upload PAN card',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
