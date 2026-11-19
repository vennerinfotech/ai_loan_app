import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../screens/onboarding_screen.dart';
import '../screens/main_nav_screen.dart';
import '../screens/login_with_mobile_screen.dart';
import '../services/session_manager.dart';
import '../services/api_service.dart';

/// Controller for Splash Screen managing auto-navigation timer
/// and a lightweight continuous ticker for the celestial orbit animation.
class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController orbitAnimation;

  @override
  void onInit() {
    super.onInit();
    // Smooth 20-second continuous loop for celestial orbit motion
    orbitAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _startTimer();
  }

  void _startTimer() {
    // Automatically navigate after 5 seconds
    _timer = Timer(const Duration(seconds: 5), () {
      navigateToNextScreen();
    });
  }

  /// Check local storage session:
  /// 1. If already logged in (is_login == 'true'), navigate directly to Dashboard (MainNavScreen).
  /// 2. If saved phone exists, call check-mobile-login API:
  ///    - If registered (is_registered == true), navigate to LoginWithMpinScreen.
  /// 3. Otherwise, navigate to OnboardingScreen.
  Future<void> navigateToNextScreen() async {
    _timer?.cancel();
    final isLogged = await SessionManager.isLoggedIn();

    if (isLogged) {
      Get.off(
        () => const MainNavScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600),
      );
      return;
    }

    // Check if phone number was previously stored
    final savedPhone = await SessionManager.getUserPhone();
    if (savedPhone.isNotEmpty && savedPhone.length == 10) {
      try {
        final response = await ApiService.checkMobileLogin(phone: savedPhone);
        final isSuccess =
            response['success'] == true || response['status_code'] == 200;
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : null;
        final isRegistered = data?['is_registered'] == true;

        if (isSuccess && isRegistered) {
          Get.off(
            () => LoginWithMobileScreen(initialPhone: savedPhone),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 600),
          );
          return;
        }
      } catch (e) {
        debugPrint('Splash checkMobileLogin exception: $e');
      }
    }

    Get.off(
      () => const OnboardingScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 600),
    );
  }

  // Alias for backward compatibility if tapped
  void navigateToOnboarding() => navigateToNextScreen();

  @override
  void onClose() {
    _timer?.cancel();
    orbitAnimation.dispose();
    super.onClose();
  }
}
