import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

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

  CoApplicantModel({
    required this.name,
    required this.relationship,
    required this.mobileNumber,
    this.applicantType = 'Financial',
    this.employmentType = 'Salaried',
    this.role = 'Co-Applicant',
    this.dob = '22 Oct 1995',
    this.monthlyIncome = '₹ 65,000',
    this.status = 'Link sent',
  });
}

/// Controller managing Applicant and Co-applicant state
class ApplicantDetailsController extends GetxController {
  // 0 = Primary Applicant, 1 = Co-applicant
  final selectedTabIndex = 0.obs;

  // Selected role when adding: 'Co-Applicant' or 'Guarantor'
  final selectedRole = 'Co-Applicant'.obs;

  // List of co-applicants
  final coApplicants = <CoApplicantModel>[
    CoApplicantModel(
      name: 'Saanvi Mehta',
      relationship: 'Spouse',
      mobileNumber: '+91 98765 43210',
      applicantType: 'Financial',
      employmentType: 'Salaried',
      role: 'Co-Applicant',
      dob: '22 Oct 1995',
      monthlyIncome: '₹ 65,000',
      status: 'Link sent',
    ),
  ].obs;

  // Form key for Add Co-Applicant screen validation
  final addCoAppFormKey = GlobalKey<FormState>();

  // Form fields for Add Co-applicant screen
  final fullNameController = TextEditingController();
  final mobileNumberController = TextEditingController();
  final selectedRelationship = ''.obs;
  final selectedApplicantType = 'Financial'.obs;
  final selectedEmploymentType = ''.obs;

  // Options for Relationship dropdown
  final relationshipOptions = const [
    'Father',
    'Mother',
    'Spouse',
    'Brother',
    'Sister',
    'Son',
    'Daughter',
    'Other',
  ];

  // Options for Applicant Type dropdown
  final applicantTypeOptions = const [
    'Financial',
    'Non-Financial',
  ];

  // Options for Employment Type (Financial)
  final financialEmploymentOptions = const [
    'Salaried',
    'Self-Employed',
    'Freelancer',
    'Pensioner',
  ];

  // Options for Employment Type (Non-Financial)
  final nonFinancialEmploymentOptions = const [
    'Housewife',
    'Retired',
    'Other',
  ];

  /// Get dynamic employment options based on currently selected applicant type
  List<String> get currentEmploymentOptions {
    if (selectedApplicantType.value == 'Non-Financial') {
      return nonFinancialEmploymentOptions;
    }
    return financialEmploymentOptions;
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
    // Validate all form fields using Form validation
    if (addCoAppFormKey.currentState?.validate() != true) {
      return;
    }

    final name = fullNameController.text.trim();
    final mobile = mobileNumberController.text.trim();
    final relationship = selectedRelationship.value;
    final appType = selectedApplicantType.value;
    final empType = selectedEmploymentType.value;
    final assignedRole = role ?? selectedRole.value;

    coApplicants.add(
      CoApplicantModel(
        name: name,
        relationship: relationship,
        mobileNumber: mobile.startsWith('+91') ? mobile : '+91 $mobile',
        applicantType: appType,
        employmentType: empType,
        role: assignedRole,
        status: 'Link sent',
      ),
    );

    // Switch tab to the newly added co-applicant
    selectedTabIndex.value = 1;

    // Reset controllers for next time
    fullNameController.clear();
    mobileNumberController.clear();
    selectedRelationship.value = '';
    selectedApplicantType.value = 'Financial';
    selectedEmploymentType.value = '';

    Get.back(); // Pop Add Co-applicant screen
  }

  @override
  void onClose() {
    fullNameController.dispose();
    mobileNumberController.dispose();
    super.onClose();
  }
}
