import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../models/active_application_model.dart';
import '../controller/active_applications_controller.dart';
import '../widgets/loan_application_detail_bottom_sheet.dart';
import 'loan_flow/application_status_screen.dart';
import 'loan_flow/choose_loan_type_screen.dart';

/// Screen displaying the list of all active loan applications with progress and status tracking,
/// driven reactively by [ActiveApplicationsController] and [ActiveApplicationModel].
class ActiveApplicationsScreen extends StatelessWidget {
  const ActiveApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActiveApplicationsController());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            _buildTopBar(context, controller),

            // Search Bar
            _buildSearchBar(controller),

            // Filter Tabs Row (Left Aligned)
            _buildFilterTabs(controller),

            const SizedBox(height: 12),

            // Applications List (Reactive)
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.applications.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                    ),
                  );
                }

                final filtered = controller.filteredApplications;

                if (filtered.isEmpty && !controller.isLoading.value) {
                  return _buildEmptyState(
                    isSearching: controller.searchQuery.value.trim().isNotEmpty,
                  );
                }

                final hasLoadingMore = controller.isLoadingMore.value;

                return RefreshIndicator(
                  onRefresh: controller.refreshApplications,
                  color: AppColors.primaryPurple,
                  child: ListView.separated(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: filtered.length + (hasLoadingMore ? 1 : 0),
                    separatorBuilder: (_, index) {
                      if (index >= filtered.length - 1) return const SizedBox.shrink();
                      return const SizedBox(height: 14);
                    },
                    itemBuilder: (context, index) {
                      if (index < filtered.length) {
                        return _buildApplicationCard(context, filtered[index]);
                      }
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),

            // Bottom Apply New Loan Bar
            _buildApplyNewLoanBar(context),
          ],
        ),
      ),
    );
  }

  /// Top Bar with squircle back button and centered title
  Widget _buildTopBar(BuildContext context, ActiveApplicationsController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Squircle Back Button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textDark,
              ),
            ),
          ),

          // Title
          const Text(
            'Active applications',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),

          // Total Count Badge (Reactive)
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.indigoTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${controller.totalCount} active',
                style: const TextStyle(
                  color: AppColors.primaryPurple,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Search Bar placed above filter tabs
  Widget _buildSearchBar(ActiveApplicationsController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: TextFormField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search by applicant name, phone, email...',
          hintStyle: const TextStyle(
            color: AppColors.muted,
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primaryPurple,
            size: 20,
          ),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: controller.clearSearch,
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.muted,
                size: 18,
              ),
            );
          }),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.dashboardCardBorder, width: 1.1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.dashboardCardBorder, width: 1.1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.3),
          ),
        ),
      ),
    );
  }

  /// Filter Tabs Row (Left-aligned: All, In review, Approved)
  Widget _buildFilterTabs(ActiveApplicationsController controller) {
    return Obx(() {
      final filters = [
        'All (${controller.totalCount})',
        'In review (${controller.inReviewCount})',
        'Approved (${controller.approvedCount})',
      ];

      return Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(filters.length, (index) {
              final isSelected = controller.selectedFilterIndex.value == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => controller.setFilter(index),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.navy : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.navy
                            : AppColors.line,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.navy
                                    .withValues(alpha: 0.18),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      filters[index],
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.muted,
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  /// Application Card matching Finsphere AI theme
  Widget _buildApplicationCard(BuildContext context, ActiveApplicationModel app) {
    final iconData = _getLoanIcon(app.loanType);
    final iconBg = _getLoanIconBg(app.loanType);
    final iconColor = _getLoanIconColor(app.loanType);

    return GestureDetector(
      onTap: () => LoanApplicationDetailBottomSheet.show(context, app),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dashboardCardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Icon + Title & ID + Status Pill
            Row(
              children: [
                // Loan Icon Container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      iconData,
                      color: iconColor,
                      size: 21,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Application ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.title,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        app.id,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Pill
                _buildStatusPill(app.statusType),
              ],
            ),

            const SizedBox(height: 14),

            // Amount, Tenure & EMI Info Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Loan amount',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        app.amount,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tenure',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        app.tenure,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Est. EMI',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        app.emi,
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Linear Progress Indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: app.progress,
                backgroundColor: AppColors.line,
                valueColor: AlwaysStoppedAnimation<Color>(
                  app.statusType == ApplicationStatusType.approved
                      ? AppColors.successGreen
                      : AppColors.primaryPurple,
                ),
                minHeight: 5,
              ),
            ),

            const SizedBox(height: 8),

            // Step Description & Percentage Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    app.currentStep,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  app.progressPercent,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.canvas),
            const SizedBox(height: 10),

            // Bottom Action Row: Applied Date + [View detail] + [Track status]
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Applied on ${app.appliedDate}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // View detail button (opens bottom sheet)
                    GestureDetector(
                      onTap: () => LoanApplicationDetailBottomSheet.show(context, app),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 13,
                              color: AppColors.primaryPurple,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'View detail',
                              style: TextStyle(
                                color: AppColors.primaryPurple,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Get.to(
                        () => const ApplicationStatusScreen(),
                        transition: Transition.noTransition,
                        duration: Duration.zero,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Track',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: AppColors.textDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Status Pill Widget
  Widget _buildStatusPill(ApplicationStatusType type) {
    Color bg;
    Color textColor;

    switch (type) {
      case ApplicationStatusType.approved:
        bg = AppColors.successGreenBg;
        textColor = AppColors.successGreen;
        break;
      case ApplicationStatusType.inReview:
        bg = AppColors.reviewPillBg;
        textColor = AppColors.reviewPillText;
        break;
      case ApplicationStatusType.rejected:
        bg = AppColors.errorRedBg;
        textColor = AppColors.errorRed;
        break;
      case ApplicationStatusType.pending:
        bg = AppColors.canvas;
        textColor = AppColors.muted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  /// Empty state when no applications match filter or search
  Widget _buildEmptyState({bool isSearching = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.assignment_outlined,
            size: 48,
            color: AppColors.line,
          ),
          const SizedBox(height: 12),
          Text(
            isSearching ? 'No matching applications' : 'No applications found',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isSearching
                ? 'Try searching with another applicant name, phone or email'
                : 'Try selecting another filter above',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Apply New Loan Bar
  Widget _buildApplyNewLoanBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => Get.to(
            () => const ChooseLoanTypeScreen(),
            transition: Transition.noTransition,
            duration: Duration.zero,
          ),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.dashboardCardGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardGradientEnd.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'Apply for a new loan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getLoanIcon(String loanType) {
    switch (loanType.toLowerCase()) {
      case 'home_loan':
        return Icons.home_outlined;
      case 'personal_loan':
        return Icons.person_outline_rounded;
      case 'auto_loan':
      case 'vehicle_loan':
        return Icons.directions_car_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  Color _getLoanIconBg(String loanType) {
    switch (loanType.toLowerCase()) {
      case 'home_loan':
        return AppColors.indigoTint;
      case 'personal_loan':
        return AppColors.inputFill;
      case 'auto_loan':
      case 'vehicle_loan':
        return AppColors.successGreenBg;
      default:
        return AppColors.canvas;
    }
  }

  Color _getLoanIconColor(String loanType) {
    switch (loanType.toLowerCase()) {
      case 'home_loan':
        return AppColors.primaryPurple;
      case 'personal_loan':
        return AppColors.indigo;
      case 'auto_loan':
      case 'vehicle_loan':
        return AppColors.successGreen;
      default:
        return AppColors.textDark;
    }
  }
}
