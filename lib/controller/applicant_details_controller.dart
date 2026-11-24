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

  dynamic get currentLeadId {
    if (leadId.value != null) return leadId.value;
    if (Get.isRegistered<ApplyLoanController>()) {
      return Get.find<ApplyLoanController>().leadStoreData.value?.leadId;
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

  // List of co-applicants from API (GET /co-applicants)
  final isLoadingCoApplicants = false.obs;
  final coApplicantsList = <CoApplicantItem>[].obs;
  final coApplicants = <CoApplicantModel>[].obs;

  // Primary Applicant Details API state (GET /applicants/{id})
  final isLoadingApplicantDetails = false.obs;
  final applicantDetailsData = Rxn<ApplicantDetailModel>();

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
  }

  /// Reset form fields when opening add screen fresh
  void resetAddCoApplicantForm() {
    editingCoApplicantId.value = null;
    fullNameController.clear();
    mobileNumberController.clear();
    selectedRelationship.value = '';
    selectedApplicantType.value = apiApplicantTypeOptions.isNotEmpty ? apiApplicantTypeOptions.first : 'Financial';
    selectedEmploymentType.value = '';
    coAppDocuments.clear();
    coAppUploadedFiles.clear();
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
        Get.snackbar(
          'Success',
          res['message']?.toString() ?? 'Co-Applicant updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );

        fetchCoApplicants();
        resetAddCoApplicantForm();
        Get.back();
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
  }

  /// Get active fields for Add Co-Applicant form strictly from API
  List<CoApplicantFormField> get activeAddFormFields {
    return formOptionsData.value?.addForm ?? [];
  }

  void addCoAppFile(String docKey, XFile file) {
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

  void removeCoAppFile(String docKey, [int? index]) {
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
    }
  }

  void selectEmploymentType(String type) {
    selectedEmploymentType.value = type;
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

        // Directly store all document options returned in the API response
        if (model.data?.documents.isNotEmpty == true) {
          coAppDocuments.assignAll(model.data!.documents);
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

        Get.snackbar(
          'Success',
          res['message']?.toString() ?? 'Co-Applicant added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.successGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );

        // Refresh co-applicants list from GET /co-applicants
        fetchCoApplicants();

        // Switch tab to the newly added co-applicant
        selectedTabIndex.value = 1;

        // Reset controllers and uploaded files for next time
        fullNameController.clear();
        mobileNumberController.clear();
        selectedRelationship.value = '';
        selectedApplicantType.value = formOptionsData.value?.addForm
                .firstWhereOrNull((f) => f.name == 'applicant_type')
                ?.defaultValue ??
            (apiApplicantTypeOptions.isNotEmpty ? apiApplicantTypeOptions.first : '');
        selectedEmploymentType.value = '';
        coAppUploadedFiles.clear();

        Get.back(); // Pop Add Co-applicant screen
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
