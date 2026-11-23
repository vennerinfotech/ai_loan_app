import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
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

    return Obx(() {
      final isLoading = controller.isLoadingLoanTypes.value &&
          controller.loanTypesData.value == null;

      return Skeletonizer(
        enabled: isLoading,
        child: Column(
          children: [
            // Scrollable Options Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

                    // Primary 2x3 Grid of Loan Types from API
                    _buildLoanTypesGrid(controller),
                    const SizedBox(height: 14),

                    // "••• Other loans" Section (Expands with remaining loan types from API)
                    if (!isLoading)
                      _buildOtherLoansSection(
                          controller, context, scrollController),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Bottom CTA Button: "Continue with [selected] loan ->"
            _buildBottomCta(controller, isLoading: isLoading),
          ],
        ),
      );
    });
  }

  Widget _buildLoanTypesGrid(ApplyLoanController controller) {
    return Obx(() {
      final apiTypes = controller.apiPrimaryLoanTypes;
      final useApi = apiTypes.isNotEmpty;
      final count = useApi ? apiTypes.length : controller.loanTypes.length;

      return Column(
        children: [
          for (int i = 0; i < count; i += 2) ...[
            Row(
              children: [
                Expanded(
                  child: useApi
                      ? _buildLoanCard(
                          controller: controller,
                          title: apiTypes[i].label ?? apiTypes[i].value ?? '',
                          subtitle: apiTypes[i].description ?? '',
                          iconKey: apiTypes[i].icon ?? apiTypes[i].value ?? '',
                        )
                      : _buildLoanCard(
                          controller: controller,
                          title: controller.loanTypes[i].title,
                          subtitle: controller.loanTypes[i].subtitle,
                          iconKey: controller.loanTypes[i].iconKey,
                        ),
                ),
                const SizedBox(width: 14),
                if (i + 1 < count)
                  Expanded(
                    child: useApi
                        ? _buildLoanCard(
                            controller: controller,
                            title: apiTypes[i + 1].label ??
                                apiTypes[i + 1].value ??
                                '',
                            subtitle: apiTypes[i + 1].description ?? '',
                            iconKey: apiTypes[i + 1].icon ??
                                apiTypes[i + 1].value ??
                                '',
                          )
                        : _buildLoanCard(
                            controller: controller,
                            title: controller.loanTypes[i + 1].title,
                            subtitle: controller.loanTypes[i + 1].subtitle,
                            iconKey: controller.loanTypes[i + 1].iconKey,
                          ),
                  )
                else
                  const Spacer(),
              ],
            ),
            if (i + 2 < count) const SizedBox(height: 14),
          ],
        ],
      );
    });
  }

  Widget _buildLoanCard({
    required ApplyLoanController controller,
    required String title,
    required String subtitle,
    required String iconKey,
  }) {
    return Obx(() {
      final isSelected = controller.selectedLoanType.value.trim().isNotEmpty &&
          controller.selectedLoanType.value.toLowerCase().trim() ==
              title.toLowerCase().trim();

      return GestureDetector(
        onTap: () => controller.selectLoanType(title),
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
                        controller.getIconForLoanType(iconKey),
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
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textSecondary2
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
      final apiOthers = controller.apiOtherLoanTypes;
      final useApi = apiOthers.isNotEmpty;
      final otherCount =
          useApi ? apiOthers.length : controller.otherLoanTypes.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // If expanded, show the additional cards
          if (isExpanded) ...[
            Column(
              children: [
                for (int i = 0; i < otherCount; i += 2) ...[
                  Row(
                    children: [
                      Expanded(
                        child: useApi
                            ? _buildLoanCard(
                                controller: controller,
                                title: apiOthers[i].label ??
                                    apiOthers[i].value ??
                                    '',
                                subtitle: apiOthers[i].description ?? '',
                                iconKey: apiOthers[i].icon ??
                                    apiOthers[i].value ??
                                    '',
                              )
                            : _buildLoanCard(
                                controller: controller,
                                title: controller.otherLoanTypes[i].title,
                                subtitle: controller.otherLoanTypes[i].subtitle,
                                iconKey: controller.otherLoanTypes[i].iconKey,
                              ),
                      ),
                      const SizedBox(width: 14),
                      if (i + 1 < otherCount)
                        Expanded(
                          child: useApi
                              ? _buildLoanCard(
                                  controller: controller,
                                  title: apiOthers[i + 1].label ??
                                      apiOthers[i + 1].value ??
                                      '',
                                  subtitle:
                                      apiOthers[i + 1].description ?? '',
                                  iconKey: apiOthers[i + 1].icon ??
                                      apiOthers[i + 1].value ??
                                      '',
                                )
                              : _buildLoanCard(
                                  controller: controller,
                                  title:
                                      controller.otherLoanTypes[i + 1].title,
                                  subtitle:
                                      controller.otherLoanTypes[i + 1].subtitle,
                                  iconKey:
                                      controller.otherLoanTypes[i + 1].iconKey,
                                ),
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
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.canvas.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: DottedBorder(
                color: AppColors.indigo.withValues(alpha: 0.4),
                strokeWidth: 1.3,
                dashPattern: const [6, 4],
                borderType: BorderType.RRect,
                radius: const Radius.circular(16),
                borderPadding: const EdgeInsets.all(1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
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
          ),
        ],
      );
    });
  }

  Widget _buildBottomCta(ApplyLoanController controller,
      {bool isLoading = false}) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        child: Obx(() {
          final hasSelection =
              controller.selectedLoanType.value.trim().isNotEmpty;
          final loanType = controller.selectedLoanType.value;

          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (isLoading || !hasSelection)
                  ? null
                  : () {
                      controller.goToStep(2);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                disabledBackgroundColor:
                    AppColors.navy.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    hasSelection ? 'Continue with  $loanType' : 'Continue',
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
      ),
    );
  }
}
