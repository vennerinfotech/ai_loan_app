import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../screens/login_with_mobile_screen.dart';
import '../screens/forgot_mpin_screen.dart';
import '../screens/main_nav_screen.dart';
import '../services/session_manager.dart';

/// GetX controller for Login with MPIN flow.
/// Includes ticker provider for continuous cosmic orbit animation in top card.
class MpinLoginController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final mpin = ''.obs;
  final userName = 'Aarav Mehta'.obs;
  final userInitials = 'AM'.obs;
  final isSubmitting = false.obs;

  late final AnimationController orbitController;
  late final Animation<double> orbitAnimation;

  @override
  void onInit() {
    super.onInit();
    orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    orbitAnimation = CurvedAnimation(
      parent: orbitController,
      curve: Curves.linear,
    );
  }

  @override
  void onClose() {
    orbitController.dispose();
    super.onClose();
  }

  void enterDigit(String digit) {
    if (mpin.value.length < 4) {
      mpin.value += digit;
      if (mpin.value.length == 4) {
        submitLogin();
      }
    }
  }

  void deleteDigit() {
    if (mpin.value.isNotEmpty) {
      mpin.value = mpin.value.substring(0, mpin.value.length - 1);
    }
  }

  void submitLogin() {
    isSubmitting.value = true;
    Future.delayed(const Duration(milliseconds: 400), () async {
      isSubmitting.value = false;
      // Save session with setString
      await SessionManager.saveLoginSession(name: userName.value);
      Get.offAll(() => const MainNavScreen());
    });
  }

  void triggerBiometric() {
    Get.snackbar(
      'Biometric Login',
      'Authenticating via fingerprint...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF524FBA),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 900), () async {
      // Save session with setString
      await SessionManager.saveLoginSession(name: userName.value);
      Get.offAll(() => const MainNavScreen());
    });
  }

  void useMobileNumber() {
    Get.to(() => const LoginWithMobileScreen());
  }

  void forgotMpin() {
    Get.to(() => const ForgotMpinScreen());
  }
}
