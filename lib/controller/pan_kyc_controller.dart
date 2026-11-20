import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../screens/upload_pan_screen.dart';
import '../screens/pan_not_verified_screen.dart';
import '../screens/review_pan_details_screen.dart';
import '../screens/kyc_next_step_placeholder_screen.dart';
import 'kyc_flow_controller.dart';
import '../widgets/image_picker_bottom_sheet.dart';
import '../models/store_pan_response_model.dart';
import '../models/upload_pan_model.dart';
import '../services/api_service.dart';

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

  // PAN Input (starts empty, dynamic input)
  final panNumber = ''.obs;
  TextEditingController panController = TextEditingController();

  // Branching toggle: is PAN verified with Income Tax records?
  final isPanVerified = false.obs;

  // API State
  final isStoringPan = false.obs;
  final storePanData = Rxn<StorePanData>();
  final uploadedPanData = Rxn<UploadPanData>();
  final panDocumentId = RxnInt();
  final isUploadingPan = false.obs;
  final panUploadedFilename = ''.obs;

  // Upload PAN Card state
  final isCardUploaded = false.obs;
  final uploadSource = ''.obs; // 'Camera' or 'Gallery'
  final panImagePath = ''.obs;
  final panImageBytes = Rxn<Uint8List>();

  // Extracted PAN details (dynamic - populated directly from API)
  final nameAsPerPan = ''.obs;
  final fathersName = ''.obs;
  final dob = ''.obs;
  final matchesAadhaar = false.obs;

  // Overall PAN completion status
  final isPanCompleted = false.obs;

  /// PAN format validation: 5 uppercase letters, 4 numbers, 1 uppercase letter (10 chars)
  bool get isPanFormatValid {
    final clean = panNumber.value.trim().toUpperCase();
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(clean);
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

  /// Verify PAN button action: calls POST /store-pan-card and stores response in model
  Future<void> verifyPan() async {
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

    if (isStoringPan.value) return;
    isStoringPan.value = true;

    try {
      final response = await ApiService.storePanCard(
        panCardNumber: panNumber.value.trim().toUpperCase(),
      );
      isStoringPan.value = false;

      final isSuccess = response['success'] == true ||
          response['status_code'] == 200 ||
          response['status_code'] == 201;

      if (isSuccess) {
        if (response['data'] != null && response['data'] is Map) {
          final data = StorePanData.fromJson(Map<String, dynamic>.from(response['data']));
          storePanData.value = data;
          if (data.documentId != null) {
            panDocumentId.value = data.documentId;
          }
        }

        isPanVerified.value = true;

        final message = response['message']?.toString() ?? 'PAN card number saved successfully.';
        Get.snackbar(
          'PAN Verified',
          message.isNotEmpty ? message : 'PAN card number saved successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );

        if (Get.isRegistered<KycFlowController>()) {
          Get.find<KycFlowController>().setStep(KycSubStep.panUpload);
        } else {
          Get.to(() => const UploadPanScreen());
        }
      } else {
        isPanVerified.value = false;
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

        if (Get.isRegistered<KycFlowController>()) {
          Get.find<KycFlowController>().setStep(KycSubStep.panNotVerified);
        } else {
          Get.to(() => const PanNotVerifiedScreen());
        }
      }
    } catch (e) {
      isStoringPan.value = false;
      debugPrint('verifyPan exception: $e');
      Get.snackbar(
        'Error',
        'Failed to save PAN card: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
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

  /// Clear uploaded PAN image and reset to viewfinder placeholder
  void clearPanImage() {
    isCardUploaded.value = false;
    uploadSource.value = '';
    panImagePath.value = '';
    panImageBytes.value = null;
    panUploadedFilename.value = '';
  }

  /// Upload PAN Card Image via POST /upload-pan
  Future<bool> uploadPanImage({
    String? filePath,
    Uint8List? fileBytes,
    String? filename,
  }) async {
    final path = filePath ?? panImagePath.value;
    final bytes = fileBytes ?? panImageBytes.value;
    final resolvedFilename = filename ??
        (panUploadedFilename.value.isNotEmpty
            ? panUploadedFilename.value
            : (path.isNotEmpty ? path.split('/').last : 'pan_card.jpg'));

    if (path.isEmpty && (bytes == null || bytes.isEmpty)) {
      Get.snackbar(
        'Upload Error',
        'Please select or capture a PAN card image first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    if (isUploadingPan.value) return false;
    isUploadingPan.value = true;

    try {
      final response = await ApiService.uploadPan(
        filePath: path,
        fileBytes: bytes,
        filename: resolvedFilename,
        uploadMode: 'combined',
      );
      isUploadingPan.value = false;

      final isSuccess = response['success'] == true ||
          response['status_code'] == 200 ||
          response['status_code'] == 201;

      if (isSuccess) {
        if (response['data'] != null && response['data'] is Map) {
          final dataMap = Map<String, dynamic>.from(response['data']);
          final uploadData = UploadPanData.fromJson(dataMap);
          uploadedPanData.value = uploadData;

          // Legacy StorePanData support
          final legacyData = StorePanData.fromJson(dataMap);
          storePanData.value = StorePanData(
            panCardNumber: uploadData.extractedData?.panNumber ?? storePanData.value?.panCardNumber ?? panNumber.value,
            userId: uploadData.userId ?? legacyData.userId ?? storePanData.value?.userId,
            documentId: legacyData.documentId ?? storePanData.value?.documentId ?? panDocumentId.value,
            filename: uploadData.filename ?? legacyData.filename,
          );

          if (uploadData.filename != null && uploadData.filename!.isNotEmpty) {
            panUploadedFilename.value = uploadData.filename!;
          } else if (resolvedFilename.isNotEmpty) {
            panUploadedFilename.value = resolvedFilename;
          }

          if (uploadData.panStatus != null) {
            isPanVerified.value = uploadData.panStatus!.toLowerCase() == 'accepted';
          }

          // Populate extracted OCR details directly from API
          final extracted = uploadData.extractedData;
          if (extracted != null) {
            if (extracted.panNumber != null && extracted.panNumber!.isNotEmpty) {
              panNumber.value = extracted.panNumber!;
              if (panController.text != extracted.panNumber!) {
                panController.text = extracted.panNumber!;
              }
            }
            if (extracted.name != null && extracted.name!.isNotEmpty) {
              nameAsPerPan.value = extracted.name!;
            }
            if (extracted.fatherName != null && extracted.fatherName!.isNotEmpty) {
              fathersName.value = extracted.fatherName!;
            }
            if (extracted.dateOfBirth != null && extracted.dateOfBirth!.isNotEmpty) {
              dob.value = extracted.dateOfBirth!;
            }
          }
        }

        isCardUploaded.value = true;

        Get.snackbar(
          'PAN Uploaded',
          response['message']?.toString() ?? 'PAN card uploaded successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
        return true;
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
        return false;
      }
    } catch (e) {
      isUploadingPan.value = false;
      debugPrint('uploadPanImage exception: $e');
      Get.snackbar(
        'Upload Error',
        'Failed to upload PAN card: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return false;
    }
  }

  /// Capture PAN photo using device camera via ImagePicker and auto-uploads to POST /upload-pan
  Future<void> takePhoto() async {
    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        isCardUploaded.value = true;
        uploadSource.value = 'Camera';
        panImagePath.value = file.path;
        panImageBytes.value = bytes;
        panUploadedFilename.value = file.name;
        await uploadPanImage(filePath: file.path, fileBytes: bytes, filename: file.name);
      }
    } catch (e) {
      debugPrint('Camera error: $e');
      Get.snackbar(
        'Camera Error',
        'Could not access camera on this device.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorRed,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Select PAN card photo from gallery via ImagePicker and auto-uploads to POST /upload-pan
  Future<void> pickFromGallery() async {
    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        isCardUploaded.value = true;
        uploadSource.value = 'Gallery';
        panImagePath.value = file.path;
        panImageBytes.value = bytes;
        panUploadedFilename.value = file.name;
        await uploadPanImage(filePath: file.path, fileBytes: bytes, filename: file.name);
      }
    } catch (e) {
      debugPrint('Gallery error: $e');
      Get.snackbar(
        'Gallery Error',
        'Could not access gallery on this device.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorRed,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Open Bottom Sheet to choose Camera or Gallery for PAN card and auto-uploads to POST /upload-pan
  Future<void> openImagePickerBottomSheet({BuildContext? context}) async {
    final file = await ImagePickerBottomSheet.show(
      context: context,
      title: 'Upload PAN card',
      subtitle: 'Take a photo or choose from gallery',
    );

    if (file != null) {
      final bytes = await file.readAsBytes();
      isCardUploaded.value = true;
      uploadSource.value = 'Selected';
      panImagePath.value = file.path;
      panImageBytes.value = bytes;
      panUploadedFilename.value = file.name;
      await uploadPanImage(filePath: file.path, fileBytes: bytes, filename: file.name);
    }
  }

  /// Continue from upload screen to Review PAN Details screen
  Future<void> continueToReview() async {
    if (isUploadingPan.value) {
      Get.snackbar(
        'Uploading',
        'Please wait while your PAN card image is being uploaded.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (!isCardUploaded.value && panImagePath.value.isEmpty && panImageBytes.value == null) {
      Get.snackbar(
        'Upload Required',
        'Please capture or select your PAN card photo to proceed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // If an image was selected/captured but upload has not been confirmed yet, upload it now
    if (panUploadedFilename.value.isEmpty && (panImagePath.value.isNotEmpty || panImageBytes.value != null)) {
      final success = await uploadPanImage();
      if (!success) return;
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
      backgroundColor: AppColors.indigo,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}
