import 'dart:async';
import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../screens/aadhaar_otp_screen.dart';
import '../screens/aadhaar_not_linked_screen.dart';
import '../screens/review_aadhaar_details_screen.dart';
import '../screens/enter_pan_screen.dart';
import 'pan_kyc_controller.dart';
import 'kyc_flow_controller.dart';
import '../widgets/image_picker_bottom_sheet.dart';

/// GetX controller for Aadhaar KYC Verification flow.
/// Implements full flow:
/// 1. Enter Aadhaar -> 2. Aadhaar OTP ->
/// 3. If mobile not linked: Not Linked Screen -> Manual upload
/// 4. If mobile linked: Review Aadhaar Details Screen -> Confirm & Continue
/// 5. Navigates to the originally selected feature.
class AadhaarKycController extends GetxController {
  // Originally selected dashboard feature
  final targetFeature = 'Apply for loan'.obs;

  // Step 1: Aadhaar Number
  final aadhaarNumber = ''.obs; // 12-digit raw
  final aadhaarController = TextEditingController();
  final frontUploaded = false.obs;
  final backUploaded = false.obs;
  final frontImagePath = ''.obs;
  final backImagePath = ''.obs;
  final frontImageBytes = Rxn<Uint8List>();
  final backImageBytes = Rxn<Uint8List>();

  // Step 2: Aadhaar OTP
  final otpCode = ''.obs;
  final otpController = TextEditingController();
  final otpFocusNode = FocusNode();
  final resendCountdown = 43.obs;
  final canResend = false.obs;
  Timer? _resendTimer;

  // Branching condition: Is mobile linked to Aadhaar?
  // Defaults to true, can be toggled to test both branches
  final isMobileLinked = true.obs;

  // Step 3: Review Details confirmation checkbox
  final isConfirmChecked = true.obs;

  // Global KYC state
  final isAadhaarVerified = false.obs;

  // Dummy Aadhaar User Details from UIDAI
  final userName = 'Aarav Mehta'.obs;
  final userInitials = 'AM'.obs;
  final maskedAadhaarDisplay = 'XXXX XXXX 1234'.obs;
  final dob = '15 Aug 1993'.obs;
  final gender = 'Male'.obs;
  final address = '123, MG Road, Bengaluru, Karnataka – 560001'.obs;
  final linkedMobile = '+91 98765 •••10'.obs;

  bool get isAadhaarValid => aadhaarNumber.value.length == 12;
  bool get isOtpValid => otpCode.value.length == 6;

  @override
  void onInit() {
    super.onInit();
    // Default pre-filled 12-digit Aadhaar for smooth demo as shown in reference: 4821 7730 1234
    aadhaarNumber.value = '482177301234';
    aadhaarController.text = '4821 7730 1234';
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    aadhaarController.dispose();
    otpController.dispose();
    otpFocusNode.dispose();
    super.onClose();
  }

  /// Sets the destination feature that triggered KYC
  void setTargetFeature(String feature) {
    targetFeature.value = feature;
  }

