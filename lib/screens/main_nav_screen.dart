import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/dashboard_controller.dart';
import '../widgets/bottom_nav_bar.dart';
import 'dashboard_screen.dart';

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
                return _buildSimpleTabScreen('My Loans & Cards', Icons.credit_card_rounded, controller);
              case 2:
                // Center action handled by controller, fallback to dashboard
                return const DashboardScreen();
              case 3:
                return _buildSimpleTabScreen('Documents & Reports', Icons.receipt_long_outlined, controller);
              case 4:
                return _buildSimpleTabScreen('My Profile', Icons.person_outline_rounded, controller);
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
                    controller.onDashboardOptionSelected('Apply for loan');
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

  Widget _buildSimpleTabScreen(String title, IconData icon, DashboardController controller) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.primaryPurple, size: 36),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Explore your applications, EMIs, and records.',
                    style: TextStyle(
                      color: AppColors.textDarkSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.currentNavIndex.value = 0,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButtonBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
