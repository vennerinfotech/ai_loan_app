import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/dashboard_response_model.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import 'aadhaar_kyc_controller.dart';
import 'pan_kyc_controller.dart';
import 'kyc_flow_controller.dart';
import '../screens/kyc_flow_screen.dart';
import '../screens/feature_placeholder_screen.dart';
import '../screens/cibil_score_screen.dart';
import '../screens/loan_flow/choose_loan_type_screen.dart';
import '../screens/loan_flow/application_status_screen.dart';
import '../screens/active_applications_screen.dart';
import 'apply_loan_controller.dart';

/// GetX controller for Dashboard screen and bottom navigation bar.
class DashboardController extends GetxController {
  // Active bottom nav tab index (0: Home, 1: Cards, 2: Apply/Add, 3: Reports/Docs, 4: Profile)
  final currentNavIndex = 0.obs;

  // Active user data (strictly dynamic, zero static fallback data)
  final userName = ''.obs;
  final userInitials = ''.obs;
  final greeting = ''.obs;
  final cibilScore = 0.obs;
  final cibilStatus = ''.obs;

  // Loading and full dashboard data
  final isLoading = false.obs;
  final dashboardData = Rxn<DashboardData>();

  // Aadhaar KYC Controller instance
  AadhaarKycController get kycController => Get.put(AadhaarKycController());
  PanKycController get panController => Get.put(PanKycController());

  bool get isAadhaarCompleted => kycController.isAadhaarVerified.value;
  bool get isPanCompleted => panController.isPanCompleted.value;
  bool get isKycCompleted => isAadhaarCompleted && isPanCompleted;

  @override
  void onInit() {
    super.onInit();
    _loadLocalUserData();
    fetchDashboardData();
  }

  /// Initial load from local session if available to avoid any UI flash
  Future<void> _loadLocalUserData() async {
    final localName = await SessionManager.getUserName();
    if (localName.isNotEmpty && userName.value.isEmpty) {
      userName.value = localName;
      userInitials.value = _computeInitials(localName);
    }
  }

  /// Derives 2-letter uppercase initials from full name
  String _computeInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length == 1) {
      return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  /// Calls GET /dashboard and synchronizes dashboard state
  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      final res = await ApiService.getDashboardData();
      if (res['status_code'] == 200 || res['success'] == true) {
        final model = DashboardResponseModel.fromJson(res);
        if (model.data != null) {
          dashboardData.value = model.data;
          final d = model.data!;

          // 1. Sync User Name & Initials
          if (d.user != null) {
            final name = d.user!.name ?? d.user!.firstName ?? userName.value;
            if (name.isNotEmpty) {
              userName.value = name;
              userInitials.value = _computeInitials(name);
            }
          }

          // 2. Sync Greeting
          if (d.greeting != null && d.greeting!.trim().isNotEmpty) {
            greeting.value = d.greeting!.trim();
          }

          // 3. Sync Credit Score
          if (d.creditScore != null) {
            if (d.creditScore!.score != null) {
              cibilScore.value = d.creditScore!.score!;
            }
            if (d.creditScore!.band != null && d.creditScore!.band!.trim().isNotEmpty) {
              cibilStatus.value = d.creditScore!.band!.trim();
            }
          }

          // 4. Sync KYC Document Verifications
          final insights = d.aiInsights;
          if (insights != null) {
            final aadhaarStatus = insights.getVerificationStatus('aadhaar');
            if (aadhaarStatus?.toLowerCase() == 'verified') {
              kycController.isAadhaarVerified.value = true;
            }
            final panStatus = insights.getVerificationStatus('pan');
            if (panStatus?.toLowerCase() == 'verified') {
              panController.isPanCompleted.value = true;
            }
          }

          // 5. Sync from Application Status steps if present
          if (d.applicationStatus?.steps.isNotEmpty == true) {
            for (final step in d.applicationStatus!.steps) {
              if (step.key == 'aadhaar' &&
                  (step.isCompleted == true || step.status?.toLowerCase() == 'completed')) {
                kycController.isAadhaarVerified.value = true;
              }
              if (step.key == 'pan' &&
                  (step.isCompleted == true || step.status?.toLowerCase() == 'completed')) {
                panController.isPanCompleted.value = true;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changeNavIndex(int index) {
    currentNavIndex.value = index;
    if (index != 0) {
      final tabTitles = ['Home', 'My Cards', 'New Loan', 'Documents', 'Profile'];
      onDashboardOptionSelected(tabTitles[index]);
    }
  }

  /// Triggered whenever any option or feature is tapped from the dashboard
  void onDashboardOptionSelected(String featureName) {
    if (featureName == 'Apply for loan' || featureName == 'New Loan' || featureName == 'Choose loan type') {
      Get.to(() => const ChooseLoanTypeScreen());
      return;
    }
    if (featureName == 'Other loans') {
      final applyController = Get.isRegistered<ApplyLoanController>()
          ? Get.find<ApplyLoanController>()
          : Get.put(ApplyLoanController());
      applyController.isOtherLoansExpanded.value = true;
      Get.to(() => const ChooseLoanTypeScreen(expandOtherLoans: true));
      return;
    }
    if (featureName == 'Loan updates' || featureName == 'Home loan Application') {
      Get.to(() => const ApplicationStatusScreen());
      return;
    }
    if (featureName == 'All Applications' ||
        featureName == 'Active applications' ||
        featureName == 'Active application') {
      Get.to(
        () => const ActiveApplicationsScreen(),
        transition: Transition.noTransition,
        duration: Duration.zero,
      );
      return;
    }
    if (featureName == 'AI eligibility') {
      // Navigation removed per user request
      return;
    }
    if (!isAadhaarCompleted) {
      kycController.setTargetFeature(featureName);
      Get.to(() => const KycFlowScreen(initialStep: KycSubStep.aadhaarInput));
    } else if (!isPanCompleted) {
      panController.setTargetFeature(featureName);
      Get.to(() => const KycFlowScreen(initialStep: KycSubStep.panInput));
    } else {
      if (featureName == 'CIBIL Report' || featureName == 'Credit Score') {
        Get.to(() => const CibilScoreScreen());
      } else {
        Get.to(() => FeaturePlaceholderScreen(featureTitle: featureName));
      }
    }
  }
}
