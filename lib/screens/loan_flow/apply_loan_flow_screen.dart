import 'package:ai_loan_app/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../controller/apply_loan_controller.dart';
import '../../widgets/loan_flow_stepper.dart';
import 'choose_loan_type_screen.dart';
import 'loan_amount_tenure_screen.dart';
import 'employment_type_screen.dart';
import 'upload_documents_screen.dart';

/// Unified Apply Loan Screen with a permanently Sticky Top Header,
/// matching the Aadhaar KYC verification flow architecture.
///
/// The top header (Back squircle button, "Apply for loan" center title,
/// Help squircle button, and 4-step Stepper) remains stationary at the top,
/// while ONLY the bottom content section transitions smoothly between steps.
class ApplyLoanFlowScreen extends StatelessWidget {
  final int initialStep;

  const ApplyLoanFlowScreen({
    super.key,
    this.initialStep = 1,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ApplyLoanController>()
        ? Get.find<ApplyLoanController>()
        : Get.put(ApplyLoanController());

    // Sync initial step if navigated directly
    if (controller.currentStep.value != initialStep && controller.stepHistory.length <= 1) {
      controller.currentStep.value = initialStep;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        controller.handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Permanently Sticky Top Header (matching reference design)
              Obx(
                () => LoanFlowHeaderWithStepper(
                  activeStep: controller.currentStep.value,
                  totalSteps: 4,
                  onBack: controller.handleBack,
                ),
              ),
              const SizedBox(height: 4),

              // 2. Dynamic Bottom Content Section (ONLY this changes between steps)
              Expanded(
                child: Obx(() {
                  switch (controller.currentStep.value) {
                    case 1:
                      return const ChooseLoanTypeBody();
                    case 2:
                      return const LoanAmountTenureBody();
                    case 3:
                      return const EmploymentTypeBody();
                    case 4:
                      return const UploadDocumentsBody();
                    default:
                      return const ChooseLoanTypeBody();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
