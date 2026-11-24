import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/loan_status_model.dart';
import '../services/api_service.dart';

enum ApplicationStepStatus { done, inProgress, pending }

class ProgressStepItem {
  final String title;
  final String subtitle;
  final ApplicationStepStatus status;

  const ProgressStepItem({
    required this.title,
    required this.subtitle,
    required this.status,
  });
}

/// Controller managing the Application Status Screen state (GET /loan/status)
class ApplicationStatusController extends GetxController {
  final isLoading = false.obs;
  final loanStatus = Rxn<LoanStatusModel>();

  @override
  void onInit() {
    super.onInit();
    fetchLoanStatus();
  }

  /// Fetches status from GET {{baseUrl}}/loan/status
  Future<void> fetchLoanStatus() async {
    isLoading.value = true;
    try {
      final res = await ApiService.getLoanStatus();
      if (res['success'] == true || res['status_code'] == 200) {
        loanStatus.value = LoanStatusModel.fromJson(res);
      } else {
        debugPrint('Notice in fetchLoanStatus: ${res['message']}');
      }
    } catch (e) {
      debugPrint('Error in fetchLoanStatus: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Formatted loan amount (e.g. ₹25,00,000)
  String get formattedLoanAmount {
    final amount = loanStatus.value?.user?.loanAmount ?? 2500000;
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return formatter.format(amount);
  }

  /// User Name or fallback
  String get userName => loanStatus.value?.user?.name ?? '';

  /// User Phone
  String get userPhone => loanStatus.value?.user?.phone ?? '';

  /// Current step integer
  int get currentStep => loanStatus.value?.user?.currentStep ?? 1;

  /// Dynamic steps derived directly from the verification_status API response
  List<ProgressStepItem> get dynamicSteps {
    final verif = loanStatus.value?.verificationStatus;
    if (verif == null || verif.rawStatus.isEmpty) {
      return const [];
    }

    final List<ProgressStepItem> list = [];

    // Map each verification item directly from the API response
    verif.rawStatus.forEach((key, value) {
      final isDone = value == true || value == 1 || value == 'true';
      
      // Clean readable title directly derived from API key
      final title = _formatKeyToTitle(key);
      final subtitle = isDone ? 'Verified' : 'Pending verification';
      final status = isDone ? ApplicationStepStatus.done : ApplicationStepStatus.inProgress;

      list.add(
        ProgressStepItem(
          title: title,
          subtitle: subtitle,
          status: status,
        ),
      );
    });

    return list;
  }

  /// Converts snake_case key (e.g. 'aadhaar_verified', 'pan_verified', 'business_proof') to formatted title
  String _formatKeyToTitle(String key) {
    if (key == 'aadhaar_verified' || key == 'aadhaar') return 'Aadhaar Verification';
    if (key == 'pan_verified' || key == 'pan') return 'PAN Verification';
    if (key == 'salaried_proof') return 'Salaried Proof';
    if (key == 'business_proof') return 'Business Proof';

    // Generic formatting for any other dynamic key returned by backend
    return key
        .replaceAll('_verified', ' Verification')
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Completed count for segmented progress bar
  int get completedStepsCount {
    return dynamicSteps.where((s) => s.status == ApplicationStepStatus.done).length;
  }

  /// Active step label (e.g. "Now: credit report")
  String get activeStepLabel {
    final active = dynamicSteps.firstWhereOrNull((s) => s.status == ApplicationStepStatus.inProgress);
    if (active != null) {
      return 'Now: ${active.title.toLowerCase()}';
    }
    if (completedStepsCount == dynamicSteps.length) {
      return 'All steps complete';
    }
    return 'In progress';
  }
}
