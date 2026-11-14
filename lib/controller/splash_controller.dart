import 'dart:async';
import 'package:get/get.dart';
import '../screens/onboarding_screen.dart';

class SplashController extends GetxController {
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
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
    super.onClose();
  }
}
