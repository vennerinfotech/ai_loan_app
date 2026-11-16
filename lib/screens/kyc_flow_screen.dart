import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/kyc_flow_controller.dart';
import '../widgets/kyc_stepper.dart';

import 'aadhaar_verification_screen.dart';
import 'aadhaar_otp_screen.dart';
import 'aadhaar_not_linked_screen.dart';
import 'review_aadhaar_details_screen.dart';
import 'enter_pan_screen.dart';
import 'pan_not_verified_screen.dart';
import 'upload_pan_screen.dart';
import 'review_pan_details_screen.dart';
import 'kyc_next_step_placeholder_screen.dart';

/// Unified KYC Verification Screen with a permanently Sticky Top Header.
/// The top header (Back button, "KYC verification" title, Help squircle, and 3-step Stepper)
/// remains stationary at the top, while only the bottom content section transitions smoothly.
class KycFlowScreen extends StatelessWidget {
  final KycSubStep initialStep;

  const KycFlowScreen({
    super.key,
    this.initialStep = KycSubStep.aadhaarInput,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      KycFlowController(initialStep: initialStep),
      tag: 'kyc_flow_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Also register as default KycFlowController so child controllers can find it
    Get.replace<KycFlowController>(controller);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. PERMANENTLY STICKY TOP HEADER SECTION (Back, Title, Help, Stepper)
              Obx(
                () => KycHeaderWithStepper(
                  activeStep: controller.activeStepNumber,
                  onBack: controller.handleBack,
                ),
              ),
              const SizedBox(height: 8),

              // 2. DYNAMIC BOTTOM CONTENT SECTION (Only this section changes)
              Expanded(
                child: Obx(() {
                  switch (controller.currentSubStep.value) {
                    case KycSubStep.aadhaarInput:
                      return const AadhaarVerificationBody();
                    case KycSubStep.aadhaarOtp:
                      return const AadhaarOtpBody();
                    case KycSubStep.aadhaarNotLinked:
                      return const AadhaarNotLinkedBody();
                    case KycSubStep.aadhaarReview:
                      return const ReviewAadhaarDetailsBody();
                    case KycSubStep.panInput:
                      return const EnterPanBody();
                    case KycSubStep.panNotVerified:
                      return const PanNotVerifiedBody();
                    case KycSubStep.panUpload:
                      return const UploadPanBody();
                    case KycSubStep.panReview:
                      return const ReviewPanDetailsBody();
                    case KycSubStep.nextStepPlaceholder:
                      return KycNextStepPlaceholderBody(
                        targetFeature: controller.panController.targetFeature.value,
                      );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
