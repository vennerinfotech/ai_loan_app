import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../models/active_application_model.dart';
import '../controller/active_applications_controller.dart';
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

            // Filter Tabs Row (Left Aligned)
            _buildFilterTabs(controller),

            const SizedBox(height: 12),

            // Applications List (Reactive)
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPurple,
                    ),
                  );
                }

                final filtered = controller.filteredApplications;

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshApplications,
                  color: AppColors.primaryPurple,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _buildApplicationCard(filtered[index]);
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
                border: Border.all(color: const Color(0xFFE2E8F0)),
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
                color: const Color(0xFFEEF0FD),
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
                      color: isSelected ? const Color(0xFF242278) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF242278)
                            : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF242278)
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
                            isSelected ? Colors.white : const Color(0xFF64748B),
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
  Widget _buildApplicationCard(ActiveApplicationModel app) {
    final iconData = _getLoanIcon(app.loanType);
    final iconBg = _getLoanIconBg(app.loanType);
    final iconColor = _getLoanIconColor(app.loanType);

    return GestureDetector(
      onTap: () => Get.to(
        () => const ApplicationStatusScreen(),
        transition: Transition.noTransition,
        duration: Duration.zero,
      ),
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
                          color: Color(0xFF94A3B8),
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
                color: const Color(0xFFF8FAFC),
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
                          color: Color(0xFF94A3B8),
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
                          color: Color(0xFF94A3B8),
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
                          color: Color(0xFF94A3B8),
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
                backgroundColor: const Color(0xFFEAEFF8),
                valueColor: AlwaysStoppedAnimation<Color>(
                  app.statusType == ApplicationStatusType.approved
                      ? const Color(0xFF16A34A)
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
                      color: Color(0xFF64748B),
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
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Bottom Track Link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Applied on ${app.appliedDate}',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: const [
                    Text(
                      'Track status',
                      style: TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: AppColors.primaryPurple,
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
        bg = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        break;
      case ApplicationStatusType.inReview:
        bg = AppColors.reviewPillBg;
        textColor = AppColors.reviewPillText;
        break;
      case ApplicationStatusType.rejected:
        bg = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case ApplicationStatusType.pending:
        bg = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
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

  /// Empty state when no applications match filter
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: Color(0xFFCBD5E1),
          ),
          SizedBox(height: 12),
          Text(
            'No applications found',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try selecting another filter above',
            style: TextStyle(
              color: Color(0xFF94A3B8),
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
              gradient: const LinearGradient(
                colors: [Color(0xFF242278), Color(0xFF3835A8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF242278).withValues(alpha: 0.22),
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
        return const Color(0xFFEEF1FD);
      case 'personal_loan':
        return const Color(0xFFE0F2FE);
      case 'auto_loan':
      case 'vehicle_loan':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getLoanIconColor(String loanType) {
    switch (loanType.toLowerCase()) {
      case 'home_loan':
        return AppColors.primaryPurple;
      case 'personal_loan':
        return const Color(0xFF0284C7);
      case 'auto_loan':
      case 'vehicle_loan':
        return const Color(0xFF15803D);
      default:
        return AppColors.textDark;
    }
  }
}
