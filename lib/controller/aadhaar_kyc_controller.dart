import 'dart:async';
import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../screens/aadhaar_otp_screen.dart';
import '../screens/aadhaar_not_linked_screen.dart';
import '../screens/review_aadhaar_details_screen.dart';
import '../screens/enter_pan_screen.dart';
import 'pan_kyc_controller.dart';
import 'kyc_flow_controller.dart';
import '../widgets/image_picker_bottom_sheet.dart';
import '../models/aadhaar_kyc_model.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';

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
  TextEditingController aadhaarController = TextEditingController();
  final frontUploaded = false.obs;
  final backUploaded = false.obs;
  final frontImagePath = ''.obs;
  final backImagePath = ''.obs;
  final frontImageBytes = Rxn<Uint8List>();
  final backImageBytes = Rxn<Uint8List>();

  // API State
  final isSendingOtp = false.obs;
  final documentId = RxnInt();
  final otpExpiresAt = ''.obs;
  final isUploadingFront = false.obs;
  final isUploadingBack = false.obs;
  final frontUploadedFilename = ''.obs;
  final backUploadedFilename = ''.obs;
  final isVerifyingOtp = false.obs;
  final isResendingOtp = false.obs;
  final isUpdatingStep = false.obs;
  final isDownloadingReceipt = false.obs;
  final aadhaarKycData = Rxn<AadhaarKycModel>();
  final receiptUser = Rxn<Map<String, dynamic>>();

  // Step 2: Aadhaar OTP
  final otpCode = ''.obs;
  TextEditingController otpController = TextEditingController();
  FocusNode otpFocusNode = FocusNode();
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

  // Dynamic Aadhaar User Details from UIDAI (starts empty, populated dynamically from API)
  final userName = ''.obs;
  final userInitials = ''.obs;
  final maskedAadhaarDisplay = ''.obs;
  final dob = ''.obs;
  final gender = ''.obs;
  final address = ''.obs;
  final linkedMobile = ''.obs;

  bool get isAadhaarValid => aadhaarNumber.value.length == 12;
  bool get isOtpValid => otpCode.value.length == 6;

  @override
  void onInit() {
    super.onInit();
    _loadInitialUserData();
  }

  /// Initialize user details from SessionManager if available
  Future<void> _loadInitialUserData() async {
    try {
      final savedName = await SessionManager.getUserName();
      final savedPhone = await SessionManager.getUserPhone();
      if (userName.value.isEmpty && savedName.isNotEmpty) {
        userName.value = savedName;
        _updateInitials(savedName);
      }
      if (linkedMobile.value.isEmpty && savedPhone.isNotEmpty) {
        linkedMobile.value = savedPhone.startsWith('+91') ? savedPhone : '+91 $savedPhone';
      }
    } catch (e) {
      debugPrint('Error loading initial user data: $e');
    }
  }

  void _updateInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      userInitials.value = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      userInitials.value = parts[0][0].toUpperCase();
    }
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
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

    // Dynamically update masked display
    if (limited.length == 12) {
      maskedAadhaarDisplay.value = 'XXXX XXXX ${limited.substring(8)}';
    } else if (limited.isNotEmpty) {
      maskedAadhaarDisplay.value = 'XXXX XXXX XXXX';
    }

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
  /// and automatically uploads it via POST /upload-aadhaar
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
        frontImagePath.value = file.path;
        frontImageBytes.value = bytes;
        isUploadingFront.value = true;
      } else {
        backImagePath.value = file.path;
        backImageBytes.value = bytes;
        isUploadingBack.value = true;
      }

      try {
        final response = await ApiService.uploadAadhaar(
          filePath: file.path,
          fileBytes: bytes,
          filename: file.name,
        );

        if (isFront) {
          isUploadingFront.value = false;
        } else {
          isUploadingBack.value = false;
        }

        final isSuccess = response['success'] == true ||
            response['status_code'] == 200 ||
            response['status_code'] == 201;

        if (isSuccess) {
          final model = response['data'] != null && response['data'] is Map
              ? AadhaarKycModel.fromJson(Map<String, dynamic>.from(response['data']))
              : null;
          final filename = model?.filename ?? file.name;
          if (isFront) {
            frontUploaded.value = true;
            frontUploadedFilename.value = filename;
          } else {
            backUploaded.value = true;
            backUploadedFilename.value = filename;
          }

          Get.snackbar(
            isFront ? 'Front Side Uploaded' : 'Back Side Uploaded',
            response['message']?.toString() ??
                'Aadhaar document uploaded successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.navy,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          );
        } else {
          final errorMsg = ApiService.getErrorMessage(response);
          Get.snackbar(
            'Upload Failed',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade800,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        if (isFront) {
          isUploadingFront.value = false;
        } else {
          isUploadingBack.value = false;
        }
        debugPrint('uploadAadhaar exception: $e');
        Get.snackbar(
          'Upload Error',
          'Failed to upload Aadhaar: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
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

  /// Send OTP to registered mobile number via POST /store-aadhaar
  /// Also ensures any selected documents are uploaded via POST /upload-aadhaar
  Future<void> sendOtp() async {
    if (!isAadhaarValid || isSendingOtp.value) {
      if (!isAadhaarValid) {
        Get.snackbar(
          'Invalid Aadhaar',
          'Please enter a valid 12-digit Aadhaar number.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
      return;
    }

    try {
      isSendingOtp.value = true;

      // 1. If front document was selected but upload hasn't completed, upload it
      if (frontImagePath.value.isNotEmpty && !frontUploaded.value) {
        final frontRes = await ApiService.uploadAadhaar(
          filePath: frontImagePath.value,
          fileBytes: frontImageBytes.value,
        );
        if (frontRes['success'] == true || frontRes['status_code'] == 201) {
          frontUploaded.value = true;
          frontUploadedFilename.value =
              frontRes['data']?['filename']?.toString() ?? '';
        }
      }

      // 2. If back document was selected but upload hasn't completed, upload it
      if (backImagePath.value.isNotEmpty && !backUploaded.value) {
        final backRes = await ApiService.uploadAadhaar(
          filePath: backImagePath.value,
          fileBytes: backImageBytes.value,
        );
        if (backRes['success'] == true || backRes['status_code'] == 201) {
          backUploaded.value = true;
          backUploadedFilename.value =
              backRes['data']?['filename']?.toString() ?? '';
        }
      }

      // 3. Store Aadhaar number and send OTP
      final response = await ApiService.storeAadhaar(
        aadhaarNumber: aadhaarNumber.value,
      );
      isSendingOtp.value = false;

      final isSuccess = response['success'] == true ||
          response['status_code'] == 200 ||
          response['status_code'] == 201;

      if (isSuccess) {
        if (response['data'] != null && response['data'] is Map) {
          final model = AadhaarKycModel.fromJson(Map<String, dynamic>.from(response['data']));
          aadhaarKycData.value = model;

          if (model.documentId != null) {
            documentId.value = model.documentId;
          }
          if (model.expiresAt != null) {
            otpExpiresAt.value = model.expiresAt!;
          }

          final testOtp = model.otp?.toString();
          if (testOtp != null && testOtp.isNotEmpty) {
            otpCode.value = testOtp;
            otpController.value = TextEditingValue(
              text: testOtp,
              selection: TextSelection.collapsed(offset: testOtp.length),
            );
            debugPrint('Auto-filled test Aadhaar OTP: $testOtp');
          }
        }

        Get.snackbar(
          'OTP Sent',
          response['message']?.toString() ??
              'Aadhaar OTP sent for verification.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );

        startResendTimer();
        if (Get.isRegistered<KycFlowController>()) {
          Get.find<KycFlowController>().setStep(KycSubStep.aadhaarOtp);
        } else {
          Get.to(() => const AadhaarOtpScreen());
        }
      } else {
        final errorMsg = ApiService.getErrorMessage(response);
        debugPrint('Store Aadhaar Error: $errorMsg');
        Get.snackbar(
          'Submission Failed',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      isSendingOtp.value = false;
      debugPrint('Store Aadhaar Exception: $e');
      Get.snackbar(
        'Error',
        'Failed to store Aadhaar: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
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

  Future<void> resendOtp() async {
    if (isResendingOtp.value) return;
    isResendingOtp.value = true;

    try {
      final response = await ApiService.resendAadhaarOtp(
        documentId: documentId.value,
      );
      isResendingOtp.value = false;

      final isSuccess = response['success'] == true ||
          response['status_code'] == 200 ||
          response['status_code'] == 201;

      if (isSuccess) {
        if (response['data'] != null && response['data'] is Map) {
          final model = AadhaarKycModel.fromJson(Map<String, dynamic>.from(response['data']));
          aadhaarKycData.value = model;

          if (model.documentId != null) {
            documentId.value = model.documentId;
          }
          if (model.expiresAt != null) {
            otpExpiresAt.value = model.expiresAt!;
          }
          if (model.otp != null) {
            final testOtp = model.otp.toString();
            otpController.text = testOtp;
            otpCode.value = testOtp;
          }
        }

        startResendTimer();
        Get.snackbar(
          'OTP Sent',
          response['message']?.toString() ??
              'A new Aadhaar OTP has been sent by UIDAI to mobile linked with ${maskedAadhaarDisplay.value}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      } else {
        final errorMsg = ApiService.getErrorMessage(response);
        Get.snackbar(
          'Failed to Resend',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      isResendingOtp.value = false;
      debugPrint('resendAadhaarOtp exception: $e');
      Get.snackbar(
        'Error',
        'Failed to resend Aadhaar OTP: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Verify OTP and branch based on whether mobile is linked
  Future<void> verifyOtp() async {
    if (!isOtpValid) {
      Get.snackbar(
        'Incomplete OTP',
        'Please enter the 6-digit Aadhaar OTP.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorRed,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (isVerifyingOtp.value) return;
    isVerifyingOtp.value = true;

    try {
      final response = await ApiService.verifyAadhaarOtp(
        otp: otpCode.value.trim(),
        documentId: documentId.value ?? 1,
      );
      isVerifyingOtp.value = false;

      final isSuccess = response['success'] == true ||
          response['status_code'] == 200 ||
          response['status_code'] == 201;

      if (isSuccess) {
        if (response['data'] != null && response['data'] is Map) {
          final model = AadhaarKycModel.fromJson(Map<String, dynamic>.from(response['data']));
          aadhaarKycData.value = model;
          if (model.documentId != null) {
            documentId.value = model.documentId;
          }
        }

        // Fetch verified user receipt details so ReviewAadhaarDetailsScreen shows live backend data
        await fetchVerificationReceiptDetails();

        Get.snackbar(
          'OTP Verified',
          response['message']?.toString() ?? 'Aadhaar OTP verified successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );

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
      } else {
        final errorMsg = ApiService.getErrorMessage(response);
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
      debugPrint('verifyAadhaarOtp exception: $e');
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

  /// Called from AadhaarNotLinkedScreen when user taps "Upload Aadhaar instead"
  Future<void> uploadAadhaarManually({BuildContext? context}) async {
    final file = await ImagePickerBottomSheet.show(
      context: context,
      title: 'Upload Aadhaar Card',
      subtitle: 'Take a photo or choose your Aadhaar image',
    );

    if (file != null) {
      final bytes = await file.readAsBytes();
      frontImagePath.value = file.path;
      frontImageBytes.value = bytes;
      isUploadingFront.value = true;

      try {
        final response = await ApiService.uploadAadhaar(
          filePath: file.path,
          fileBytes: bytes,
          filename: file.name,
        );
        isUploadingFront.value = false;

        final isSuccess = response['success'] == true ||
            response['status_code'] == 200 ||
            response['status_code'] == 201;

        if (isSuccess) {
          final model = response['data'] != null && response['data'] is Map
              ? AadhaarKycModel.fromJson(Map<String, dynamic>.from(response['data']))
              : null;
          final filename = model?.filename ?? file.name;
          frontUploaded.value = true;
          frontUploadedFilename.value = filename;

          Get.snackbar(
            'Aadhaar Uploaded',
            response['message']?.toString() ??
                'Aadhaar document uploaded successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.navy,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          );

          if (Get.isRegistered<KycFlowController>()) {
            Get.find<KycFlowController>().setStep(KycSubStep.aadhaarReview);
          } else {
            Get.to(() => const ReviewAadhaarDetailsScreen());
          }
        } else {
          final errorMsg = ApiService.getErrorMessage(response);
          Get.snackbar(
            'Upload Failed',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade800,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        isUploadingFront.value = false;
        debugPrint('uploadAadhaarManually exception: $e');
        Get.snackbar(
          'Error',
          'Failed to upload Aadhaar: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// Update onboarding step API: POST {{baseUrl}}/update-onboarding-step
  Future<Map<String, dynamic>> updateOnboardingStep({int step = 5}) async {
    isUpdatingStep.value = true;
    try {
      final response = await ApiService.updateOnboardingStep(step: step);
      isUpdatingStep.value = false;

      final isSuccess = response['success'] == true ||
          response['status_code'] == 200;

      if (isSuccess) {
        final currentStep = response['data']?['current_step'] ?? step;
        await SessionManager.saveCurrentStep(
          currentStep is int ? currentStep : int.tryParse(currentStep.toString()) ?? step,
        );
      }
      return response;
    } catch (e) {
      isUpdatingStep.value = false;
      debugPrint('updateOnboardingStep exception: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Fetch verified user details from GET {{baseUrl}}/download-verification-receipt
  /// to populate the "Check your details" (Review Aadhaar Details) screen dynamically.
  Future<void> fetchVerificationReceiptDetails({BuildContext? context}) async {
    if (isDownloadingReceipt.value) return;
    isDownloadingReceipt.value = true;

    try {
      final response = await ApiService.downloadVerificationReceipt();
      isDownloadingReceipt.value = false;

      final isSuccess = response['success'] == true ||
          response['status_code'] == 200;

      if (isSuccess && response['data'] != null) {
        final model = AadhaarKycModel.fromJson(Map<String, dynamic>.from(response['data']));
        aadhaarKycData.value = model;

        final rawUser = response['data']['user'];
        if (rawUser != null && rawUser is Map) {
          final userData = Map<String, dynamic>.from(rawUser);
          receiptUser.value = userData;
        }

        // 1. Full name & initials from model.user or rawUser
        final name = (model.user?.name ?? receiptUser.value?['name']?.toString() ?? '').trim();
        if (name.isNotEmpty) {
          userName.value = name;
          _updateInitials(name);
        }

        // 2. Mobile number
        final phone = (model.user?.phone ?? receiptUser.value?['phone']?.toString() ?? '').trim();
        if (phone.isNotEmpty) {
          linkedMobile.value = phone.startsWith('+91') ? phone : '+91 $phone';
        }

        // 3. Optional KYC attributes if returned by backend
        final rawDob = model.user?.dob ?? receiptUser.value?['dob']?.toString();
        if (rawDob != null && rawDob.trim().isNotEmpty) {
          dob.value = rawDob.trim();
        }
        final rawGender = model.user?.gender ?? receiptUser.value?['gender']?.toString();
        if (rawGender != null && rawGender.trim().isNotEmpty) {
          gender.value = rawGender.trim();
        }
        final rawAddress = model.user?.address ?? receiptUser.value?['address']?.toString();
        if (rawAddress != null && rawAddress.trim().isNotEmpty) {
          address.value = rawAddress.trim();
        }

        // 4. Ensure masked Aadhaar is formatted
        if (maskedAadhaarDisplay.value.isEmpty || maskedAadhaarDisplay.value == 'N/A') {
          if (aadhaarNumber.value.length == 12) {
            maskedAadhaarDisplay.value = 'XXXX XXXX ${aadhaarNumber.value.substring(8)}';
          }
        }
      } else {
        // Fallback to locally stored session data if network or auth error
        await _loadInitialUserData();
      }
    } catch (e) {
      isDownloadingReceipt.value = false;
      debugPrint('fetchVerificationReceiptDetails exception: $e');
      await _loadInitialUserData();
    }
  }

  /// Alias for backward compatibility
  Future<void> downloadVerificationReceipt({BuildContext? context}) =>
      fetchVerificationReceiptDetails(context: context);

  /// Confirm & continue after reviewing Aadhaar details
  void confirmAndContinue() {
    if (!isConfirmChecked.value) {
      Get.snackbar(
        'Confirmation Required',
        'Please confirm that these Aadhaar details are correct and belong to you.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorRed,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isAadhaarVerified.value = true;

    // Advance onboarding step to 5 (Aadhaar KYC completed)
    updateOnboardingStep(step: 5);

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
      backgroundColor: AppColors.indigo,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}
