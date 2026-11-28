import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/co_applicant_form_options_model.dart';
import '../models/add_co_applicant_model.dart';
import '../models/co_applicants_list_model.dart';
import '../models/co_applicant_detail_model.dart';
import '../models/applicant_detail_model.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../theme/app_colors.dart';
import 'apply_loan_controller.dart';
import 'dashboard_controller.dart';

/// Co-applicant data model
class CoApplicantModel {
  final dynamic id;
  final String name;
  final String relationship;
  final String mobileNumber;
  final String applicantType;
  final String employmentType;
  final String role; // 'Co-Applicant' or 'Guarantor'
  final String dob;
  final String monthlyIncome;
  final String status;
  final List<CoAppDocumentItem> documents;
  final Map<String, List<XFile>> uploadedFiles;

  CoApplicantModel({
    this.id,
    required this.name,
    required this.relationship,
    required this.mobileNumber,
    this.applicantType = '',
    this.employmentType = '',
    this.role = 'Co-Applicant',
    this.dob = '',
    this.monthlyIncome = '',
    this.status = 'Documents pending',
    this.documents = const [],
    this.uploadedFiles = const {},
  });
}

/// Controller managing Applicant and Co-applicant state
class ApplicantDetailsController extends GetxController {
  // 0 = Primary Applicant, 1 = Co-applicant
  final selectedTabIndex = 0.obs;

  // Selected role when adding: 'Co-Applicant' or 'Guarantor'
  final selectedRole = 'Co-Applicant'.obs;

  // Loading state for GET /co-applicants/form-options
  final isLoadingFormOptions = false.obs;
  final formOptionsData = Rxn<CoApplicantFormOptionsData>();

  // Adding Co-Applicant State
  final isAddingCoApplicant = false.obs;
  final leadId = Rxn<dynamic>();

  // Co-Applicant OTP verification state from POST /co-applicants response
  final lastCoAppOtp = Rxn<dynamic>();
  final lastCoAppOtpExpiresAt = Rxn<String>();

  dynamic get currentLeadId {
    if (leadId.value != null) return leadId.value;
    if (Get.isRegistered<ApplyLoanController>()) {
      final appLeadId = Get.find<ApplyLoanController>().leadStoreData.value?.leadId;
      if (appLeadId != null) return appLeadId;
    }
    // Also check applicantDetailsData loanApplications for active lead
    final apps = applicantDetailsData.value?.loanApplications;
    if (apps != null && apps.isNotEmpty) {
      final firstAppId = apps.first.id;
      if (firstAppId != null) return firstAppId;
    }
    return null;
  }

  // Dynamic Options strictly from GET /co-applicants/form-options API
  final apiRelationshipOptions = <String>[].obs;
  final apiApplicantTypeOptions = <String>[].obs;
  final apiOptionsByApplicantType = <String, List<String>>{}.obs;

  // Dynamic documents list strictly from API response (POST /co-applicants)
  final coAppDocuments = <CoAppDocumentItem>[].obs;

  // Uploaded files for the co-applicant: Map<docKey, List<XFile>>
  final coAppUploadedFiles = <String, List<XFile>>{}.obs;

  // Existing server files for edit mode: Map<docKey, List<Map<String, dynamic>>>
  final coAppExistingFiles = <String, List<Map<String, dynamic>>>{}.obs;

  // Validation errors for co-applicant documents from upload API
  final coAppDocumentErrors = <String, String>{}.obs;

  // Loading state for document deletion
  final isDeletingCoAppDoc = false.obs;

  // Set of document keys currently uploading individually
  final uploadingDocKeys = <String>{}.obs;

  // Aadhaar upload mode: 'separate' (Front & Back) or 'combined' (Single PDF)
  final selectedAadhaarUploadMode = 'separate'.obs;

  // Store the original aadhaar doc item from API (with upload_modes) for reference
  CoAppDocumentItem? _originalAadhaarDocItem;

  // Temporary holder for newly created co-applicant if document upload fails,
  // preventing duplicate creations on retry
  final currentDraftCoAppId = Rxn<dynamic>();

  // List of co-applicants from API (GET /co-applicants)
  final isLoadingCoApplicants = false.obs;
  final coApplicantsList = <CoApplicantItem>[].obs;
  final coApplicants = <CoApplicantModel>[].obs;

  // Primary Applicant Details API state (GET /applicants/{id})
  final isLoadingApplicantDetails = false.obs;
  final applicantDetailsData = Rxn<ApplicantDetailModel>();

  // Filter for primary applicant documents: 'all' or 'uploaded'
  final applicantDocFilter = 'all'.obs;

  /// Dynamic list of primary applicant documents strictly from the API response
  List<ApplicantDocumentItem> get primaryApplicantDocuments {
    final apps = applicantDetailsData.value?.loanApplications;
    if (apps != null && apps.isNotEmpty) {
      final activeApp = apps.firstWhereOrNull((a) => a.isActive == true) ?? apps.first;
      return activeApp.documents;
    }
    return const [];
  }

  // Co-Applicant Details API state (GET /co-applicants/{id})
  final isLoadingCoAppDetails = false.obs;
  final selectedCoApplicantDetails = Rxn<CoApplicantDetailData>();
  final isDeletingCoApplicant = false.obs;
  final editingCoApplicantId = Rxn<dynamic>();

