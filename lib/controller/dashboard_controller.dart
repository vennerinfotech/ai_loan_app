import 'package:get/get.dart';
import 'aadhaar_kyc_controller.dart';
import 'pan_kyc_controller.dart';
import 'kyc_flow_controller.dart';
import '../screens/kyc_flow_screen.dart';
import '../screens/feature_placeholder_screen.dart';
import '../screens/cibil_score_screen.dart';

/// GetX controller for Dashboard screen and bottom navigation bar.
class DashboardController extends GetxController {
  // Active bottom nav tab index (0: Home, 1: Cards, 2: Apply/Add, 3: Reports/Docs, 4: Profile)
  final currentNavIndex = 0.obs;

  // Active user data
  final userName = 'Aarav'.obs;
  final userInitials = 'AM'.obs;
  final cibilScore = 762.obs;
  final cibilStatus = 'Good'.obs;

  // Aadhaar KYC Controller instance
  AadhaarKycController get kycController => Get.put(AadhaarKycController());
  PanKycController get panController => Get.put(PanKycController());

  bool get isAadhaarCompleted => kycController.isAadhaarVerified.value;
  bool get isPanCompleted => panController.isPanCompleted.value;
  bool get isKycCompleted => isAadhaarCompleted && isPanCompleted;

  void changeNavIndex(int index) {
    currentNavIndex.value = index;
    if (index != 0) {
      final tabTitles = ['Home', 'My Cards', 'New Loan', 'Documents', 'Profile'];
      onDashboardOptionSelected(tabTitles[index]);
    }
  }

  /// Triggered whenever any option or feature is tapped from the dashboard
  void onDashboardOptionSelected(String featureName) {
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
