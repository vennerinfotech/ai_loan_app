import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../controller/registration_controller.dart';
import '../theme/theme.dart';
import '../widgets/registration_stepper.dart';
import '../widgets/create_account_step.dart';
import '../widgets/verify_otp_step.dart';
import '../widgets/create_mpin_step.dart';
import '../widgets/top_right_cosmic_orbit_painter.dart';

/// Registration Screen: Fixed header stepper + switchable step content.
/// Step 1 = Create Account, Step 2 = Verify OTP, Step 3 = Create MPIN.
/// Header stays fixed; only bottom content changes between steps.
/// Unified light theme with visible primary-colored cosmic design on MPIN step.
class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegistrationController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Obx(() {
        final isMpinStep = controller.currentStep.value == 2;

        return Stack(
          children: [
            // Top right design pattern in primary color on MPIN step (visible on light bg)
            if (isMpinStep)
              Positioned(
                top: 0,
                right: 0,
                width: 360,
                height: 200,
                child: CustomPaint(
                  painter: TopRightCosmicOrbitPainter(
                    animation: controller.mpinOrbitAnimation,
                  ),
                ),
              ),

            SafeArea(
              child: Column(
                children: [
                  // Fixed header: Back + stepper pills + step counter
                  RegistrationStepper(
                    currentStep: controller.currentStep,
                    totalSteps: RegistrationController.totalSteps,
                    onBack: controller.goBack,
                  ),

                  // Switchable step content
                  Expanded(
                    child: Obx(() {
                      switch (controller.currentStep.value) {
                        case 0:
                          return CreateAccountStep(controller: controller);
                        case 1:
                          return VerifyOtpStep(controller: controller);
                        case 2:
                          return CreateMpinStep(controller: controller);
                        default:
                          return CreateAccountStep(controller: controller);
                      }
                    }),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
