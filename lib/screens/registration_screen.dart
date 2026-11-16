import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../controller/registration_controller.dart';
import '../theme/theme.dart';
import '../widgets/registration_stepper.dart';
import '../widgets/create_account_step.dart';
import '../widgets/verify_otp_step.dart';

/// Registration Screen: Fixed header stepper + switchable step content.
/// Step 1 = Create Account, Step 2 = Verify OTP.
/// Header stays fixed; only bottom content changes between steps.
/// All colors from AppColors. Uses GetX (zero setState).
class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegistrationController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
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
                  default:
                    // Placeholder for step 3 (future)
                    return const Center(
                      child: Text(
                        'Complete Profile (Coming soon)',
                        style: TextStyle(
                          color: AppColors.textDarkSecondary,
                          fontSize: 16,
                        ),
                      ),
                    );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
