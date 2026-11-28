import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../screens/aadhaar_otp_screen.dart';
import '../screens/upload_aadhaar_screen.dart';
import '../screens/review_aadhaar_details_screen.dart';
import '../screens/enter_pan_screen.dart';
import 'pan_kyc_controller.dart';
import 'kyc_flow_controller.dart';
import '../widgets/image_picker_bottom_sheet.dart';
import '../widgets/aadhaar_extracting_dialog.dart';
import '../models/aadhaar_kyc_model.dart';
import '../models/upload_aadhaar_model.dart';
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

  // Upload Mode: 0 = Front & Back Images/PDF, 1 = Single PDF (Front + Back)
  final uploadModeIndex = 0.obs;
  bool get isSinglePdfMode => uploadModeIndex.value == 1;

  // Single PDF upload state
  final singlePdfPath = ''.obs;
  final singlePdfBytes = Rxn<Uint8List>();
  final singlePdfFilename = ''.obs;
  final singlePdfUploaded = false.obs;

  // Manual Document Upload fallback state
  final showManualUpload = false.obs;
  final isUploadingDocuments = false.obs;
  final uploadedAadhaarData = Rxn<UploadAadhaarData>();

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
  /// Pick Aadhaar document (Front or Back) using camera or gallery via ImagePickerBottomSheet.
  /// Stores image path and bytes locally for preview and later upload.
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
        frontUploaded.value = true;
        frontUploadedFilename.value = file.name;
      } else {
        backImagePath.value = file.path;
        backImageBytes.value = bytes;
        backUploaded.value = true;
        backUploadedFilename.value = file.name;
      }
    }
  }

  /// Remove selected Aadhaar document
  void removeAadhaarDocument({required bool isFront}) {
    if (isFront) {
      frontUploaded.value = false;
      frontImagePath.value = '';
      frontImageBytes.value = null;
      frontUploadedFilename.value = '';
    } else {
      backUploaded.value = false;
      backImagePath.value = '';
      backImageBytes.value = null;
      backUploadedFilename.value = '';
    }
  }

  /// Switch upload mode (0: Front & Back Images/PDF, 1: Single PDF)
  void setUploadMode(int index) {
    uploadModeIndex.value = index;
  }

  /// Pick single Aadhaar PDF document (containing Front + Back)
  /// Combined mode requires PDF only - directly opens file picker filtered for .pdf files
  Future<void> pickSinglePdfDocument({BuildContext? context}) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result.isNotEmpty && result.first.path != null) {
        final file = result.first;
        final path = file.path!;
        final name = file.name;

        if (!name.toLowerCase().endsWith('.pdf') && !path.toLowerCase().endsWith('.pdf')) {
          Get.snackbar(
            'PDF Required',
            'The file must be a PDF.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade800,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
          return;
        }

        final bytes = await File(path).readAsBytes();
        singlePdfPath.value = path;
        singlePdfBytes.value = bytes;
        singlePdfUploaded.value = true;
        singlePdfFilename.value = name;
      }
    } catch (e) {
      debugPrint('pickSinglePdfDocument error: $e');
      Get.snackbar(
        'Picker Error',
        'Failed to select PDF document: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Remove selected Single PDF document
  void removeSinglePdfDocument() {
    singlePdfUploaded.value = false;
    singlePdfPath.value = '';
    singlePdfBytes.value = null;
    singlePdfFilename.value = '';
  }

  /// Upload Aadhaar documents via POST /upload-aadhaar
  /// Handles both 'separate' (Front & Back) and 'combined' (Single PDF)
  Future<void> uploadBothAadhaarDocuments() async {
    final isSingle = isSinglePdfMode;

    if (isSingle) {
      final hasSingle = singlePdfPath.value.isNotEmpty || singlePdfBytes.value != null;
      if (!hasSingle) {
        Get.snackbar(
          'Document Required',
          'Please select a single PDF containing both front and back sides of your Aadhaar card.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      if (!singlePdfPath.value.toLowerCase().endsWith('.pdf') &&
          !singlePdfFilename.value.toLowerCase().endsWith('.pdf')) {
        Get.snackbar(
          'Validation Error',
          'The file must be a PDF.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
    } else {
      final hasFront = frontImagePath.value.isNotEmpty || frontImageBytes.value != null;
      final hasBack = backImagePath.value.isNotEmpty || backImageBytes.value != null;

      if (!hasFront || !hasBack) {
        Get.snackbar(
          'Both Documents Required',
          'Please select both front and back images of your Aadhaar card before uploading.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return;
      }
    }

    if (isUploadingDocuments.value) return;
    isUploadingDocuments.value = true;

    try {
      final response = isSingle
          ? await ApiService.uploadAadhaar(
              uploadMode: 'combined',
              singlePdfPath: singlePdfPath.value,
              singlePdfBytes: singlePdfBytes.value,
              singlePdfFilename: singlePdfFilename.value.isNotEmpty ? singlePdfFilename.value : null,
            )
          : await ApiService.uploadAadhaar(
              uploadMode: 'separate',
              frontPath: frontImagePath.value,
              backPath: backImagePath.value,
              frontBytes: frontImageBytes.value,
              backBytes: backImageBytes.value,
              frontFilename: frontUploadedFilename.value.isNotEmpty ? frontUploadedFilename.value : null,
              backFilename: backUploadedFilename.value.isNotEmpty ? backUploadedFilename.value : null,
            );
      isUploadingDocuments.value = false;

      final isSuccess = response['success'] == true ||
          response['status_code'] == 200 ||
          response['status_code'] == 201;

      if (isSuccess) {
        final uploadData = response['data'] != null && response['data'] is Map
            ? UploadAadhaarData.fromJson(Map<String, dynamic>.from(response['data']))
            : null;
        uploadedAadhaarData.value = uploadData;

        if (uploadData?.front != null && uploadData!.front!.isNotEmpty) {
          frontUploadedFilename.value = uploadData.front!;
        }
        if (uploadData?.back != null && uploadData!.back!.isNotEmpty) {
          backUploadedFilename.value = uploadData.back!;
        }

        // Populate extracted OCR details from API response
        final extracted = uploadData?.extractedData;
        if (extracted != null) {
          if (extracted.name != null && extracted.name!.isNotEmpty) {
            userName.value = extracted.name!;
            _updateInitials(extracted.name!);
          }
          if (extracted.dateOfBirth != null && extracted.dateOfBirth!.isNotEmpty) {
            dob.value = extracted.dateOfBirth!;
          }
          if (extracted.gender != null && extracted.gender!.isNotEmpty) {
            gender.value = extracted.gender!;
          }
          if (extracted.address != null && extracted.address!.isNotEmpty) {
            address.value = extracted.address!;
          }
          if (extracted.aadhaarNumber != null && extracted.aadhaarNumber!.isNotEmpty) {
            final raw = extracted.aadhaarNumber!.replaceAll(RegExp(r'\D'), '');
            if (raw.length == 12) {
              aadhaarNumber.value = raw;
              maskedAadhaarDisplay.value = 'XXXX XXXX ${raw.substring(8)}';
            }
          }
        }

        // Show "Extracting details..." modal loader dialog for 5 seconds
        Get.dialog(
          const AadhaarExtractingDialog(),
          barrierDismissible: false,
        );

        await Future.delayed(const Duration(seconds: 5));

        // Dismiss the extracting details loader dialog
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        // After 5s extracting loader, proceed to Review Details
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
      isUploadingDocuments.value = false;
      debugPrint('uploadBothAadhaarDocuments exception: $e');
      Get.snackbar(
        'Upload Error',
        'Failed to upload Aadhaar documents: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Triggered on tap "Send OTP":
  /// Shows only the "Aadhaar Verified!" modal dialog with "Proceed" button
  void initiateAadhaarVerification() {
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

    // Show only the "Aadhaar Verified!" dialog directly
    _showAadhaarVerifiedDialog();
  }

  /// Displays the "Aadhaar Verified!" dialog matching the reference design:
  /// - Green circle with checkmark
  /// - "Aadhaar Verified!" title
  /// - "Aadhaar {number} verification initiated successfully."
  /// - "Proceed" CTA button that calls sendOtp()
  void _showAadhaarVerifiedDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green Circle Checkmark Badge
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F7EE),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC7EBD4),
                      width: 2.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Color(0xFF4CAF50),
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Title: Aadhaar Verified!
                const Text(
                  'Aadhaar Verified!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle: Aadhaar {number} verification initiated successfully.
                Text.rich(
                  TextSpan(
                    text: 'Aadhaar ',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14.5,
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(
                        text: aadhaarNumber.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const TextSpan(
                        text: ' verification initiated successfully.',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),

                // "Proceed" CTA Button with loader while isSendingOtp is true
                Obx(
                  () {
                    final isSending = isSendingOtp.value;
                    return SizedBox(
                      width: 130,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: isSending ? null : () => sendOtp(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          disabledBackgroundColor:
                              AppColors.navy.withValues(alpha: 0.8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Text(
                                'Proceed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Send OTP to registered mobile number via POST /store-aadhaar
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

        if (Get.isDialogOpen == true) {
          Get.back();
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
        if (Get.isDialogOpen == true) {
          Get.back();
        }
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
      if (Get.isDialogOpen == true) {
        Get.back();
      }
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

        // After OTP verification, navigate to Upload Aadhaar Document screen (Front & Back)
        if (Get.isRegistered<KycFlowController>()) {
          Get.find<KycFlowController>().setStep(KycSubStep.aadhaarUpload);
        } else {
          Get.to(() => const UploadAadhaarScreen());
        }
      } else {
        // Aadhaar OTP verification failed: stay on OTP screen and show error
        final errorMsg = ApiService.getErrorMessage(response);

        Get.snackbar(
          'Verification Unsuccessful',
          errorMsg.isNotEmpty
              ? errorMsg
              : 'Failed to verify Aadhaar OTP. Please check the code and try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      isVerifyingOtp.value = false;
      debugPrint('verifyAadhaarOtp exception: $e');
      Get.snackbar(
        'Verification Failed',
        'Failed to verify OTP: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    }
  }

  /// Called from AadhaarNotLinkedScreen when user taps "Upload Aadhaar instead"
  void navigateToManualUpload() {
    showManualUpload.value = true;
    if (Get.isRegistered<KycFlowController>()) {
      Get.find<KycFlowController>().setStep(KycSubStep.aadhaarUpload);
    } else {
      Get.to(() => const UploadAadhaarScreen());
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
  /// to populate the "Check your details" (Review Aadhaar Details) screen directly from API.
  Future<void> fetchVerificationReceiptDetails({BuildContext? context}) async {
    if (isDownloadingReceipt.value) return;
    isDownloadingReceipt.value = true;

    try {
      final response = await ApiService.downloadVerificationReceipt();
      isDownloadingReceipt.value = false;

      final isSuccess = response['success'] == true ||
          response['status_code'] == 200;

      if (isSuccess && response['data'] != null) {
        final dataMap = Map<String, dynamic>.from(response['data']);
        final model = AadhaarKycModel.fromJson(dataMap);
        aadhaarKycData.value = model;

        final rawUser = dataMap['user'] is Map
            ? Map<String, dynamic>.from(dataMap['user'])
            : (dataMap['extracted_data'] is Map
                ? Map<String, dynamic>.from(dataMap['extracted_data'])
                : dataMap);
        receiptUser.value = rawUser;

        // Persist user ID from receipt if available
        final receiptUserId = rawUser['id'] ?? dataMap['user_id'] ?? model.user?.id;
        if (receiptUserId != null) {
          SessionManager.saveUserId(receiptUserId);
        }

        // 1. Full name & initials directly from API
        final name = (rawUser['name'] ?? model.user?.name ?? '').toString().trim();
        if (name.isNotEmpty && name.toLowerCase() != 'null') {
          userName.value = name;
          _updateInitials(name);
        }

        // 2. Mobile number directly from API
        final phone = (rawUser['phone'] ??
                rawUser['mobile'] ??
                rawUser['linked_mobile'] ??
                model.user?.phone ??
                '')
            .toString()
            .trim();
        if (phone.isNotEmpty && phone.toLowerCase() != 'null') {
          linkedMobile.value = phone.startsWith('+91') ? phone : '+91 $phone';
        }

        // 3. Date of birth directly from API
        final rawDob = (rawUser['dob'] ??
                rawUser['date_of_birth'] ??
                model.user?.dob ??
                '')
            .toString()
            .trim();
        if (rawDob.isNotEmpty && rawDob.toLowerCase() != 'null') {
          dob.value = rawDob;
        }

        // 4. Gender directly from API
        final rawGender = (rawUser['gender'] ?? model.user?.gender ?? '').toString().trim();
        if (rawGender.isNotEmpty && rawGender.toLowerCase() != 'null') {
          gender.value = rawGender;
        }

        // 5. Address directly from API
        final rawAddress = (rawUser['address'] ?? model.user?.address ?? '').toString().trim();
        if (rawAddress.isNotEmpty && rawAddress.toLowerCase() != 'null') {
          address.value = rawAddress;
        }

        // 6. Masked Aadhaar directly from API or input
        final rawAadhaar = (rawUser['aadhaar_number'] ??
                rawUser['aadhaar_no'] ??
                rawUser['masked_aadhaar'] ??
                aadhaarNumber.value)
            .toString()
            .trim();
        final digits = rawAadhaar.replaceAll(RegExp(r'\D'), '');
        if (digits.length == 12) {
          maskedAadhaarDisplay.value = 'XXXX XXXX ${digits.substring(8)}';
        } else if (rawAadhaar.isNotEmpty && rawAadhaar.toLowerCase() != 'null') {
          maskedAadhaarDisplay.value = rawAadhaar;
        }
      }
    } catch (e) {
      isDownloadingReceipt.value = false;
      debugPrint('fetchVerificationReceiptDetails exception: $e');
      // No local storage fallback: missing details will display N/A or - as requested
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
