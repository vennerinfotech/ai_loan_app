import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/active_application_model.dart';
import '../models/active_loan_applications_model.dart';
import '../models/applicant_detail_model.dart';
import '../services/api_service.dart';

/// GetX controller managing the active loan applications state,
/// pagination, filtering, and real API integration from GET /loan-applications/active.
class ActiveApplicationsController extends GetxController {
  // Observables
  final applications = <ActiveApplicationModel>[].obs;
  final rawApplications = <ApplicantLoanApplication>[].obs;
  final activeStatuses = <ActiveStatusItem>[].obs;
  final pagination = Rxn<ActiveApplicationsPagination>();
  final selectedFilterIndex = 0.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final currentPage = 1.obs;
  final int perPage = 7;

  late final ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    fetchApplications();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    if (maxScroll - currentScroll <= 150) {
      loadMoreApplications();
    }
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

  int get totalCount => pagination.value?.total ?? applications.length;

  int get inReviewCount => applications
      .where((a) => a.statusType == ApplicationStatusType.inReview)
      .length;

  int get approvedCount => applications
      .where((a) => a.statusType == ApplicationStatusType.approved)
      .length;

  /// Fetches initial page (page 1) strictly from GET {{baseUrl}}/loan-applications/active.
  Future<void> fetchApplications({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMore.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final res = await ApiService.getActiveLoanApplications(
        page: 1,
        perPage: perPage,
      );
      if (res['success'] == true || res['status_code'] == 200) {
        final data = ActiveLoanApplicationsResponseData.fromJson(res);
        rawApplications.assignAll(data.loanApplications);
        activeStatuses.assignAll(data.activeStatuses);
        pagination.value = data.pagination;

        currentPage.value = data.pagination?.currentPage ?? 1;
        final lastPage = data.pagination?.lastPage ?? 1;
        hasMore.value = (data.pagination?.hasMorePages == true) || (currentPage.value < lastPage);

        // Map into UI models
        final uiModels = data.loanApplications.map(_mapToUiModel).toList();
        applications.assignAll(uiModels);
      } else {
        debugPrint('Notice in fetchApplications: ${res['message']}');
        if (!isRefresh) applications.clear();
      }
    } catch (e) {
      debugPrint('Error in fetchApplications: $e');
      if (!isRefresh) applications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads next page applications for pagination (perPage: 7)
  Future<void> loadMoreApplications() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;

    isLoadingMore.value = true;
    final nextPage = currentPage.value + 1;

    try {
      final res = await ApiService.getActiveLoanApplications(
        page: nextPage,
        perPage: perPage,
      );
      if (res['success'] == true || res['status_code'] == 200) {
        final data = ActiveLoanApplicationsResponseData.fromJson(res);
        if (data.loanApplications.isNotEmpty) {
          rawApplications.addAll(data.loanApplications);
          pagination.value = data.pagination;
          currentPage.value = data.pagination?.currentPage ?? nextPage;

          final lastPage = data.pagination?.lastPage ?? nextPage;
          hasMore.value = (data.pagination?.hasMorePages == true) || (currentPage.value < lastPage);

          final uiModels = data.loanApplications.map(_mapToUiModel).toList();
          applications.addAll(uiModels);
        } else {
          hasMore.value = false;
        }
      } else {
        hasMore.value = false;
      }
    } catch (e) {
      debugPrint('Error in loadMoreApplications: $e');
    } finally {
      isLoadingMore.value = false;
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
      raw: app,
    );
  }

  /// Refreshes applications from backend
  Future<void> refreshApplications() async {
    await fetchApplications(isRefresh: true);
  }
}
