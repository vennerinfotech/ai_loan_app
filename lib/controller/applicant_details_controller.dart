import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

/// Co-applicant data model
class CoApplicantModel {
  final String name;
  final String relationship;
  final String mobileNumber;
  final String dob;
  final String monthlyIncome;
  final String status;

  CoApplicantModel({
    required this.name,
    required this.relationship,
    required this.mobileNumber,
    this.dob = '22 Oct 1995',
    this.monthlyIncome = '₹ 65,000',
    this.status = 'Link sent',
  });
}

/// Controller managing Applicant and Co-applicant state
class ApplicantDetailsController extends GetxController {
  // 0 = Primary Applicant, 1 = Co-applicant
  final selectedTabIndex = 0.obs;

  // List of co-applicants
  final coApplicants = <CoApplicantModel>[
    CoApplicantModel(
      name: 'Saanvi Mehta',
      relationship: 'Spouse',
      mobileNumber: '+91 98765 43210',
      dob: '22 Oct 1995',
      monthlyIncome: '₹ 65,000',
      status: 'Link sent',
    ),
  ].obs;

  // Form fields for Add Co-applicant screen
  final selectedRelationship = 'Spouse'.obs;
  final fullNameController = TextEditingController(text: 'Saanvi Mehta');
  final mobileNumberController = TextEditingController(text: '98765 43210');
  final dobController = TextEditingController();
  final incomeController = TextEditingController();

  final relationshipOptions = [
    'Spouse',
    'Parent',
    'Sibling',
    'Business partner',
  ];

  void selectTab(int index) {
    selectedTabIndex.value = index;
  }

  void selectRelationship(String rel) {
    selectedRelationship.value = rel;
  }

  void addCoApplicant() {
    final name = fullNameController.text.trim().isEmpty
        ? 'Saanvi Mehta'
        : fullNameController.text.trim();
    final mobile = mobileNumberController.text.trim().isEmpty
        ? '+91 98765 43210'
        : '+91 ${mobileNumberController.text.trim()}';
    final dob = dobController.text.trim().isEmpty
        ? '22 Oct 1995'
        : dobController.text.trim();
    final income = incomeController.text.trim().isEmpty
        ? '₹ 65,000'
        : '₹ ${incomeController.text.trim()}';

    coApplicants.add(
      CoApplicantModel(
        name: name,
        relationship: selectedRelationship.value,
        mobileNumber: mobile,
        dob: dob,
        monthlyIncome: income,
        status: 'Link sent',
      ),
    );

    // Switch tab to the newly added co-applicant
    selectedTabIndex.value = 1;

    // Reset controllers for next time
    fullNameController.text = '';
    mobileNumberController.text = '';
    dobController.text = '';
    incomeController.text = '';

    Get.back(); // Pop Add Co-applicant screen
  }

  @override
  void onClose() {
    // Keep controllers safe from disposal crashes
    super.onClose();
  }
}
