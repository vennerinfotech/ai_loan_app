import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/active_application_model.dart';
import '../models/active_loan_applications_model.dart';
import '../models/applicant_detail_model.dart';
import '../services/api_service.dart';

/// GetX controller managing the active loan applications state,
/// filtering, and real API integration from GET /loan-applications/active.
class ActiveApplicationsController extends GetxController {
  // Observables
  final applications = <ActiveApplicationModel>[].obs;
  final rawApplications = <ApplicantLoanApplication>[].obs;
  final activeStatuses = <ActiveStatusItem>[].obs;
  final pagination = Rxn<ActiveApplicationsPagination>();
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

  /// Fetches active applications strictly from GET {{baseUrl}}/loan-applications/active.
  Future<void> fetchApplications() async {
    isLoading.value = true;
    try {
      final res = await ApiService.getActiveLoanApplications();
      if (res['success'] == true || res['status_code'] == 200) {
        final data = ActiveLoanApplicationsResponseData.fromJson(res);
        rawApplications.assignAll(data.loanApplications);
        activeStatuses.assignAll(data.activeStatuses);
        pagination.value = data.pagination;

        // Map into UI models
        final uiModels = data.loanApplications.map(_mapToUiModel).toList();
        applications.assignAll(uiModels);
      } else {
        debugPrint('Notice in fetchApplications: ${res['message']}');
        applications.clear();
      }
    } catch (e) {
      debugPrint('Error in fetchApplications: $e');
      applications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Maps an [ApplicantLoanApplication] API item to UI [ActiveApplicationModel]
  ActiveApplicationModel _mapToUiModel(ApplicantLoanApplication app) {
    final statusRaw = (app.status ?? '').toLowerCase().trim();
    final statusLabel = app.statusLabel ?? app.status ?? 'In Process';

    ApplicationStatusType type;
    if (statusRaw == 'sanction' || statusRaw == 'approved' || statusRaw == 'disbursed') {
      type = ApplicationStatusType.approved;
    } else if (statusRaw == 'rejected') {
      type = ApplicationStatusType.rejected;
    } else if (statusRaw == 'pending' || statusRaw == 'document_pending') {
      type = ApplicationStatusType.pending;
    } else {
      type = ApplicationStatusType.inReview;
    }

    // Format currency
    final amountNum = app.loanAmount ?? app.bankDetails?.sanctionedAmount ?? 0;
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final formattedAmount = currencyFormatter.format(amountNum);

    // Format tenure & EMI
    final tenureMonths = app.bankDetails?.tenureMonths;
    final tenureText = tenureMonths != null && tenureMonths > 0
        ? (tenureMonths >= 12 && tenureMonths % 12 == 0
            ? '${tenureMonths ~/ 12} Yrs'
            : '$tenureMonths Mos')
        : '36 Mos';

    final emiNum = app.bankDetails?.emi;
    final emiText = emiNum != null && emiNum > 0
        ? currencyFormatter.format(emiNum)
        : '-';

    // Format applied date
    String appliedDate = '-';
    if (app.createdAt != null && app.createdAt!.isNotEmpty) {
      try {
        final parsed = DateTime.parse(app.createdAt!);
        appliedDate = DateFormat('dd MMM yyyy').format(parsed.toLocal());
      } catch (_) {
        appliedDate = app.createdAt!;
      }
    }

    // Progress estimation based on status
    double progress = 0.5;
    String progressPercent = '50%';
    if (type == ApplicationStatusType.approved) {
      progress = 0.9;
      progressPercent = '90%';
    } else if (statusRaw == 'document_pending') {
      progress = 0.3;
      progressPercent = '30%';
    } else if (statusRaw == 'in_process' || statusRaw == 'submitted') {
      progress = 0.65;
      progressPercent = '65%';
    }

    final appIdStr = app.loanApplicationNumber != null && app.loanApplicationNumber!.isNotEmpty
        ? app.loanApplicationNumber!
        : (app.id != null ? 'APP-${app.id}' : 'APP-01');

    return ActiveApplicationModel(
      id: appIdStr,
      title: app.loanType ?? 'Loan Application',
      loanType: app.loanType ?? 'Personal Loan',
      amount: formattedAmount,
      tenure: tenureText,
      emi: emiText,
      progress: progress,
      progressPercent: progressPercent,
      currentStep: statusLabel,
      statusType: type,
      appliedDate: appliedDate,
    );
  }

  /// Refreshes applications from backend
  Future<void> refreshApplications() async {
    await fetchApplications();
  }
}