  /// Format Aadhaar number with spaces: "4821 7730 1234"
  void onAadhaarChanged(String val) {
    final digitsOnly = val.replaceAll(RegExp(r'\D'), '');
    final limited = digitsOnly.length > 12 ? digitsOnly.substring(0, 12) : digitsOnly;
    aadhaarNumber.value = limited;

    // Format with spaces
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();
    if (aadhaarController.text != formatted) {
      aadhaarController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  /// Pick Aadhaar document (Front or Back) using camera or gallery via ImagePickerBottomSheet
  Future<void> pickAadhaarDocument({
    required bool isFront,
    BuildContext? context,
  }) async {
    final file = await ImagePickerBottomSheet.show(
      context: context,
      title: isFront ? 'Upload Aadhaar (Front Side)' : 'Upload Aadhaar (Back Side)',
      subtitle: 'Take a photo or choose an image from gallery',
    );

    if (file != null) {
      final bytes = await file.readAsBytes();
      if (isFront) {
        frontUploaded.value = true;
        frontImagePath.value = file.path;
        frontImageBytes.value = bytes;
      } else {
        backUploaded.value = true;
        backImagePath.value = file.path;
        backImageBytes.value = bytes;
      }

      Get.snackbar(
        isFront ? 'Front Side Uploaded' : 'Back Side Uploaded',
        'Document selected: ${file.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF212074),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Remove uploaded Aadhaar document
  void removeAadhaarDocument({required bool isFront}) {
    if (isFront) {
      frontUploaded.value = false;
      frontImagePath.value = '';
      frontImageBytes.value = null;
    } else {
      backUploaded.value = false;
      backImagePath.value = '';
      backImageBytes.value = null;
    }
  }

  /// Send OTP to registered mobile number
  void sendOtp() {
    if (!isAadhaarValid) {
      Get.snackbar(
        'Invalid Aadhaar',
        'Please enter a valid 12-digit Aadhaar number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    startResendTimer();
    if (Get.isRegistered<KycFlowController>()) {
      Get.find<KycFlowController>().setStep(KycSubStep.aadhaarOtp);
    } else {
      Get.to(() => const AadhaarOtpScreen());
    }
  }

  void startResendTimer() {
    resendCountdown.value = 43;
    canResend.value = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void onOtpChanged(String val) {
    otpCode.value = val;
  }

  void resendOtp() {
    if (!canResend.value) return;
    startResendTimer();
    Get.snackbar(
      'OTP Sent',
      'A new Aadhaar OTP has been sent by UIDAI to mobile linked with $maskedAadhaarDisplay.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF212074),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  /// Verify OTP and branch based on whether mobile is linked
  void verifyOtp() {
    if (!isOtpValid) {
      Get.snackbar(
        'Incomplete OTP',
        'Please enter the 6-digit Aadhaar OTP.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (Get.isRegistered<KycFlowController>()) {
      Get.find<KycFlowController>().setStep(
        isMobileLinked.value ? KycSubStep.aadhaarReview : KycSubStep.aadhaarNotLinked,
      );
    } else {
      if (isMobileLinked.value) {
        Get.to(() => const ReviewAadhaarDetailsScreen());
      } else {
        Get.to(() => const AadhaarNotLinkedScreen());
      }
    }
  }

  /// Called from AadhaarNotLinkedScreen when user taps "Upload Aadhaar instead"
  Future<void> uploadAadhaarManually({BuildContext? context}) async {
    final file = await ImagePickerBottomSheet.show(
      context: context,
      title: 'Upload Aadhaar Card',
      subtitle: 'Take a photo or choose your Aadhaar image',
    );

    if (file != null) {
      final bytes = await file.readAsBytes();
      frontUploaded.value = true;
      frontImagePath.value = file.path;
      frontImageBytes.value = bytes;

      Get.snackbar(
        'Aadhaar Uploaded',
        'Document submitted: ${file.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF212074),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );

      if (Get.isRegistered<KycFlowController>()) {
        Get.find<KycFlowController>().setStep(KycSubStep.aadhaarReview);
      } else {
        Get.to(() => const ReviewAadhaarDetailsScreen());
      }
    }
  }

  /// Confirm & continue after reviewing Aadhaar details
  void confirmAndContinue() {
    if (!isConfirmChecked.value) {
      Get.snackbar(
        'Confirmation Required',
        'Please confirm that these Aadhaar details are correct and belong to you.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isAadhaarVerified.value = true;

    final panController = Get.put(PanKycController());
    panController.setTargetFeature(targetFeature.value);

    if (Get.isRegistered<KycFlowController>()) {
      Get.find<KycFlowController>().setStep(KycSubStep.panInput);
    } else {
      Get.to(() => const EnterPanScreen());
    }
  }

  /// Edit details action
  void editDetails() {
    Get.snackbar(
      'Edit Details',
      'You can update your communication address in application form.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF524FBA),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}
