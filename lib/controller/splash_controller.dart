import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../screens/onboarding_screen.dart';
import '../screens/main_nav_screen.dart';
import '../services/session_manager.dart';

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
  /// If already logged in (is_login == 'true'), navigate directly to Dashboard (MainNavScreen).
  /// If not logged in, navigate to OnboardingScreen.
  Future<void> navigateToNextScreen() async {
    _timer?.cancel();
    final isLogged = await SessionManager.isLoggedIn();

    if (isLogged) {
      Get.off(
        () => const MainNavScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600),
      );
    } else {
      Get.off(
        () => const OnboardingScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 600),
      );
    }
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
