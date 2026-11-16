import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../models/registration_step.dart';
import '../screens/login_with_mpin_screen.dart';

/// GetX controller for Create Account + OTP Verify registration flow.
class RegistrationController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController mpinOrbitAnimation;

  // ==========================================
  // Step Management
  // ==========================================
  final RxInt currentStep = 0.obs; // 0 = Create Account, 1 = Verify OTP, 2 = (future step)
  static const int totalSteps = 3;

  final List<RegistrationStep> steps = const [
    RegistrationStep(index: 0, title: 'Create Account'),
    RegistrationStep(index: 1, title: 'Verify OTP'),
    RegistrationStep(index: 2, title: 'Create MPIN'),
  ];

  // ==========================================
  // Create Account - Form Fields
  // ==========================================
  final fullName = ''.obs;
  final mobileNumber = ''.obs;
  final email = ''.obs;
  final referralCode = ''.obs;
  final agreedToTerms = false.obs;
  final showReferralField = false.obs;

  // Text controllers for input fields
  final fullNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final emailController = TextEditingController();
  final referralCodeController = TextEditingController();

  // ==========================================
  // OTP Verification
  // ==========================================
  final otpController = TextEditingController();
  final otpFocusNode = FocusNode();
  final otpCode = ''.obs;
  final resendCountdown = 57.obs;
  final canResend = false.obs;
  Timer? _resendTimer;

  /// Masked phone number for OTP screen display
  String get maskedPhone {
    final phone = mobileNumber.value;
    if (phone.length >= 10) {
      return '+91 ${phone.substring(0, 5)} ••••${phone.substring(phone.length - 2)}';
    }
    return '+91 $phone';
  }

  /// Whether the Create Account form is valid (referral code is optional)
  bool get isFormValid {
    return fullName.value.trim().isNotEmpty &&
        mobileNumber.value.trim().length == 10 &&
        agreedToTerms.value;
  }

  // ==========================================
  // Lifecycle
  // ==========================================
  @override
  void onInit() {
    super.onInit();
    // Continuous loop animation for cosmic orbit pattern (matched with onboarding & login screens)
    mpinOrbitAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void onClose() {
    mpinOrbitAnimation.dispose();
    fullNameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    referralCodeController.dispose();
    otpController.dispose();
    otpFocusNode.dispose();
    _resendTimer?.cancel();
    super.onClose();
  }

  // ==========================================
  // Step Navigation
  // ==========================================
  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      currentStep.value = step;
    }
  }

  void goBack() {
    if (currentStep.value > 0) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  // ==========================================
  // Create Account Actions
  // ==========================================
  void toggleReferralField() {
    showReferralField.value = !showReferralField.value;
  }

  void toggleTerms() {
    agreedToTerms.value = !agreedToTerms.value;
  }

  void submitForm() {
    if (fullName.value.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter your full name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E2127),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }
    if (mobileNumber.value.trim().length != 10) {
      Get.snackbar(
        'Invalid Mobile',
        'Please enter a valid 10-digit mobile number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E2127),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }
    if (!agreedToTerms.value) {
      Get.snackbar(
        'Terms Required',
        'Please agree to the Terms & Privacy Policy to continue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E2127),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }
    // Move to OTP step
    currentStep.value = 1;
    _startResendTimer();
  }

  // ==========================================
  // OTP Actions
  // ==========================================
  void onOtpChanged(String val) {
    otpCode.value = val;
  }

  void enterOtpDigit(String digit) {
    if (otpController.text.length < 6) {
      otpController.text += digit;
      otpCode.value = otpController.text;
    }
  }

  void deleteOtpDigit() {
    if (otpController.text.isNotEmpty) {
      otpController.text =
          otpController.text.substring(0, otpController.text.length - 1);
      otpCode.value = otpController.text;
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    resendCountdown.value = 57;
    canResend.value = false;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void resendOtp() {
    if (!canResend.value) return;
    otpController.clear();
    _startResendTimer();
  }

  void verifyOtp() {
    if (otpController.text.length < 6) return;
    // Advance to step 3 (Create MPIN)
    currentStep.value = 2;
  }

  // ==========================================
  // Step 3: Create MPIN Actions & Validation
  // ==========================================
  final newMpin = ''.obs;
  final confirmMpin = ''.obs;
  final activeMpinField = 'new'.obs; // 'new' or 'confirm'

  bool get has4Digits => newMpin.value.length == 4;

  bool get hasNoSequence {
    final pin = newMpin.value;
    if (pin.length < 2) return true;
    const sequences = [
      '0123', '1234', '2345', '3456', '4567', '5678', '6789',
      '3210', '4321', '5432', '6543', '7654', '8765', '9876',
    ];
    for (final seq in sequences) {
      if (pin == seq) return false;
    }
    return true;
  }

  bool get hasNoRepeats {
    final pin = newMpin.value;
    if (pin.length < 2) return true;
    if (pin.length == 4 &&
        pin[0] == pin[1] &&
        pin[1] == pin[2] &&
        pin[2] == pin[3]) {
      return false;
    }
    return true;
  }

  bool get isMpinValid => has4Digits && hasNoSequence && hasNoRepeats;
  bool get isMpinConfirmed =>
      confirmMpin.value.length == 4 && confirmMpin.value == newMpin.value;
  bool get canSetMpin => isMpinValid && isMpinConfirmed;

  void selectMpinField(String field) {
    activeMpinField.value = field;
  }

  void enterMpinDigit(String digit) {
    if (activeMpinField.value == 'new') {
      if (newMpin.value.length < 4) {
        newMpin.value += digit;
        if (newMpin.value.length == 4) {
          activeMpinField.value = 'confirm';
        }
      }
    } else {
      if (confirmMpin.value.length < 4) {
        confirmMpin.value += digit;
      }
    }
  }

  void deleteMpinDigit() {
    if (activeMpinField.value == 'confirm') {
      if (confirmMpin.value.isNotEmpty) {
        confirmMpin.value =
            confirmMpin.value.substring(0, confirmMpin.value.length - 1);
      } else {
        activeMpinField.value = 'new';
      }
    } else {
      if (newMpin.value.isNotEmpty) {
        newMpin.value = newMpin.value.substring(0, newMpin.value.length - 1);
      }
    }
  }

  void setMpin() {
    if (!canSetMpin) return;
    Get.offAll(() => const LoginWithMpinScreen());
  }

  /// Format countdown seconds to MM:SS
  String get formattedCountdown {
    final mins = (resendCountdown.value ~/ 60).toString().padLeft(2, '0');
    final secs = (resendCountdown.value % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}
