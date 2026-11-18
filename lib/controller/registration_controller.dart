import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../models/registration_step.dart';
import '../models/register_response_model.dart';
import '../models/verify_otp_response_model.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
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
  // API State & Response
  // ==========================================
  final isLoading = false.obs;
  final registerResponse = Rxn<RegisterResponseModel>();
  final isVerifyingOtp = false.obs;
  final verifyOtpResponse = Rxn<VerifyOtpResponseModel>();
  final authToken = ''.obs;

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
  TextEditingController fullNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController referralCodeController = TextEditingController();

  // ==========================================
  // OTP Verification
  // ==========================================
  TextEditingController otpController = TextEditingController();
  FocusNode otpFocusNode = FocusNode();
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

  /// Submit Form: Calls POST /register API and transitions to OTP step
  Future<void> submitForm() async {
    if (fullName.value.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter your full name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
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
        backgroundColor: AppColors.navy,
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
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      isLoading.value = true;
      final Map<String, dynamic> response = await ApiService.register(
        name: fullName.value.trim(),
        phone: mobileNumber.value.trim(),
        email: email.value.trim(),
        referenceCode: referralCode.value.trim(),
      );

      isLoading.value = false;

      final statusCode = response['status_code'];
      final isSuccess =
          response['success'] == true || statusCode == 200 || statusCode == 201;

      if (isSuccess) {
        // Store data in model class
        final model = RegisterResponseModel.fromJson(response);
        registerResponse.value = model;

        // Update mobile number if returned by API
        if (model.data?.phone != null && model.data!.phone!.isNotEmpty) {
          mobileNumber.value = model.data!.phone!;
        }

        // Auto-fill OTP from response for testing
        if (model.data?.otp != null) {
          final otp = model.data!.otp.toString();
          otpController.value = TextEditingValue(
            text: otp,
            selection: TextSelection.collapsed(offset: otp.length),
          );
          otpCode.value = otp;
          debugPrint('Auto-filled OTP: $otp');
        }

        Get.snackbar(
          'Success',
          model.message.isNotEmpty
              ? model.message
              : 'Registration successful. OTP sent to mobile.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );

        // Move to OTP step
        currentStep.value = 1;
        _startResendTimer();
      } else {
        final errorMsg =
            response['message']?.toString() ?? 'Registration failed';
        debugPrint('Registration Error: $errorMsg');
        Get.snackbar(
          'Registration Failed',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('Registration Exception: $e');
      Get.snackbar(
        'Error',
        'Failed to connect to server: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
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

  /// Verify OTP API: calls POST /verify-otp with phone and otp
  Future<void> verifyOtp() async {
    final enteredOtp = otpCode.value.trim();
    if (enteredOtp.length < 6) {
      Get.snackbar(
        'Incomplete OTP',
        'Please enter the complete 6-digit OTP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      isVerifyingOtp.value = true;
      final phone = mobileNumber.value.trim();

      final Map<String, dynamic> response = await ApiService.verifyOtp(
        phone: phone,
        otp: enteredOtp,
      );

      isVerifyingOtp.value = false;

      final statusCode = response['status_code'];
      final isSuccess =
          response['success'] == true || statusCode == 200 || statusCode == 201;

      if (isSuccess) {
        // Store data in model class
        final model = VerifyOtpResponseModel.fromJson(response);
        verifyOtpResponse.value = model;

        if (model.data?.token != null && model.data!.token!.isNotEmpty) {
          authToken.value = model.data!.token!;
          // Save session
          await SessionManager.saveLoginSession(
            phone: model.data?.user?.phone ?? phone,
            name: model.data?.user?.name ?? fullName.value,
          );
        }

        Get.snackbar(
          'Success',
          model.message.isNotEmpty
              ? model.message
              : 'OTP verified successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );

        // Advance to Step 3 (Create MPIN)
        currentStep.value = 2;
      } else {
        final errorMsg =
            response['message']?.toString() ?? 'OTP verification failed';
        debugPrint('Verify OTP Error: $errorMsg');
        Get.snackbar(
          'Verification Failed',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      isVerifyingOtp.value = false;
      debugPrint('Verify OTP Exception: $e');
      Get.snackbar(
        'Error',
        'Failed to verify OTP: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
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
