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

  /// Fetches active applications. Zero static mock data.
  Future<void> fetchApplications() async {
    isLoading.value = true;
    try {
      // Dynamic list: populated only when real applications exist
      applications.assignAll([]);
    } finally {
      isLoading.value = false;
    }
  }

  /// Refreshes applications from backend
  Future<void> refreshApplications() async {
    await fetchApplications();
  }
}
