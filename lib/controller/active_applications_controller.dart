import 'package:get/get.dart';
import '../models/active_application_model.dart';

/// GetX controller managing the active loan applications state,
/// filtering, and future API integration.
class ActiveApplicationsController extends GetxController {
  // Observables
  final applications = <ActiveApplicationModel>[].obs;
  final selectedFilterIndex = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchApplications();
  }

  /// Sets the selected filter tab index (0: All, 1: In review, 2: Approved)
  void setFilter(int index) {
    selectedFilterIndex.value = index;
  }

  /// Computed list based on active filter index
  List<ActiveApplicationModel> get filteredApplications {
    if (selectedFilterIndex.value == 1) {
      return applications
          .where((app) => app.statusType == ApplicationStatusType.inReview)
          .toList();
    }
    if (selectedFilterIndex.value == 2) {
      return applications
          .where((app) => app.statusType == ApplicationStatusType.approved)
          .toList();
    }
    return applications;
  }

  int get totalCount => applications.length;

  int get inReviewCount => applications
      .where((a) => a.statusType == ApplicationStatusType.inReview)
      .length;

  int get approvedCount => applications
      .where((a) => a.statusType == ApplicationStatusType.approved)
      .length;

  /// Fetches active applications. Formatted via [ActiveApplicationModel.fromJson]
  /// for seamless future direct REST API backend integration.
  Future<void> fetchApplications() async {
    isLoading.value = true;

    try {
      // Mock API JSON payload ready for direct network integration:
      final List<Map<String, dynamic>> mockApiData = [
        {
          'id': '#FIN-HL-8924',
          'title': 'Home loan',
          'loan_type': 'home_loan',
          'amount': '₹14,50,000',
          'tenure': '15 years',
          'emi': '₹14,850/mo',
          'progress': 0.48,
          'progress_percent': '48%',
          'current_step': 'Step 3 of 6 • Credit report',
          'status': 'inReview',
          'applied_date': '12 Nov 2026',
        },
        {
          'id': '#FIN-PL-4102',
          'title': 'Personal loan',
          'loan_type': 'personal_loan',
          'amount': '₹3,00,000',
          'tenure': '3 years',
          'emi': '₹9,960/mo',
          'progress': 0.75,
          'progress_percent': '75%',
          'current_step': 'Step 4 of 6 • Income verification',
          'status': 'inReview',
          'applied_date': '14 Nov 2026',
        },
        {
          'id': '#FIN-AL-3019',
          'title': 'Auto loan',
          'loan_type': 'auto_loan',
          'amount': '₹6,50,000',
          'tenure': '5 years',
          'emi': '₹13,520/mo',
          'progress': 1.0,
          'progress_percent': '100%',
          'current_step': 'Step 6 of 6 • Sanction letter ready',
          'status': 'approved',
          'applied_date': '08 Nov 2026',
        },
      ];

      // Parse JSON list into strongly typed models
      final parsed = mockApiData
          .map((json) => ActiveApplicationModel.fromJson(json))
          .toList();

      applications.assignAll(parsed);
    } finally {
      isLoading.value = false;
    }
  }

  /// Refreshes applications from backend
  Future<void> refreshApplications() async {
    await fetchApplications();
  }
}
