import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../screens/upload_pan_screen.dart';
import '../screens/pan_not_verified_screen.dart';
import '../screens/review_pan_details_screen.dart';
import '../screens/kyc_next_step_placeholder_screen.dart';
import 'kyc_flow_controller.dart';

/// GetX Controller for PAN Card Verification flow.
/// Implements:
/// 1. Enter PAN manually or upload PAN directly
/// 2. Verification check:
///    - If verified: Navigate to Upload PAN Card Screen
///    - If not verified: Navigate to PAN Not Verified Screen
/// 3. Upload PAN via Camera / Gallery simulation
/// 4. Review PAN Details
/// 5. Submit with placeholder for next KYC step
class PanKycController extends GetxController {
  // Originally selected feature from Dashboard (e.g. 'Apply for loan')
  final targetFeature = 'Apply for loan'.obs;

  // PAN Input
  final panNumber = 'ABCDE1234F'.obs;
  final panController = TextEditingController(text: 'ABCDE1234F');

  // Branching toggle: is PAN verified with Income Tax records?
  // Defaults to true, can be toggled to test both branches
  final isPanVerified = true.obs;

  // Upload PAN Card state
  final isCardUploaded = false.obs;
  final uploadSource = ''.obs; // 'Camera' or 'Gallery'

  // Extracted PAN details (dummy data matching reference)
  final nameAsPerPan = 'AARAV MEHTA'.obs;
  final fathersName = 'RAJESH MEHTA'.obs;
  final dob = '15 Aug 1993'.obs;
  final matchesAadhaar = true.obs;

  // Overall PAN completion status
  final isPanCompleted = false.obs;

  /// PAN format validation: 5 uppercase letters, 4 numbers, 1 uppercase letter (10 chars)
  bool get isPanFormatValid {
    final clean = panNumber.value.trim().toUpperCase();
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(clean);
  }

  @override
  void onClose() {
    panController.dispose();
    super.onClose();
  }

  void setTargetFeature(String feature) {
    targetFeature.value = feature;
  }

  /// On PAN text field changed
  void onPanChanged(String val) {
    final upper = val.toUpperCase().replaceAll(RegExp(r'\s+'), '');
    final limited = upper.length > 10 ? upper.substring(0, 10) : upper;
    panNumber.value = limited;
    if (panController.text != limited) {
      panController.value = TextEditingValue(
        text: limited,
        selection: TextSelection.collapsed(offset: limited.length),
      );
    }
  }

  /// Verify PAN button action
  void verifyPan() {
    if (!isPanFormatValid) {
      Get.snackbar(
        'Invalid PAN Number',
        'Please enter a valid 10-character PAN (5 letters, 4 numbers, 1 letter).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (isPanVerified.value) {
      if (Get.isRegistered<KycFlowController>()) {
        Get.find<KycFlowController>().setStep(KycSubStep.panUpload);
      } else {
        Get.to(() => const UploadPanScreen());
      }
    } else {
      if (Get.isRegistered<KycFlowController>()) {
        Get.find<KycFlowController>().setStep(KycSubStep.panNotVerified);
      } else {
        Get.to(() => const PanNotVerifiedScreen());
      }
    }
  }

  /// Directly jump to upload PAN card instead of manual entry
  void uploadPanCardInstead() {
    if (Get.isRegistered<KycFlowController>()) {
      Get.find<KycFlowController>().setStep(KycSubStep.panUpload);
    } else {
      Get.to(() => const UploadPanScreen());
    }
  }

  /// Try again from PAN not verified screen
  void tryAgain() {
    if (Get.isRegistered<KycFlowController>()) {
      Get.find<KycFlowController>().setStep(KycSubStep.panInput);
    } else {
      Get.back();
    }
  }

  /// Cancel upload and return to enter PAN
  void cancelUpload() {
    if (Get.isRegistered<KycFlowController>()) {
      Get.find<KycFlowController>().setStep(KycSubStep.panInput);
    } else {
      Get.back();
    }
  }

  /// Simulate camera photo capture
  void takePhoto() {
    isCardUploaded.value = true;
    uploadSource.value = 'Camera';
    Get.snackbar(
      'Photo Captured',
      'PAN card photo captured successfully via camera.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF212074),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  /// Simulate gallery photo selection
  void pickFromGallery() {
    isCardUploaded.value = true;
    uploadSource.value = 'Gallery';
    Get.snackbar(
      'Image Selected',
      'PAN card image selected from device gallery.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF212074),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  /// Continue from upload screen to Review PAN Details screen
  void continueToReview() {
    if (!isCardUploaded.value) {
      // Auto-set dummy upload if user hasn't explicitly tapped camera/gallery for quick demo
      isCardUploaded.value = true;
      uploadSource.value = 'Camera';
    }
    if (Get.isRegistered<KycFlowController>()) {
      Get.find<KycFlowController>().setStep(KycSubStep.panReview);
    } else {
      Get.to(() => const ReviewPanDetailsScreen());
    }
  }

  /// Submit action from Review PAN Details screen
  void submitPanDetails() {
    isPanCompleted.value = true;

    if (Get.isRegistered<KycFlowController>()) {
      Get.find<KycFlowController>().setStep(KycSubStep.nextStepPlaceholder);
    } else {
      Get.to(() => KycNextStepPlaceholderScreen(targetFeature: targetFeature.value));
    }
  }

  /// Edit PAN details action
  void editDetails() {
    Get.snackbar(
      'Edit PAN Details',
      'If your name on PAN has typographical errors, you can re-upload or update via NSDL/UTI portal.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF524FBA),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}
