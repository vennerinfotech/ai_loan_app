import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/dashboard_controller.dart';
import '../widgets/bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'loan_flow/choose_loan_type_screen.dart';
import 'emi_calculator_screen.dart';
import 'document_wallet_screen.dart';
import 'profile_screen.dart';

/// Separate container screen hosting the bottom navigation bar and pages.
class MainNavScreen extends StatelessWidget {
  const MainNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Screen Page Body
          Obx(() {
            switch (controller.currentNavIndex.value) {
              case 0:
                return const DashboardScreen();
              case 1:
                return const EmiCalculatorScreen(showBackButton: false);
              case 2:
                // Center action handled by controller, fallback to dashboard
                return const DashboardScreen();
              case 3:
                return const DocumentWalletScreen(showBackButton: true);
              case 4:
                return const ProfileScreen();
              default:
                return const DashboardScreen();
            }
          }),

          // Floating Custom Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(
              () => CustomFloatingBottomNavBar(
                currentIndex: controller.currentNavIndex.value,
                onTap: (index) {
                  if (index == 2) {
                    Get.to(() => const ChooseLoanTypeScreen());
                  } else {
                    controller.currentNavIndex.value = index;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
