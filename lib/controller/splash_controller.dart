import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../screens/onboarding_screen.dart';

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
    // Automatically navigate to OnboardingScreen after 5 seconds
    _timer = Timer(const Duration(seconds: 5), () {
      navigateToOnboarding();
    });
  }

  void navigateToOnboarding() {
    _timer?.cancel();
    Get.off(
      () => const OnboardingScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    orbitAnimation.dispose();
    super.onClose();
  }
}
