import 'package:material_ui/material_ui.dart';
import '../../theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../controller/apply_loan_controller.dart';
import 'apply_loan_flow_screen.dart';

/// Screen 1 of Apply Loan Flow: "Choose loan type" (Step 1 of 4)
class ChooseLoanTypeScreen extends StatelessWidget {
  final bool expandOtherLoans;

  const ChooseLoanTypeScreen({super.key, this.expandOtherLoans = false});

  @override
  Widget build(BuildContext context) {
    if (expandOtherLoans) {
      final controller = Get.isRegistered<ApplyLoanController>()
          ? Get.find<ApplyLoanController>()
          : Get.put(ApplyLoanController());
      controller.isOtherLoansExpanded.value = true;
    }
    return const ApplyLoanFlowScreen(initialStep: 1);
  }
}

/// Content body of "Choose loan type" (used within sticky-header Loan Flow)
class ChooseLoanTypeBody extends StatelessWidget {
  const ChooseLoanTypeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ApplyLoanController>();
    final scrollController = ScrollController();

    return Column(
      children: [
        // Scrollable Options Content
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading & Subtitle
                const Text(
                  'What\'s the loan for?',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pick one — you can change it later.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 18),

                // Primary 2x3 Grid of Loan Types
                _buildLoanTypesGrid(controller),
                const SizedBox(height: 14),

                // "••• Other loans" Section (Expands with Education, Machinery, BT+Top-up, Agri loans)
                _buildOtherLoansSection(controller, context, scrollController),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // Bottom CTA Button: "Continue with [selected] loan ->"
        _buildBottomCta(controller),
      ],
    );
  }

  Widget _buildLoanTypesGrid(ApplyLoanController controller) {
    return Column(
      children: [
        for (int i = 0; i < controller.loanTypes.length; i += 2) ...[
          Row(
            children: [
              Expanded(
                child: _buildLoanCard(controller, controller.loanTypes[i]),
              ),
              const SizedBox(width: 14),
              if (i + 1 < controller.loanTypes.length)
                Expanded(
                  child: _buildLoanCard(controller, controller.loanTypes[i + 1]),
                )
              else
                const Spacer(),
            ],
          ),
          if (i + 2 < controller.loanTypes.length) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildLoanCard(ApplyLoanController controller, LoanTypeOption item) {
    return Obx(() {
      final isSelected = controller.selectedLoanType.value == item.title;

      return GestureDetector(
        onTap: () => controller.selectLoanType(item.title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 118,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navy : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.navy
                  : AppColors.line,
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.navy.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Icon Container and Checkmark Badge if selected
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.indigo
                          : AppColors.indigoTint,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForType(item.iconKey),
                        size: 19,
                        color: isSelected
                            ? Colors.white
                            : AppColors.indigo,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                ],
              ),

              // Title & Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.muted
                          : AppColors.muted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOtherLoansSection(
    ApplyLoanController controller,
    BuildContext context,
    ScrollController scrollController,
  ) {
    return Obx(() {
      final isExpanded = controller.isOtherLoansExpanded.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // If expanded, show the 4 additional cards: Education, Machinery, BT+Top-up, Agri
          if (isExpanded) ...[
            Column(
              children: [
                for (int i = 0; i < controller.otherLoanTypes.length; i += 2) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildLoanCard(controller, controller.otherLoanTypes[i]),
                      ),
                      const SizedBox(width: 14),
                      if (i + 1 < controller.otherLoanTypes.length)
                        Expanded(
                          child: _buildLoanCard(controller, controller.otherLoanTypes[i + 1]),
                        )
                      else
                        const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ],

          // Dotted Toggle Button: "••• Other loans" / "Show fewer loans"
          GestureDetector(
            onTap: () {
              controller.toggleOtherLoans();
              if (controller.isOtherLoansExpanded.value) {
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (scrollController.hasClients) {
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
            },
            child: DottedBorder(
              color: AppColors.indigoTint,
              strokeWidth: 1.2,
              dashPattern: const [5, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(16),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.canvas.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isExpanded) ...[
                      const Text(
                        '•••',
                        style: TextStyle(
                          color: AppColors.indigo,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Other loans',
                        style: TextStyle(
                          color: AppColors.indigo,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: AppColors.indigo,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Show fewer loans',
                        style: TextStyle(
                          color: AppColors.indigo,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBottomCta(ApplyLoanController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
      child: Obx(() {
        final loanType = controller.selectedLoanType.value.toLowerCase();

        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              controller.goToStep(2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue with  $loanType',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.amber,
                  size: 18,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  IconData _getIconForType(String iconKey) {
    switch (iconKey) {
      case 'home':
        return Icons.home_rounded;
      case 'property':
        return Icons.account_balance_rounded;
      case 'business':
        return Icons.work_outline_rounded;
      case 'personal':
        return Icons.person_outline_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'machinery':
        return Icons.precision_manufacturing_rounded;
      case 'bt_topup':
        return Icons.trending_up_rounded;
      case 'agri':
        return Icons.eco_rounded;
      default:
        return Icons.monetization_on_rounded;
    }
  }
}