  /// Delete Co-Applicant API: DELETE {{baseUrl}}/co-applicants/{id}
  Future<bool> deleteCoApplicant(dynamic coApplicantId) async {
    if (coApplicantId == null) return false;
    isDeletingCoApplicant.value = true;
    try {
      final res = await ApiService.deleteCoApplicant(coApplicantId: coApplicantId);
      if (res['success'] == true || res['status_code'] == 200) {
        coApplicantsList.removeWhere((item) => item.id == coApplicantId);

        // Close delete confirmation dialog first before showing snackbar
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        Get.snackbar(
          'Success',
          res['message']?.toString() ?? 'Co-applicant deleted successfully.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
        return true;
      } else {
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        Get.snackbar(
          'Notice',
          res['message']?.toString() ?? 'Failed to delete co-applicant.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.errorRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error in deleteCoApplicant: $e');
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      return false;
    } finally {
      isDeletingCoApplicant.value = false;
    }
  }

  /// Prepare form fields for editing an existing co-applicant
  void prepareEditCoApplicant(CoApplicantItem item) {
    editingCoApplicantId.value = item.id;
    fullNameController.text = item.name ?? '';
    mobileNumberController.text = item.phone ?? '';
    selectedRelationship.value = item.relationship ?? '';
    selectedApplicantType.value = item.applicantType ?? 'Financial';
    selectedEmploymentType.value = item.employmentType ?? '';
    coAppUploadedFiles.clear();

    if (item.employmentType != null && item.employmentType!.isNotEmpty) {
      _updateDocumentsForEmploymentType(item.employmentType!);
    }
  }

  /// Fetches co-applicant full details via GET {{baseUrl}}/co-applicants/{id}
  /// and populates existing fields & documents for edit mode
  Future<void> fetchAndPopulateCoApplicantForEdit(dynamic coApplicantId) async {
    if (coApplicantId == null) return;
    coAppExistingFiles.clear();
    coAppUploadedFiles.clear();
    coAppDocumentErrors.clear();

    final details = await fetchCoApplicantDetails(coApplicantId);
    if (details != null) {
      final profile = details.coApplicant;
      if (profile != null) {
        if (profile.name != null && profile.name!.isNotEmpty) {
          fullNameController.text = profile.name!;
        }
        if (profile.phone != null && profile.phone!.isNotEmpty) {
          mobileNumberController.text = profile.phone!;
        }
        if (profile.relationship != null && profile.relationship!.isNotEmpty) {
          selectedRelationship.value = profile.relationship!;
        }
        if (profile.applicantType != null && profile.applicantType!.isNotEmpty) {
          selectedApplicantType.value = profile.applicantType!;
        }
        if (profile.employmentType != null && profile.employmentType!.isNotEmpty) {
          selectedEmploymentType.value = profile.employmentType!;
        }
      }

      // First, ensure coAppDocuments has the employment type document schema from formOptionsData
      if (selectedEmploymentType.value.isNotEmpty) {
        _updateDocumentsForEmploymentType(selectedEmploymentType.value);
      }

      // Map existing uploaded documents from API response
      if (details.documents.isNotEmpty) {
        for (final d in details.documents) {
          final docKey = d.key ?? '';
          if (docKey.isEmpty) continue;

          // If aadhar_card with multiple files or separate
          if (docKey == 'aadhar_card' || docKey == 'aadhaar_card') {
            if (d.files.isNotEmpty) {
              for (int i = 0; i < d.files.length; i++) {
                final f = d.files[i];
                final isFront = f.docKey == 'aadhar_card_front' ||
                    (f.name?.toLowerCase().contains('front') == true) ||
                    i == 0;
                final targetKey = isFront ? 'aadhar_card_front' : 'aadhar_card_back';
                coAppExistingFiles[targetKey] = [
                  {
                    'doc_key': targetKey,
                    'index': f.index ?? i,
                    'name': f.name,
                    'url': f.url,
                    'status': f.status,
                  }
                ];
              }
            }
            continue;
          }

          final targetKey = (docKey == 'pan_card' || docKey == 'pan_card_image')
              ? 'pan_card_image'
              : docKey;

          final List<Map<String, dynamic>> fileList = [];
          if (d.files.isNotEmpty) {
            for (int i = 0; i < d.files.length; i++) {
              final f = d.files[i];
              fileList.add({
                'doc_key': f.docKey ?? targetKey,
                'index': f.index ?? i,
                'name': f.name,
                'url': f.url,
                'status': f.status,
              });
            }
          } else if (d.uploaded == true) {
            fileList.add({
              'doc_key': targetKey,
              'index': 0,
              'name': 'Uploaded Document',
              'url': null,
              'status': d.status,
            });
          }

          if (fileList.isNotEmpty) {
            coAppExistingFiles[targetKey] = fileList;
          } else {
            coAppExistingFiles.remove(targetKey);
          }

          // If this document wasn't in coAppDocuments, add it dynamically
          final existingDoc = coAppDocuments.firstWhereOrNull((item) => item.key == targetKey);
          if (existingDoc == null) {
            coAppDocuments.add(
              CoAppDocumentItem(
                key: targetKey,
                label: d.label?.isNotEmpty == true ? d.label : _formatDocKey(targetKey),
                allowMultiple: d.allowMultiple,
                acceptedFormats: d.acceptedFormats,
                maxSizeMb: d.maxSizeMb,
                uploadField: d.uploadField ?? getUploadFieldForDocKey(targetKey),
                ocrAutofill: d.ocrAutofill,
                uploaded: d.uploaded ?? fileList.isNotEmpty,
                status: d.status,
                files: d.files.map((f) => f.toJson()).toList(),
              ),
            );
          } else if (d.label?.isNotEmpty == true && existingDoc.label != d.label) {
            // Update label from API response if cleaner
            final idx = coAppDocuments.indexOf(existingDoc);
            if (idx != -1) {
              coAppDocuments[idx] = CoAppDocumentItem(
                key: existingDoc.key,
                label: d.label,
                allowMultiple: existingDoc.allowMultiple,
                acceptedFormats: existingDoc.acceptedFormats,
                maxSizeMb: existingDoc.maxSizeMb,
                uploadField: existingDoc.uploadField,
                ocrAutofill: existingDoc.ocrAutofill,
                uploaded: d.uploaded ?? fileList.isNotEmpty,
                status: d.status,
                files: d.files.map((f) => f.toJson()).toList(),
              );
            }
          }
        }
      }
    }
  }

  /// Format document key to readable label
  String _formatDocKey(String key) {
    if (key == 'aadhar_card_front') return 'Aadhaar Card (Front)';
    if (key == 'aadhar_card_back') return 'Aadhaar Card (Back)';
    if (key == 'aadhar_card_combined_pdf') return 'Aadhaar Card (Single PDF)';
    if (key == 'aadhar_card' || key == 'aadhaar_card') return 'Aadhaar Card';
    if (key == 'pan_card_image' || key == 'pan_card') return 'PAN Card';
    if (key == 'profile_image') return 'Co-Applicant Photo';
    if (key == 'latest_salary_slips') return 'Salary Slip';
    if (key == 'bank_statement') return 'Bank Statement';
    if (key == 'form_16_itr') return 'Form 16 / ITR';
    if (key == 'salary_letterpad') return 'Company Letterpad';
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  /// Reset form fields when opening add screen fresh
  void resetAddCoApplicantForm() {
    editingCoApplicantId.value = null;
    currentDraftCoAppId.value = null;
    coAppDocumentErrors.clear();
    coAppExistingFiles.clear();
    fullNameController.clear();
    mobileNumberController.clear();
    selectedRelationship.value = '';
    selectedApplicantType.value = '';
    selectedEmploymentType.value = '';
    coAppDocuments.clear();
    coAppUploadedFiles.clear();
    selectedAadhaarUploadMode.value = 'separate';
    _originalAadhaarDocItem = null;
  }

  /// Switch Aadhaar upload mode between 'separate' (Front & Back) and 'combined' (Single PDF)
  void switchAadhaarUploadMode(String mode) {
    if (selectedAadhaarUploadMode.value == mode) return;

    // Clear any existing aadhaar files when switching modes
    coAppUploadedFiles.remove('aadhar_card_front');
    coAppUploadedFiles.remove('aadhar_card_back');
    coAppUploadedFiles.remove('aadhar_card_combined_pdf');
    coAppExistingFiles.remove('aadhar_card_front');
    coAppExistingFiles.remove('aadhar_card_back');
    coAppExistingFiles.remove('aadhar_card_combined_pdf');
    clearCoAppDocError('aadhar_card_front');
    clearCoAppDocError('aadhar_card_back');
    clearCoAppDocError('aadhar_card_combined_pdf');

    selectedAadhaarUploadMode.value = mode;

    // Re-expand aadhaar docs based on new mode
    _rebuildAadhaarDocs();
  }

  /// Rebuilds the aadhaar document entries in coAppDocuments based on selected mode
  void _rebuildAadhaarDocs() {
    final doc = _originalAadhaarDocItem;
    if (doc == null) return;

    // Find and remove existing aadhaar entries
    coAppDocuments.removeWhere((d) {
      final k = d.key ?? '';
      return k == 'aadhar_card' || k == 'aadhaar_card' ||
          k == 'aadhar_card_front' || k == 'aadhar_card_back' ||
          k == 'aadhar_card_combined_pdf';
    });

    // Find the insertion index (after profile_image if exists, else at start)
    int insertIndex = 0;
    final profileIdx = coAppDocuments.indexWhere((d) => d.key == 'profile_image');
    if (profileIdx >= 0) insertIndex = profileIdx + 1;

    if (selectedAadhaarUploadMode.value == 'combined') {
      // Single combined PDF mode
      final combinedMode = doc.uploadModes?.firstWhereOrNull((m) => m.key == 'combined');
      coAppDocuments.insert(
        insertIndex,
        CoAppDocumentItem(
          key: 'aadhar_card_combined_pdf',
          label: 'Aadhaar Card (Single PDF)',
          allowMultiple: false,
          acceptedFormats: combinedMode?.acceptedFormats.isNotEmpty == true
              ? combinedMode!.acceptedFormats
              : ['pdf'],
          maxSizeMb: doc.maxSizeMb ?? 5,
          uploadField: combinedMode?.fields.isNotEmpty == true
              ? combinedMode!.fields.first
              : 'documents[aadhar_card_combined_pdf]',
          ocrAutofill: doc.ocrAutofill,
          uploaded: false,
          status: 'not_uploaded',
        ),
      );
    } else {
      // Separate Front & Back mode
      final separateMode = doc.uploadModes?.firstWhereOrNull((m) => m.key == 'separate');
      final frontField = separateMode != null && separateMode.fields.isNotEmpty
          ? separateMode.fields.first
          : 'documents[aadhar_card_front]';
      final backField = separateMode != null && separateMode.fields.length > 1
          ? separateMode.fields[1]
          : 'documents[aadhar_card_back]';
      final formats = separateMode?.acceptedFormats.isNotEmpty == true
          ? separateMode!.acceptedFormats
          : (doc.acceptedFormats.isNotEmpty ? doc.acceptedFormats : ['pdf', 'jpg', 'jpeg', 'png']);

      coAppDocuments.insert(
        insertIndex,
        CoAppDocumentItem(
          key: 'aadhar_card_front',
          label: 'Aadhaar Card (Front)',
          allowMultiple: false,
          acceptedFormats: formats,
          maxSizeMb: doc.maxSizeMb ?? 5,
          uploadField: frontField,
          ocrAutofill: true,
          uploaded: false,
          status: 'not_uploaded',
        ),
      );
      coAppDocuments.insert(
        insertIndex + 1,
        CoAppDocumentItem(
          key: 'aadhar_card_back',
          label: 'Aadhaar Card (Back)',
          allowMultiple: false,
          acceptedFormats: formats,
          maxSizeMb: doc.maxSizeMb ?? 5,
          uploadField: backField,
          ocrAutofill: true,
          uploaded: false,
          status: 'not_uploaded',
        ),
      );
    }
  }

  /// Update Co-Applicant API: PUT {{baseUrl}}/co-applicants/{id}
  Future<bool> updateCoApplicant({required dynamic coApplicantId, String? role}) async {
    if (addCoAppFormKey.currentState?.validate() != true) {
      return false;
    }

    final name = fullNameController.text.trim();
    final rawMobile = mobileNumberController.text.trim();
    final mobile = rawMobile.replaceAll(RegExp(r'[^0-9]'), '');
    final relationship = selectedRelationship.value.trim();
    final appType = selectedApplicantType.value.trim();
    final empType = selectedEmploymentType.value.trim();

    if (relationship.isEmpty || empType.isEmpty) {
      return false;
    }

    isAddingCoApplicant.value = true;
    try {
      final res = await ApiService.updateCoApplicant(
        coApplicantId: coApplicantId,
        coApplicantName: name,
        coApplicantMobile: mobile,
        coRelationship: relationship,
        applicantType: appType,
        employmentType: empType,
        leadId: currentLeadId,
      );

      if (res['status_code'] == 200 || res['status_code'] == 201 || res['success'] == true) {
        String successMsg =
            res['message']?.toString() ?? 'Co-Applicant updated successfully!';

        // Upload any newly selected documents via dedicated upload endpoint
        if (coAppUploadedFiles.isNotEmpty) {
          final uploadRes = await _uploadSelectedCoAppDocs(coApplicantId);
          final isUploadOk = uploadRes != null &&
              (uploadRes['success'] == true ||
                  uploadRes['status_code'] == 200 ||
                  uploadRes['status_code'] == 201);

          if (!isUploadOk) {
            _setDocumentErrors(uploadRes);
            final errorMsg = ApiService.getErrorMessage(uploadRes);
            Get.snackbar(
              'Document Upload Failed',
              errorMsg,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.errorRed,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            );
            return false;
          }

          if (uploadRes['message'] != null &&
              uploadRes['message'].toString().isNotEmpty) {
            successMsg = uploadRes['message'].toString();
          }
        }

        coAppDocumentErrors.clear();
        currentDraftCoAppId.value = null;

        // Refresh co-applicants list and applicant details
        fetchCoApplicants();
        fetchApplicantDetails();
        selectedTabIndex.value = 1;

        resetAddCoApplicantForm();

        Future.delayed(const Duration(milliseconds: 150), () {
          Get.snackbar(
            'Success',
            successMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successGreen,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        });
        return true;
      } else {
        Get.snackbar(
          'Notice',
          res['message']?.toString() ?? 'Failed to update co-applicant.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error in updateCoApplicant: $e');
      return false;
    } finally {
      isAddingCoApplicant.value = false;
    }
  }

  /// Fetch Co-Applicant Details API: GET {{baseUrl}}/co-applicants/{id}
  Future<CoApplicantDetailData?> fetchCoApplicantDetails(dynamic coApplicantId) async {
    if (coApplicantId == null) return null;
    isLoadingCoAppDetails.value = true;
    selectedCoApplicantDetails.value = null;
    try {
      final res = await ApiService.getCoApplicantDetails(coApplicantId: coApplicantId);
      if (res['success'] == true || res['status_code'] == 200) {
        if (res['data'] != null && res['data'] is Map<String, dynamic>) {
          final data = CoApplicantDetailData.fromJson(res['data'] as Map<String, dynamic>);
          selectedCoApplicantDetails.value = data;
          return data;
        }
      } else {
        Get.snackbar(
          'Notice',
          res['message']?.toString() ?? 'Failed to fetch co-applicant details.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error in fetchCoApplicantDetails: $e');
    } finally {
      isLoadingCoAppDetails.value = false;
    }
    return null;
  }

  // Loading states for Co-Applicant Document Access OTP
  final isSendingCoAppOtp = false.obs;
  final isVerifyingCoAppOtp = false.obs;

  /// Send Co-Applicant Document Access OTP
  Future<Map<String, dynamic>> sendCoApplicantOtp({
    required dynamic coApplicantId,
    String? phone,
  }) async {
    isSendingCoAppOtp.value = true;
    try {
      final res = await ApiService.sendCoApplicantDocumentOtp(
        coApplicantId: coApplicantId,
        phone: phone,
      );
      return res;
    } finally {
      isSendingCoAppOtp.value = false;
    }
  }

  /// Resend Co-Applicant Document Access OTP
  Future<Map<String, dynamic>> resendCoApplicantOtp({
    required dynamic coApplicantId,
    String? phone,
  }) async {
    isSendingCoAppOtp.value = true;
    try {
      final res = await ApiService.resendCoApplicantDocumentOtp(
        coApplicantId: coApplicantId,
        phone: phone,
      );
      return res;
    } finally {
      isSendingCoAppOtp.value = false;
    }
  }

  /// Verify Co-Applicant Document Access OTP
  Future<Map<String, dynamic>> verifyCoApplicantOtp({
    required dynamic coApplicantId,
    required String otp,
  }) async {
    isVerifyingCoAppOtp.value = true;
    try {
      final res = await ApiService.verifyCoApplicantDocumentOtp(
        coApplicantId: coApplicantId,
        otp: otp,
      );

      if (res['success'] == true || res['status_code'] == 200) {
        // Refresh co-applicants list and selected co-applicant details
        await fetchCoApplicants();
        await fetchCoApplicantDetails(coApplicantId);
      }
      return res;
    } finally {
      isVerifyingCoAppOtp.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchApplicantDetails();
    fetchCoApplicants();
  }

  /// Fetch Applicant Details API: GET {{baseUrl}}/applicants/{user_id}
  Future<void> fetchApplicantDetails({dynamic userId}) async {
    isLoadingApplicantDetails.value = true;
    try {
      dynamic effectiveUserId = userId;
      if (effectiveUserId == null || effectiveUserId.toString().trim().isEmpty) {
        final savedId = await SessionManager.getUserId();
        if (savedId.isNotEmpty) effectiveUserId = savedId;
      }
      if ((effectiveUserId == null || effectiveUserId.toString().trim().isEmpty) &&
          Get.isRegistered<DashboardController>()) {
        final dashId = Get.find<DashboardController>().dashboardData.value?.user?.id;
        if (dashId != null) effectiveUserId = dashId;
      }
      // Fallback default user ID 1 matching collection
      effectiveUserId ??= 1;

      final res = await ApiService.getApplicantDetails(userId: effectiveUserId);
      if (res['success'] == true || res['status_code'] == 200) {
        final model = ApplicantDetailModel.fromJson(res);
        applicantDetailsData.value = model;

        if (model.applicant?.id != null) {
          SessionManager.saveUserId(model.applicant!.id);
        }
      } else {
        debugPrint('Notice in fetchApplicantDetails: ${res['message']}');
      }
    } catch (e) {
      debugPrint('Error in fetchApplicantDetails: $e');
    } finally {
      isLoadingApplicantDetails.value = false;
    }
  }

  /// Fetch Co-Applicants List API: GET {{baseUrl}}/co-applicants
  Future<void> fetchCoApplicants() async {
    isLoadingCoApplicants.value = true;
    try {
      final res = await ApiService.getCoApplicants();
      if (res['success'] == true || res['status_code'] == 200) {
        final model = CoApplicantsListResponseModel.fromJson(res);
        if (model.data != null) {
          coApplicantsList.assignAll(model.data!.coApplicants);
        }
      }
    } catch (e) {
      debugPrint('Error in fetchCoApplicants: $e');
    } finally {
      isLoadingCoApplicants.value = false;
    }
  }

  // Form key for Add Co-Applicant screen validation
  final addCoAppFormKey = GlobalKey<FormState>();

  // Form fields for Add Co-applicant screen
  final fullNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final selectedRelationship = ''.obs;
  final selectedApplicantType = ''.obs;
  final selectedEmploymentType = ''.obs;

  /// Fetch Co-Applicant Form Options API: GET {{baseUrl}}/co-applicants/form-options
  Future<void> fetchCoApplicantFormOptions() async {
    isLoadingFormOptions.value = true;
    try {
      final res = await ApiService.getCoApplicantFormOptions();
      if (res['success'] == true || res['status_code'] == 200) {
        final model = CoApplicantFormOptionsResponseModel.fromJson(res);
        if (model.data != null) {
          formOptionsData.value = model.data;
          _populateOptionsFromApi(model.data!);
        }
      }
    } catch (e) {
      debugPrint('Error in fetchCoApplicantFormOptions: $e');
    } finally {
      isLoadingFormOptions.value = false;
    }
  }

  void _populateOptionsFromApi(CoApplicantFormOptionsData data) {
    for (final field in data.addForm) {
      final name = field.name ?? '';
      final alias = field.alias ?? '';

      if (name == 'co_relationship' || alias == 'relationship') {
        if (field.options.isNotEmpty) {
          apiRelationshipOptions.assignAll(field.options);
        }
      } else if (name == 'applicant_type') {
        if (field.options.isNotEmpty) {
          apiApplicantTypeOptions.assignAll(field.options);
        }
        if (field.defaultValue != null && field.defaultValue!.isNotEmpty) {
          selectedApplicantType.value = field.defaultValue!;
        } else if (selectedApplicantType.value.isEmpty && field.options.isNotEmpty) {
          selectedApplicantType.value = field.options.first;
        }
      } else if (name == 'employment_type') {
        if (field.optionsByApplicantType.isNotEmpty) {
          apiOptionsByApplicantType.assignAll(field.optionsByApplicantType);
        }
      }
    }

    // Ensure valid employment type for selected applicant type
    if (selectedEmploymentType.value.isNotEmpty &&
        !currentEmploymentOptions.contains(selectedEmploymentType.value)) {
      selectedEmploymentType.value = '';
    }

    // Update dynamic documents based on current employment type (no static fallback)
    _updateDocumentsForEmploymentType(selectedEmploymentType.value);
  }

  /// Updates coAppDocuments strictly based on selected employment_type from API
  void _updateDocumentsForEmploymentType(String empType) {
    if (empType.trim().isEmpty) {
      coAppDocuments.clear();
      return;
    }

    final docsConfig = formOptionsData.value?.documents;
    if (docsConfig == null) {
      coAppDocuments.clear();
      return;
    }

    List<CoAppDocumentItem> matchedDocs = [];

    // Check directly in by_employment_type mapping from API
    if (docsConfig.byEmploymentType.containsKey(empType)) {
      matchedDocs = docsConfig.byEmploymentType[empType] ?? [];
    } else {
      // Case-insensitive / trimmed match against API keys
      final normalizedEmp = empType.trim().toLowerCase();
      for (final entry in docsConfig.byEmploymentType.entries) {
        if (entry.key.trim().toLowerCase() == normalizedEmp) {
          matchedDocs = entry.value;
          break;
        }
      }
    }

    if (matchedDocs.isNotEmpty) {
      final List<CoAppDocumentItem> expandedDocs = [];
      for (final doc in matchedDocs) {
        final key = doc.key ?? '';
        if (key == 'aadhar_card' || key == 'aadhaar_card') {
          // Store the original aadhaar doc item with upload_modes for later use
          _originalAadhaarDocItem = doc;

          // Check if upload_modes are available from API
          if (doc.uploadModes != null && doc.uploadModes!.isNotEmpty) {
            // Use the selected mode to expand
            if (selectedAadhaarUploadMode.value == 'combined') {
              final combinedMode = doc.uploadModes!.firstWhereOrNull((m) => m.key == 'combined');
              expandedDocs.add(
                CoAppDocumentItem(
                  key: 'aadhar_card_combined_pdf',
                  label: 'Aadhaar Card (Single PDF)',
                  allowMultiple: false,
                  acceptedFormats: combinedMode?.acceptedFormats.isNotEmpty == true
                      ? combinedMode!.acceptedFormats
                      : ['pdf'],
                  maxSizeMb: doc.maxSizeMb ?? 5,
                  uploadField: combinedMode?.fields.isNotEmpty == true
                      ? combinedMode!.fields.first
                      : 'documents[aadhar_card_combined_pdf]',
                  ocrAutofill: doc.ocrAutofill,
                  uploaded: false,
                  status: 'not_uploaded',
                ),
              );
            } else {
              final separateMode = doc.uploadModes!.firstWhereOrNull((m) => m.key == 'separate');
              final frontField = separateMode != null && separateMode.fields.isNotEmpty
                  ? separateMode.fields.first
                  : 'documents[aadhar_card_front]';
              final backField = separateMode != null && separateMode.fields.length > 1
                  ? separateMode.fields[1]
                  : 'documents[aadhar_card_back]';
              final formats = separateMode?.acceptedFormats.isNotEmpty == true
                  ? separateMode!.acceptedFormats
                  : (doc.acceptedFormats.isNotEmpty ? doc.acceptedFormats : ['pdf', 'jpg', 'jpeg', 'png']);

              expandedDocs.add(
                CoAppDocumentItem(
                  key: 'aadhar_card_front',
                  label: 'Aadhaar Card (Front)',
                  allowMultiple: false,
                  acceptedFormats: formats,
                  maxSizeMb: doc.maxSizeMb ?? 5,
                  uploadField: frontField,
                  ocrAutofill: true,
                  uploaded: false,
                  status: 'not_uploaded',
                ),
              );
              expandedDocs.add(
                CoAppDocumentItem(
                  key: 'aadhar_card_back',
                  label: 'Aadhaar Card (Back)',
                  allowMultiple: false,
                  acceptedFormats: formats,
                  maxSizeMb: doc.maxSizeMb ?? 5,
                  uploadField: backField,
                  ocrAutofill: true,
                  uploaded: false,
                  status: 'not_uploaded',
                ),
              );
            }
          } else {
            // No upload_modes — fallback to separate front/back
            expandedDocs.add(
              CoAppDocumentItem(
                key: 'aadhar_card_front',
                label: 'Aadhaar Card (Front)',
                allowMultiple: false,
                acceptedFormats: doc.acceptedFormats.isNotEmpty
                    ? doc.acceptedFormats
                    : ['pdf', 'jpg', 'jpeg', 'png'],
                maxSizeMb: doc.maxSizeMb ?? 5,
                uploadField: 'documents[aadhar_card_front]',
                ocrAutofill: true,
                uploaded: false,
                status: 'not_uploaded',
              ),
            );
            expandedDocs.add(
              CoAppDocumentItem(
                key: 'aadhar_card_back',
                label: 'Aadhaar Card (Back)',
                allowMultiple: false,
                acceptedFormats: doc.acceptedFormats.isNotEmpty
                    ? doc.acceptedFormats
                    : ['pdf', 'jpg', 'jpeg', 'png'],
                maxSizeMb: doc.maxSizeMb ?? 5,
                uploadField: 'documents[aadhar_card_back]',
                ocrAutofill: true,
                uploaded: false,
                status: 'not_uploaded',
              ),
            );
          }
        } else if (key == 'pan_card' || key == 'pan_card_image') {
          expandedDocs.add(
            CoAppDocumentItem(
              key: 'pan_card_image',
              label: 'PAN Card',
              allowMultiple: false,
              acceptedFormats: doc.acceptedFormats.isNotEmpty
                  ? doc.acceptedFormats
                  : ['pdf', 'jpg', 'jpeg', 'png'],
              maxSizeMb: doc.maxSizeMb ?? 5,
              uploadField: 'documents[pan_card_image]',
              ocrAutofill: true,
              uploaded: doc.uploaded,
              status: doc.status,
            ),
          );
        } else {
          expandedDocs.add(doc);
        }
      }
      coAppDocuments.assignAll(expandedDocs);
    } else {
      coAppDocuments.clear();
    }
  }

  /// Get active fields for Add Co-Applicant form strictly from API
  List<CoApplicantFormField> get activeAddFormFields {
    return formOptionsData.value?.addForm ?? [];
  }

  /// Whether the Aadhaar card has upload_modes from the API (supports mode switching)
  bool get hasAadhaarUploadModes =>
      _originalAadhaarDocItem?.uploadModes != null &&
      _originalAadhaarDocItem!.uploadModes!.length > 1;

  void addCoAppFile(String docKey, XFile file) {
    clearCoAppDocError(docKey);
    final currentList = List<XFile>.from(coAppUploadedFiles[docKey] ?? []);
    final docItem = coAppDocuments.firstWhereOrNull((d) => d.key == docKey);
    final isMulti = docItem?.allowMultiple == true;

    if (isMulti) {
      currentList.add(file);
    } else {
      currentList.clear();
      currentList.add(file);
    }
    coAppUploadedFiles[docKey] = currentList;
  }

  /// Sets document errors from API response for inline error display
  void _setDocumentErrors(Map<String, dynamic>? response) {
    coAppDocumentErrors.clear();
    if (response != null && response['errors'] is Map) {
      final errMap = response['errors'] as Map;
      errMap.forEach((k, v) {
        final keyStr = k.toString();
        final msg = v is List ? (v.isNotEmpty ? v.first.toString() : '') : v.toString();
        if (msg.isNotEmpty) {
          coAppDocumentErrors[keyStr] = msg;
          for (final doc in coAppDocuments) {
            final dKey = doc.key ?? '';
            if (dKey.isNotEmpty &&
                (keyStr == dKey ||
                    keyStr.contains(dKey) ||
                    (dKey.contains('aadhar') && keyStr.contains('aadhar')))) {
              coAppDocumentErrors[dKey] = msg;
            }
          }
        }
      });
    }
  }

  /// Clears document error for a specific document key
  void clearCoAppDocError(String docKey) {
    coAppDocumentErrors.remove(docKey);
    coAppDocumentErrors.removeWhere((k, _) =>
        k.contains(docKey) || (docKey.contains('aadhar') && k.contains('aadhar')));
  }

  /// Returns the API upload_field for a document key
  String getUploadFieldForDocKey(String docKey) {
    if (docKey == 'aadhar_card_front') return 'documents[aadhar_card_front]';
    if (docKey == 'aadhar_card_back') return 'documents[aadhar_card_back]';
    if (docKey == 'aadhar_card_combined_pdf') return 'documents[aadhar_card_combined_pdf]';
    if (docKey == 'pan_card' || docKey == 'pan_card_image') return 'documents[pan_card_image]';
    if (docKey == 'profile_image') return 'documents[profile_image]';

    final docItem = coAppDocuments.firstWhereOrNull((d) => d.key == docKey);
    if (docItem?.uploadField != null && docItem!.uploadField!.isNotEmpty) {
      return docItem.uploadField!;
    }
    if (docItem?.allowMultiple == true || docKey == 'bank_statement' || docKey == 'latest_salary_slips') {
      return 'co_multi_files[$docKey][]';
    }
    return 'documents[$docKey]';
  }

  /// Helper to upload all files in [coAppUploadedFiles] using each document's API upload_field
  Future<Map<String, dynamic>?> _uploadSelectedCoAppDocs(
      dynamic coApplicantId) async {
    if (coApplicantId == null || coAppUploadedFiles.isEmpty) return null;

    final Map<String, String> fieldMapping = {};
    for (final entry in coAppUploadedFiles.entries) {
      final k = entry.key;
      fieldMapping[k] = getUploadFieldForDocKey(k);
    }

    return ApiService.uploadCoApplicantDocuments(
      coApplicantId: coApplicantId,
      uploadedFiles: Map<String, List<XFile>>.from(coAppUploadedFiles),
      fieldMapping: fieldMapping,
    );
  }

  /// Upload a single document or sub-document immediately to the server
  Future<bool> uploadSingleDocOnServer({
    required dynamic coApplicantId,
    required String docKey,
    required XFile file,
    String? uploadField,
  }) async {
    uploadingDocKeys.add(docKey);
    clearCoAppDocError(docKey);
    try {
      final field = uploadField ?? getUploadFieldForDocKey(docKey);
      final res = await ApiService.uploadSingleCoApplicantDocument(
        coApplicantId: coApplicantId,
        file: file,
        uploadField: field,
      );

      if (res['success'] == true || res['status_code'] == 200) {
        if (res['data'] != null && res['data'] is Map<String, dynamic>) {
          final dataMap = res['data'] as Map<String, dynamic>;
          if (dataMap['documents'] is List) {
            updateDocumentsFromDeleteResponse(dataMap['documents'] as List);
          }
        }

        // Ensure local existing files state has this uploaded file
        final docItem = coAppDocuments.firstWhereOrNull((d) => d.key == docKey);
        final isMulti = docItem?.allowMultiple == true;
        final list = List<Map<String, dynamic>>.from(coAppExistingFiles[docKey] ?? []);
        if (isMulti) {
          list.add({
            'doc_key': docKey,
            'index': list.length,
            'name': file.name,
            'status': 'accepted',
          });
        } else {
          list.clear();
          list.add({
            'doc_key': docKey,
            'index': 0,
            'name': file.name,
            'status': 'accepted',
          });
        }
        coAppExistingFiles[docKey] = list;
        coAppExistingFiles.refresh();

        // Also refresh details and list in background
        fetchCoApplicants();
        fetchCoApplicantDetails(coApplicantId);

        Get.snackbar(
          'Success',
          res['message']?.toString() ?? 'Document uploaded successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return true;
      } else {
        _setDocumentErrors(res);
        final errorMsg = ApiService.getErrorMessage(res);
        Get.snackbar(
          'Upload Failed',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error in uploadSingleDocOnServer: $e');
      return false;
    } finally {
      uploadingDocKeys.remove(docKey);
    }
  }

  void removeCoAppFile(String docKey, [int? index]) {
    clearCoAppDocError(docKey);
    if (coAppUploadedFiles.containsKey(docKey) &&
        (coAppUploadedFiles[docKey]?.isNotEmpty == true)) {
      if (index != null && coAppUploadedFiles[docKey] != null) {
        final list = List<XFile>.from(coAppUploadedFiles[docKey]!);
        if (index >= 0 && index < list.length) {
          list.removeAt(index);
          if (list.isEmpty) {
            coAppUploadedFiles.remove(docKey);
          } else {
            coAppUploadedFiles[docKey] = list;
          }
        }
      } else {
        coAppUploadedFiles.remove(docKey);
      }
    } else if (coAppExistingFiles.containsKey(docKey) &&
        (coAppExistingFiles[docKey]?.isNotEmpty == true)) {
      if (index != null && coAppExistingFiles[docKey] != null) {
        final list = List<Map<String, dynamic>>.from(coAppExistingFiles[docKey]!);
        if (index >= 0 && index < list.length) {
          list.removeAt(index);
          if (list.isEmpty) {
            coAppExistingFiles.remove(docKey);
          } else {
            coAppExistingFiles[docKey] = list;
          }
        }
      } else {
        coAppExistingFiles.remove(docKey);
      }
    }
  }

  /// Delete co-applicant document from server API: POST {{baseUrl}}/co-applicants/{id}/documents/delete
  /// Dynamic form-data fields:
  /// - doc_key: document key e.g. bank_statement, aadhar_card_front, pan_card_image
  /// - index: position for multi-file documents e.g. 0
  Future<bool> deleteCoAppDocumentOnServer({
    required dynamic coApplicantId,
    required String docKey,
    dynamic index,
  }) async {
    isDeletingCoAppDoc.value = true;
    try {
      final res = await ApiService.deleteCoApplicantDocument(
        coApplicantId: coApplicantId,
        docKey: docKey,
        index: index,
      );

      if (res['success'] == true || res['status_code'] == 200) {
        // Close delete confirmation dialog first before showing snackbar
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        // Update documents dynamic state from API response data if provided
        if (res['data'] != null && res['data'] is Map<String, dynamic>) {
          final dataMap = res['data'] as Map<String, dynamic>;
          if (dataMap['documents'] is List) {
            updateDocumentsFromDeleteResponse(dataMap['documents'] as List);
          } else {
            removeCoAppFile(docKey, index is int ? index : int.tryParse(index?.toString() ?? ''));
          }
        } else {
          removeCoAppFile(docKey, index is int ? index : int.tryParse(index?.toString() ?? ''));
        }

        // Also refresh co-applicants details and list in background
        fetchCoApplicants();
        if (coApplicantId != null) {
          fetchCoApplicantDetails(coApplicantId);
        }

        Get.snackbar(
          'Success',
          res['message']?.toString() ?? 'Document deleted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return true;
      } else {
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        Get.snackbar(
          'Notice',
          ApiService.getErrorMessage(res),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.errorRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error in deleteCoAppDocumentOnServer: $e');
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      return false;
    } finally {
      isDeletingCoAppDoc.value = false;
    }
  }

  /// Updates coAppExistingFiles & coAppDocuments dynamically from delete/upload API response
  void updateDocumentsFromDeleteResponse(List<dynamic> apiDocs) {
    for (final docRaw in apiDocs) {
      if (docRaw is! Map) continue;
      final docMap = Map<String, dynamic>.from(docRaw);
      final key = docMap['key']?.toString() ?? '';
      if (key.isEmpty) continue;

      final isUploaded = docMap['uploaded'] == true;
      final filesRaw = docMap['files'] as List<dynamic>? ?? [];

      // Special handling for aadhar_card separate front & back
      if (key == 'aadhar_card' || key == 'aadhaar_card') {
        if (!isUploaded || filesRaw.isEmpty) {
          coAppExistingFiles.remove('aadhar_card_front');
          coAppExistingFiles.remove('aadhar_card_back');
        } else {
          bool hasFront = false;
          bool hasBack = false;
          for (int i = 0; i < filesRaw.length; i++) {
            final f = filesRaw[i];
            if (f is Map) {
              final subKey = f['doc_key']?.toString() ?? '';
              final isFront = subKey == 'aadhar_card_front' ||
                  (f['name']?.toString().toLowerCase().contains('front') ?? false) ||
                  i == 0;
              final target = isFront ? 'aadhar_card_front' : 'aadhar_card_back';
              if (isFront) hasFront = true;
              if (!isFront) hasBack = true;
              coAppExistingFiles[target] = [
                {
                  'doc_key': target,
                  'index': f['index'] ?? i,
                  'name': f['name'] ?? 'Aadhaar File',
                  'status': f['status'],
                  'url': f['url'],
                }
              ];
            }
          }
          if (!hasFront) coAppExistingFiles.remove('aadhar_card_front');
          if (!hasBack) coAppExistingFiles.remove('aadhar_card_back');
        }
        continue;
      }

      final targetKey = (key == 'pan_card' || key == 'pan_card_image') ? 'pan_card_image' : key;

      if (!isUploaded || filesRaw.isEmpty) {
        coAppExistingFiles.remove(targetKey);
      } else {
        final List<Map<String, dynamic>> newFileList = [];
        for (int i = 0; i < filesRaw.length; i++) {
          final f = filesRaw[i];
          if (f is Map) {
            newFileList.add({
              'doc_key': f['doc_key'] ?? targetKey,
              'index': f['index'] ?? i,
              'name': f['name'] ?? 'Document File',
              'status': f['status'],
              'url': f['url'],
            });
          }
        }
        coAppExistingFiles[targetKey] = newFileList;
      }

      // Also update coAppDocuments list if present
      final docItemIndex = coAppDocuments.indexWhere((d) => d.key == targetKey);
      if (docItemIndex != -1) {
        final current = coAppDocuments[docItemIndex];
        coAppDocuments[docItemIndex] = CoAppDocumentItem(
          key: current.key,
          label: docMap['label']?.toString() ?? current.label,
          allowMultiple: current.allowMultiple,
          acceptedFormats: current.acceptedFormats,
          maxSizeMb: current.maxSizeMb,
          uploadField: current.uploadField,
          ocrAutofill: current.ocrAutofill,
          uploaded: isUploaded,
          status: docMap['status']?.toString() ?? current.status,
          files: filesRaw,
        );
      }
    }
    coAppExistingFiles.refresh();
    coAppDocuments.refresh();
  }

  /// Get relationship options strictly from API
  List<String> get currentRelationshipOptions {
    return apiRelationshipOptions;
  }

  /// Get applicant type options strictly from API
  List<String> get currentApplicantTypeOptions {
    return apiApplicantTypeOptions;
  }

  /// Get dynamic employment options strictly from API based on currently selected applicant type
  List<String> get currentEmploymentOptions {
    if (apiOptionsByApplicantType.isNotEmpty) {
      final opts = apiOptionsByApplicantType[selectedApplicantType.value];
      if (opts != null && opts.isNotEmpty) {
        return opts;
      }
    }
    return [];
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
  }

  void selectRole(String role) {
    selectedRole.value = role;
  }

  void selectRelationship(String rel) {
    selectedRelationship.value = rel;
  }

  void selectApplicantType(String type) {
    if (selectedApplicantType.value != type) {
      selectedApplicantType.value = type;
      // Reset selected employment type if not in the new valid list
      if (!currentEmploymentOptions.contains(selectedEmploymentType.value)) {
        selectedEmploymentType.value = '';
      }
      _updateDocumentsForEmploymentType(selectedEmploymentType.value);
    }
  }

  void selectEmploymentType(String type) {
    selectedEmploymentType.value = type;
    _updateDocumentsForEmploymentType(type);
  }

  /// Submit Co-Applicant API: POST {{baseUrl}}/co-applicants
  Future<bool> addCoApplicant({String? role}) async {
    // Validate text form fields only when submit button is pressed
    if (addCoAppFormKey.currentState?.validate() != true) {
      return false;
    }

    final name = fullNameController.text.trim();
    final rawMobile = mobileNumberController.text.trim();
    final mobile = rawMobile.replaceAll(RegExp(r'[^0-9]'), '');
    final relationship = selectedRelationship.value.trim();
    final appType = selectedApplicantType.value.trim();
    final empType = selectedEmploymentType.value.trim();
    final assignedRole = role ?? selectedRole.value;

    if (relationship.isEmpty || empType.isEmpty) {
      return false;
    }

    final activeLeadId = currentLeadId;
    if (activeLeadId == null) {
      Get.snackbar(
        'Notice',
        'Lead ID not found. Please submit your application first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    isAddingCoApplicant.value = true;
    try {
      final res = await ApiService.addCoApplicant(
        coApplicantName: name,
        coApplicantMobile: mobile,
        coRelationship: relationship,
        applicantType: appType,
        employmentType: empType,
        leadId: activeLeadId,
      );

      if (res['status_code'] == 200 || res['status_code'] == 201 || res['success'] == true) {
        final model = AddCoApplicantResponseModel.fromJson(res);

        // Store OTP and expiry from add co-applicant API response
        if (model.data?.otp != null) {
          lastCoAppOtp.value = model.data!.otp;
          lastCoAppOtpExpiresAt.value = model.data?.otpExpiresAt;
          debugPrint('Co-Applicant OTP received: ${model.data!.otp}');
        }

        // Directly store all document options returned in the API response
        // but expand aadhaar_card based on selected upload mode
        if (model.data?.documents.isNotEmpty == true) {
          final List<CoAppDocumentItem> expandedApiDocs = [];
          for (final doc in model.data!.documents) {
            final key = doc.key ?? '';
            if (key == 'aadhar_card' || key == 'aadhaar_card') {
              // Store original and expand based on selected mode
              _originalAadhaarDocItem = doc;
              if (selectedAadhaarUploadMode.value == 'combined') {
                final combinedMode = doc.uploadModes?.firstWhereOrNull((m) => m.key == 'combined');
                expandedApiDocs.add(
                  CoAppDocumentItem(
                    key: 'aadhar_card_combined_pdf',
                    label: 'Aadhaar Card (Single PDF)',
                    allowMultiple: false,
                    acceptedFormats: combinedMode?.acceptedFormats.isNotEmpty == true
                        ? combinedMode!.acceptedFormats
                        : ['pdf'],
                    maxSizeMb: doc.maxSizeMb ?? 5,
                    uploadField: combinedMode?.fields.isNotEmpty == true
                        ? combinedMode!.fields.first
                        : 'documents[aadhar_card_combined_pdf]',
                    ocrAutofill: doc.ocrAutofill,
                    uploaded: false,
                    status: 'not_uploaded',
                  ),
                );
              } else {
                final separateMode = doc.uploadModes?.firstWhereOrNull((m) => m.key == 'separate');
                final frontField = separateMode != null && separateMode.fields.isNotEmpty
                    ? separateMode.fields.first
                    : 'documents[aadhar_card_front]';
                final backField = separateMode != null && separateMode.fields.length > 1
                    ? separateMode.fields[1]
                    : 'documents[aadhar_card_back]';
                final formats = separateMode?.acceptedFormats.isNotEmpty == true
                    ? separateMode!.acceptedFormats
                    : (doc.acceptedFormats.isNotEmpty ? doc.acceptedFormats : ['pdf', 'jpg', 'jpeg', 'png']);

                expandedApiDocs.add(
                  CoAppDocumentItem(
                    key: 'aadhar_card_front',
                    label: 'Aadhaar Card (Front)',
                    allowMultiple: false,
                    acceptedFormats: formats,
                    maxSizeMb: doc.maxSizeMb ?? 5,
                    uploadField: frontField,
                    ocrAutofill: true,
                    uploaded: false,
                    status: 'not_uploaded',
                  ),
                );
                expandedApiDocs.add(
                  CoAppDocumentItem(
                    key: 'aadhar_card_back',
                    label: 'Aadhaar Card (Back)',
                    allowMultiple: false,
                    acceptedFormats: formats,
                    maxSizeMb: doc.maxSizeMb ?? 5,
                    uploadField: backField,
                    ocrAutofill: true,
                    uploaded: false,
                    status: 'not_uploaded',
                  ),
                );
              }
            } else {
              expandedApiDocs.add(doc);
            }
          }
          coAppDocuments.assignAll(expandedApiDocs);
        }

        coApplicants.add(
          CoApplicantModel(
            id: model.data?.coApplicantId ?? model.data?.coApplicant?.id,
            name: model.data?.coApplicant?.name ?? name,
            relationship: model.data?.coApplicant?.relationship ?? relationship,
            mobileNumber: mobile.startsWith('+91') ? mobile : '+91 $mobile',
            applicantType: model.data?.applicantType ?? appType,
            employmentType: model.data?.employmentType ?? empType,
            role: assignedRole,
            status: 'Documents pending',
            documents: List<CoAppDocumentItem>.from(model.data?.documents ?? coAppDocuments),
            uploadedFiles: Map.from(coAppUploadedFiles),
          ),
        );

        // Upload selected documents via dedicated /co-applicants/{id}/documents/upload API
        String successMsg =
            res['message']?.toString() ?? 'Co-Applicant added successfully!';
        final createdCoAppId =
            model.data?.coApplicantId ?? model.data?.coApplicant?.id;

        if (createdCoAppId != null) {
          currentDraftCoAppId.value = createdCoAppId;
        }

        if (createdCoAppId != null && coAppUploadedFiles.isNotEmpty) {
          final uploadRes = await _uploadSelectedCoAppDocs(createdCoAppId);
          final isUploadOk = uploadRes != null &&
              (uploadRes['success'] == true ||
                  uploadRes['status_code'] == 200 ||
                  uploadRes['status_code'] == 201);

          if (!isUploadOk) {
            _setDocumentErrors(uploadRes);
            final errorMsg = ApiService.getErrorMessage(uploadRes);
            Get.snackbar(
              'Document Upload Failed',
              errorMsg,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.errorRed,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            );
            // Refresh co-applicants list in background so draft is saved
            fetchCoApplicants();
            // DO NOT reset form fields, DO NOT pop screen, RETURN FALSE!
            return false;
          }

          if (uploadRes['message'] != null &&
              uploadRes['message'].toString().isNotEmpty) {
            successMsg = uploadRes['message'].toString();
          }
        }

        // Upload succeeded or no documents were attached
        currentDraftCoAppId.value = null;
        coAppDocumentErrors.clear();

        // Refresh co-applicants list and applicant details
        fetchCoApplicants();
        fetchApplicantDetails();

        // Switch tab to the Co-applicant tab so the newly added co-applicant shows
        selectedTabIndex.value = 1;

        // Reset controllers and uploaded files for next time
        fullNameController.clear();
        mobileNumberController.clear();
        selectedRelationship.value = '';
        selectedApplicantType.value = '';
        selectedEmploymentType.value = '';
        coAppUploadedFiles.clear();

        Future.delayed(const Duration(milliseconds: 150), () {
          Get.snackbar(
            'Success',
            successMsg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.successGreen,
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
          );
        });
        return true;
      } else {
        final msg = ApiService.getErrorMessage(res);
        Get.snackbar(
          'Notice',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      debugPrint('Exception in addCoApplicant: $e');
      Get.snackbar(
        'Notice',
        'Failed to add co-applicant. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isAddingCoApplicant.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    mobileNumberController.dispose();
    super.onClose();
  }
}
