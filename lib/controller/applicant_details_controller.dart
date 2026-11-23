import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/co_applicant_form_options_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

/// Co-applicant data model
class CoApplicantModel {
  final String name;
  final String relationship;
  final String mobileNumber;
  final String applicantType;
  final String employmentType;
  final String role; // 'Co-Applicant' or 'Guarantor'
  final String dob;
  final String monthlyIncome;
  final String status;
  final Map<String, List<XFile>> documents;

  CoApplicantModel({
    required this.name,
    required this.relationship,
    required this.mobileNumber,
    this.applicantType = '',
    this.employmentType = '',
    this.role = 'Co-Applicant',
    this.dob = '',
    this.monthlyIncome = '',
    this.status = 'Documents attached',
    this.documents = const {},
  });
}

/// Helper model for dynamic co-applicant document upload items
class CoAppDocumentConfigItem {
  final String key;
  final String label;
  final bool isMulti;
  final List<String> acceptedFormats;
  final int maxSizeMb;

  CoAppDocumentConfigItem({
    required this.key,
    required this.label,
    this.isMulti = false,
    this.acceptedFormats = const ['pdf', 'jpg', 'jpeg', 'png'],
    this.maxSizeMb = 5,
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

  // Dynamic Options strictly from GET /co-applicants/form-options API
  final apiRelationshipOptions = <String>[].obs;
  final apiApplicantTypeOptions = <String>[].obs;
  final apiOptionsByApplicantType = <String, List<String>>{}.obs;

  // Uploaded files for the co-applicant being added
  final coAppUploadedFiles = <String, List<XFile>>{}.obs;

  // List of co-applicants
  final coApplicants = <CoApplicantModel>[].obs;

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

  /// Dynamic document items to upload based on API documents options and employment type
  List<CoAppDocumentConfigItem> get dynamicCoAppDocuments {
    final docsConfig = formOptionsData.value?.documents;
    if (docsConfig == null) {
      return [];
    }

    final accepted = docsConfig.acceptedFormats.isNotEmpty
        ? docsConfig.acceptedFormats
        : ['pdf', 'jpg', 'jpeg', 'png'];
    final profileFormats = docsConfig.profileImageFormats.isNotEmpty
        ? docsConfig.profileImageFormats
        : ['jpg', 'jpeg', 'png'];
    final maxSize = docsConfig.maxSizeMb ?? 5;
    final multiKeys = docsConfig.multiFileKeys;

    final List<CoAppDocumentConfigItem> list = [
      CoAppDocumentConfigItem(
        key: 'profile_image',
        label: selectedRole.value.toLowerCase() == 'guarantor'
            ? 'Guarantor Photo'
            : 'Co-Applicant Photo',
        isMulti: false,
        acceptedFormats: profileFormats,
        maxSizeMb: maxSize,
      ),
      CoAppDocumentConfigItem(
        key: 'aadhar_card',
        label: 'Aadhaar Card',
        isMulti: false,
        acceptedFormats: accepted,
        maxSizeMb: maxSize,
      ),
      CoAppDocumentConfigItem(
        key: 'pan_card',
        label: 'PAN Card',
        isMulti: false,
        acceptedFormats: accepted,
        maxSizeMb: maxSize,
      ),
    ];

    final empType = selectedEmploymentType.value.toLowerCase().trim();

    if (empType == 'salaried') {
      list.add(CoAppDocumentConfigItem(
        key: 'bank_statement',
        label: 'Bank Statement (Last 6 Months)',
        isMulti: multiKeys.contains('bank_statement'),
        acceptedFormats: accepted,
        maxSizeMb: maxSize,
      ));
      list.add(CoAppDocumentConfigItem(
        key: 'latest_salary_slips',
        label: 'Salary Slips (Last 3 Months)',
        isMulti: multiKeys.contains('latest_salary_slips'),
        acceptedFormats: accepted,
        maxSizeMb: maxSize,
      ));
      list.add(CoAppDocumentConfigItem(
        key: 'form_16_itr',
        label: 'Form 16 / ITR',
        isMulti: multiKeys.contains('form_16_itr'),
        acceptedFormats: accepted,
        maxSizeMb: maxSize,
      ));
    } else if (empType == 'self-employed') {
      list.add(CoAppDocumentConfigItem(
        key: 'bank_statement',
        label: 'Bank Statement (Last 12 Months)',
        isMulti: multiKeys.contains('bank_statement'),
        acceptedFormats: accepted,
        maxSizeMb: maxSize,
      ));
      list.add(CoAppDocumentConfigItem(
        key: 'form_16_itr',
        label: 'ITR / Financial Statements',
        isMulti: multiKeys.contains('form_16_itr'),
        acceptedFormats: accepted,
        maxSizeMb: maxSize,
      ));
      list.add(CoAppDocumentConfigItem(
        key: 'gst_3b',
        label: 'GST Return / Business Proof',
        isMulti: multiKeys.contains('gst_3b'),
        acceptedFormats: accepted,
        maxSizeMb: maxSize,
      ));
    } else if (empType == 'freelancer' || empType == 'pensioner') {
      list.add(CoAppDocumentConfigItem(
        key: 'bank_statement',
        label: 'Bank Statement',
        isMulti: multiKeys.contains('bank_statement'),
        acceptedFormats: accepted,
        maxSizeMb: maxSize,
      ));
      list.add(CoAppDocumentConfigItem(
        key: 'other_doc',
        label: 'Income / Pension Proof / Other Document',
        isMulti: multiKeys.contains('other_doc'),
        acceptedFormats: accepted,
        maxSizeMb: maxSize,
      ));
    } else if (empType.isNotEmpty) {
      list.add(CoAppDocumentConfigItem(
        key: 'other_doc',
        label: 'Other Supporting Document',
        isMulti: multiKeys.contains('other_doc'),
        acceptedFormats: accepted,
        maxSizeMb: maxSize,
      ));
    }

    return list;
  }

  void addCoAppFile(String docKey, XFile file) {
    final currentList = List<XFile>.from(coAppUploadedFiles[docKey] ?? []);
    final multiKeys = formOptionsData.value?.documents?.multiFileKeys ?? [];
    final isMulti = multiKeys.contains(docKey);

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

  void addCoApplicant({String? role}) {
    // Validate text form fields only when submit button is pressed
    if (addCoAppFormKey.currentState?.validate() != true) {
      return;
    }

    final name = fullNameController.text.trim();
    final mobile = mobileNumberController.text.trim();
    final relationship = selectedRelationship.value.trim();
    final appType = selectedApplicantType.value.trim();
    final empType = selectedEmploymentType.value.trim();
    final assignedRole = role ?? selectedRole.value;

    if (relationship.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please select relationship to applicant',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (empType.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please select employment type',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    coApplicants.add(
      CoApplicantModel(
        name: name,
        relationship: relationship,
        mobileNumber: mobile.startsWith('+91') ? mobile : '+91 $mobile',
        applicantType: appType,
        employmentType: empType,
        role: assignedRole,
        status: coAppUploadedFiles.isNotEmpty ? 'Documents attached' : 'Link sent',
        documents: Map.from(coAppUploadedFiles),
      ),
    );

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
  }

  @override
  void onClose() {
    fullNameController.dispose();
    mobileNumberController.dispose();
    super.onClose();
  }
}
