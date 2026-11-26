import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../controller/dashboard_controller.dart';
import '../widgets/bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'emi_calculator_screen.dart';
import 'document_wallet_screen.dart';
import 'profile_screen.dart';

/// Main navigation container screen hosting the bottom navigation bar and pages.
/// Implements double-back-press to exit with toast notification displayed
/// directly above the bottom navigation bar.
class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  DateTime? _lastBackPressTime;
  late FToast _fToast;

  @override
  void initState() {
    super.initState();
    _fToast = FToast();
    _fToast.init(context);
  }

  void _handleBackPress() {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      _fToast.removeCustomToast();
      _fToast.showToast(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            'Press back again to exit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        positionedToastBuilder: (context, child, gravity) {
          // Positioned 106px from bottom (directly above the floating 68px nav bar + 24px margin)
          return Positioned(
            left: 0,
            right: 0,
            bottom: 106,
            child: Center(child: child),
          );
        },
        toastDuration: const Duration(seconds: 2),
      );
    } else {
      _fToast.removeCustomToast();
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
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
                      controller.handleApplyLoan(featureName: 'Apply for loan');
                    } else {
                      controller.currentNavIndex.value = index;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
