import 'package:get/get.dart';
import 'aadhaar_kyc_controller.dart';
import 'pan_kyc_controller.dart';

/// All sub-steps within the unified KYC Verification flow.
enum KycSubStep {
  // Step 1: Aadhaar
  aadhaarInput,
  aadhaarOtp,
  aadhaarNotLinked,
  aadhaarReview,

  // Step 2: PAN
  panInput,
  panNotVerified,
  panUpload,
  panReview,

  // Step 3: Next KYC Step / Credit
  nextStepPlaceholder,
}

/// Controller that coordinates sticky-header KYC flow.
/// The header (Back button, Title, Help, and Stepper) stays permanently sticky at the top,
/// while only the bottom content section transitions between sub-steps.
class KycFlowController extends GetxController {
  final KycSubStep initialStep;

  KycFlowController({this.initialStep = KycSubStep.aadhaarInput});

  late final Rx<KycSubStep> currentSubStep;
  final List<KycSubStep> history = [];

  // References to Aadhaar and PAN controllers
  AadhaarKycController get aadhaarController => Get.put(AadhaarKycController());
  PanKycController get panController => Get.put(PanKycController());

  @override
  void onInit() {
    super.onInit();
    currentSubStep = initialStep.obs;
    history.add(initialStep);
  }

  /// Determines the active step index for the top stepper (1 = Aadhaar, 2 = PAN, 3 = Credit)
  int get activeStepNumber {
    switch (currentSubStep.value) {
      case KycSubStep.aadhaarInput:
      case KycSubStep.aadhaarOtp:
      case KycSubStep.aadhaarNotLinked:
      case KycSubStep.aadhaarReview:
        return 1;
      case KycSubStep.panInput:
      case KycSubStep.panNotVerified:
      case KycSubStep.panUpload:
      case KycSubStep.panReview:
        return 2;
      case KycSubStep.nextStepPlaceholder:
        return 3;
    }
  }

  /// Transition to a new sub-step in the KYC flow
  void setStep(KycSubStep step) {
    if (currentSubStep.value != step) {
      history.add(step);
      currentSubStep.value = step;
    }
  }

  /// Handle back button tap (intelligent back history within KYC, or pop back to Dashboard)
  void handleBack() {
    if (history.length > 1) {
      history.removeLast();
      currentSubStep.value = history.last;
    } else {
      Get.back();
    }
  }
}
