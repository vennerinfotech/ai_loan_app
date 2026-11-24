import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../controller/recommended_loan_offers_controller.dart';
import '../../models/loan_suggestions_model.dart';
import '../../theme/app_colors.dart';

/// Screen displaying Bank Loan Suggestions directly from API response
class RecommendedLoanOffersScreen extends StatelessWidget {
  const RecommendedLoanOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecommendedLoanOffersController());

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(context, controller),

            // Main Content Area
            Expanded(
              child: RefreshIndicator(
                color: AppColors.navy,
                backgroundColor: Colors.white,
                onRefresh: controller.fetchLoanSuggestions,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return _buildSkeletonSuggestions();
                  }

                  if (controller.displayedSuggestions.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: AppColors.indigoTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_outlined,
                                size: 32,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'No Loan Suggestions Available',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'We could not find matching bank loan suggestions right now. Please try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 22),
                            ElevatedButton.icon(
                              onPressed: () => controller.fetchLoanSuggestions(),
                              icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                              label: const Text(
                                'Refresh',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navy,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                    itemCount: controller.displayedSuggestions.length + 2,
                    itemBuilder: (context, index) {
                      // Item 0: User Profile Header from API
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildUserHeader(controller),
                        );
                      }

                      // Item 1: Filter Tabs
                      if (index == 1) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildFilterTabs(controller),
                        );
                      }

                      // Items 2+: Bank Suggestion Cards
                      final suggestion =
                          controller.displayedSuggestions[index - 2];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildSuggestionCard(controller, suggestion),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top App Bar
  Widget _buildTopAppBar(
    BuildContext context,
    RecommendedLoanOffersController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
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
                border: Border.all(color: AppColors.line, width: 1.2),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.textDark,
              ),
            ),
          ),

          // Screen Title
          const Expanded(
            child: Center(
              child: Text(
                'Loan Suggestions',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),

          // Right spacer to keep title centered
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  /// User header banner populated directly from API response data.user
  Widget _buildUserHeader(RecommendedLoanOffersController controller) {
    final user = controller.suggestionsUser.value;
    final name = user?.name ?? 'Applicant';
    final phone = user?.phone;
    final totalCount = controller.suggestions.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.dashboardCardGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardGradientEnd.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.amber,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User details from API
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                if (phone != null && phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+91 $phone',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Match count pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              '$totalCount Offers',
              style: const TextStyle(
                color: AppColors.amber,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Segmented filter tabs: Best match, Lowest rate, Lowest fee
  Widget _buildFilterTabs(RecommendedLoanOffersController controller) {
    return Row(
      children: List.generate(controller.filters.length, (index) {
        final isSelected = controller.selectedFilterIndex.value == index;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => controller.changeFilter(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.navy : AppColors.line,
                  width: 1.2,
                ),
              ),
              child: Text(
                controller.filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Suggestion Card built directly from API LoanSuggestionItem
  Widget _buildSuggestionCard(
    RecommendedLoanOffersController controller,
    LoanSuggestionItem item,
  ) {
    final bankName = item.bankName ?? 'Bank';
    final matchScore = item.matchScore ?? 0;
    final interestRate = item.interestRate ?? 'N/A';
    final maxAmount = item.maxLoanAmount ?? 'N/A';
    final tenure = item.tenure ?? 'N/A';
    final fee = item.processingFee ?? 'N/A';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: matchScore >= 90 ? AppColors.amber : AppColors.line,
          width: matchScore >= 90 ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Bank Avatar + Bank Name + Match Score
            Row(
              children: [
                // Bank Avatar with initials
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getBankColor(bankName),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      item.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Bank Name
                Expanded(
                  child: Text(
                    bankName,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                // Match Score Pill
                if (matchScore > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successGreenBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 13,
                          color: AppColors.successGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$matchScore% Match',
                          style: const TextStyle(
                            color: AppColors.successGreen,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // 2x2 Specs Grid from API
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSpecItem('Interest rate', interestRate),
                      ),
                      Expanded(
                        child: _buildSpecItem('Max loan amount', maxAmount),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSpecItem('Tenure', tenure),
                      ),
                      Expanded(
                        child: _buildSpecItem('Processing fee', fee),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // AI Match Reason from API
            if (item.reason != null && item.reason!.trim().isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.indigoTint,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.indigo.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: AppColors.indigo,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.reason!,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Advantages / Pros from API
            if (item.pros.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 5,
                children: item.pros.map((pro) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppColors.successGreenBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: AppColors.successGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pro,
                          style: const TextStyle(
                            color: AppColors.successGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],

            // Cons / Points to Note from API
            if (item.cons.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 5,
                children: item.cons.map((con) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppColors.warningAmberBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 12,
                          color: AppColors.warningAmber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          con,
                          style: const TextStyle(
                            color: AppColors.warningAmber,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Action Button: "Apply now"
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => controller.applyForOffer(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Apply now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.amber,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Spec item block (Title + Value)
  Widget _buildSpecItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  /// Dynamic color generator for bank icons
  Color _getBankColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('hdfc')) return const Color(0xFF004C8F);
    if (lower.contains('sbi') || lower.contains('state bank')) {
      return const Color(0xFF0083CA);
    }
    if (lower.contains('icici')) return const Color(0xFF9E1B32);
    if (lower.contains('axis')) return const Color(0xFF97144D);
    if (lower.contains('kotak')) return const Color(0xFFED1C24);
    if (lower.contains('bajaj')) return const Color(0xFF003366);
    return AppColors.navy;
  }

  /// Skeleton shimmer placeholder while fetching suggestions
  Widget _buildSkeletonSuggestions() {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          // User Header Skeleton
          Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(height: 14),

          // Filters Skeleton
          Row(
            children: [
              Container(width: 90, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
              const SizedBox(width: 8),
              Container(width: 80, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
              const SizedBox(width: 8),
              Container(width: 100, height: 36, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10))),
            ],
          ),
          const SizedBox(height: 14),

          // 2 Bank Offer Cards Skeleton
          for (int i = 0; i < 2; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
            ),
        ],
      ),
    );
  }
}
