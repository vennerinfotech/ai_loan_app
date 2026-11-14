import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

class OnboardingPageData {
  final String titlePrefix;
  final String titleHighlight;
  final String description;

  const OnboardingPageData({
    required this.titlePrefix,
    required this.titleHighlight,
    required this.description,
  });
}

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<OnboardingPageData> pages = const [
    OnboardingPageData(
      titlePrefix: 'Meet every need with\n',
      titleHighlight: 'quick loans.',
      description:
          'Free CIBIL score, AI-powered eligibility and a fully digital application — all in one place.',
    ),
    OnboardingPageData(
      titlePrefix: 'Instant approval in\n',
      titleHighlight: 'under 3 minutes.',
      description:
          'Fast-track your dreams with paperless verification and immediate disbursement directly to your account.',
    ),
    OnboardingPageData(
      titlePrefix: 'Transparent rates with\n',
      titleHighlight: 'zero hidden fees.',
      description:
          'Flexible repayment tenures, lowest interest rates, and bank-grade data security at every step.',
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void goToPage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void createAccount() {
    // Handle create free account action
  }

  void alreadyHaveAccount() {
    // Handle sign-in action
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
