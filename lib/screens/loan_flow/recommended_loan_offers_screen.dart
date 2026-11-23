import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../controller/recommended_loan_offers_controller.dart';
import '../../models/loan_offer_model.dart';
import '../../theme/app_colors.dart';

/// Screen displaying Recommended Loan Offers (Bank Offers, Profile Match, & Cost Breakdown)
/// Uses [RecommendedLoanOffersController] and [LoanOfferItem] model for reactive state management.
/// Fully unified with canonical [AppColors] design tokens.
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
            _buildTopAppBar(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Properly Aligned Top Card (Loan Amount, Tenure, & CIBIL Badge)
                    _buildTopSummaryCard(controller),
                    const SizedBox(height: 14),

                    // 2. Alert / Info Banner
                    _buildAlertBanner(controller),
                    const SizedBox(height: 16),

                    // 3. Filter Tabs (Best match, Lowest rate, Lowest fee)
                    _buildFilterTabs(controller),
                    const SizedBox(height: 16),

                    // 4. Reactive Recommended Bank Offer Cards from Model using ListView.builder
                    Obx(
                      () => ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: controller.displayedOffers.length,
                        itemBuilder: (context, index) {
                          final offer = controller.displayedOffers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildOfferCard(controller, offer),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 5. "Why you're matched" Section from Model
                    _buildWhyMatchedSection(controller),
                    const SizedBox(height: 24),

                    // 6. "Cost breakdown · Top pick" Section from Model
                    _buildCostBreakdownSection(controller),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top App Bar with back button, screen title, and filter button
  Widget _buildTopAppBar(BuildContext context) {
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

          // Title
          const Expanded(
            child: Center(
              child: Text(
                'Loan offers',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),

          // Right Filter / Options Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line, width: 1.2),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 18,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  /// Properly designed Top Summary Card bound dynamically from [LoanOffersSummaryData] model
  Widget _buildTopSummaryCard(RecommendedLoanOffersController controller) {
    return Obx(() {
      final summary = controller.topSummary.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.dashboardCardGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left: Loan Type Pill Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.home_rounded, size: 14, color: AppColors.amber),
                  const SizedBox(width: 5),
                  Text(
                    summary.loanType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Middle: Loan Amount and Tenure Info
            Expanded(
              child: Text(
                summary.amountAndTenure,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Right: CIBIL Score Gold Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 12,
                    color: AppColors.navy,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    summary.cibilScore,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Alert / Info Banner indicating recommendations status
  Widget _buildAlertBanner(RecommendedLoanOffersController controller) {
    return Obx(() {
      if (!controller.isAiServerUnreachable.value) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warningAmberBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line, width: 1.1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: AppColors.warningAmber,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI server unreachable',
                    style: TextStyle(
                      color: AppColors.warningAmber,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Showing local recommendations instead.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: controller.isRetrying.value
                  ? null
                  : () => controller.retryAiRecommendations(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: controller.isRetrying.value
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.warningAmber,
                        ),
                      )
                    : const Text(
                        'Retry',
                        style: TextStyle(
                          color: AppColors.warningAmber,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Segmented Filter Pills (Best match, Lowest rate, Lowest fee) controlled via GetX
  Widget _buildFilterTabs(RecommendedLoanOffersController controller) {
    return Obx(() {
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
    });
  }

  /// Reusable Bank Offer Card rendered dynamically from [LoanOfferItem] model
  Widget _buildOfferCard(
    RecommendedLoanOffersController controller,
    LoanOfferItem offer,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: offer.isTopPick ? AppColors.amber : AppColors.line,
          width: offer.isTopPick ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Bank Logo + Title + Match Gauge
                Row(
                  children: [
                    // Bank Logo Square
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: offer.logoColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          offer.logoText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Bank Name & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.bankName,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            offer.policySubtitle,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Circular Match Gauge
                    _buildMatchGauge(offer.matchPercent),
                  ],
                ),
                const SizedBox(height: 14),

                // 2x2 Specs Container
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
                            child: _buildSpecItem('Interest rate', offer.interestRate),
                          ),
                          Expanded(
                            child: _buildSpecItem('Max loan amount', offer.maxAmount),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSpecItem('Tenure', offer.tenure),
                          ),
                          Expanded(
                            child: _buildSpecItem('Processing fee', offer.processingFee),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Branded Navy EMI Strip Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.indigo, AppColors.navy],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Est. EMI from',
                        style: TextStyle(
                          color: AppColors.indigoTint,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: offer.monthlyEmi,
                              style: const TextStyle(
                                color: AppColors.amber,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const TextSpan(
                              text: ' /month',
                              style: TextStyle(
                                color: AppColors.indigoTint,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Green Guidelines Checkpoint
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 15,
                      color: AppColors.successGreen,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Meets CIBIL and income guidelines',
                      style: TextStyle(
                        color: AppColors.successGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Buttons: "View details" & "Apply now +"
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => controller.showOfferDetails(offer),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.line, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'View details',
                            style: TextStyle(
                              color: AppColors.navy,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => controller.applyForOffer(offer),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Apply now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.add_rounded,
                                color: AppColors.amber,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Floating "Top pick" Gold Badge in top right corner
          if (offer.isTopPick)
            Positioned(
              top: -8,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Top pick',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Circular match gauge widget with percentage indicator
  Widget _buildMatchGauge(int percent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: percent / 100.0,
                strokeWidth: 3.2,
                backgroundColor: AppColors.line,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.successGreen),
              ),
              const Icon(
                Icons.check,
                size: 14,
                color: AppColors.successGreen,
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'match',
          style: TextStyle(
            color: AppColors.successGreen,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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

  /// Section 5: "Why you're matched" with profile strength & criteria grid from [WhyMatchedData]
  Widget _buildWhyMatchedSection(RecommendedLoanOffersController controller) {
    return Obx(() {
      final why = controller.whyMatched.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Why you're matched",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Profile Strength + %
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Profile strength',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${(why.profileStrength * 100).toInt()}%',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Linear Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: why.profileStrength,
                    minHeight: 6,
                    backgroundColor: AppColors.line,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.indigo),
                  ),
                ),
                const SizedBox(height: 16),

                // Criteria Grid Items (2 columns)
                if (why.criteria.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: why.criteria.map((crit) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final halfWidth = (MediaQuery.of(context).size.width - 76) / 2;
                          return SizedBox(
                            width: halfWidth,
                            child: _buildMatchCriterionItem(crit),
                          );
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 14),

                // Hint strip at bottom of matched section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.indigoTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: AppColors.indigo,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          why.hintText,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  /// Single Match Criterion block with icon
  Widget _buildMatchCriterionItem(MatchCriterion crit) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: crit.isSuccess ? AppColors.successGreenBg : AppColors.warningAmberBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                crit.isSuccess ? Icons.check : Icons.priority_high_rounded,
                size: 13,
                color: crit.isSuccess ? AppColors.successGreen : AppColors.warningAmber,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crit.title,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  crit.subtitle,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section 6: "Cost breakdown · Top pick" bound dynamically from [CostBreakdownData]
  Widget _buildCostBreakdownSection(RecommendedLoanOffersController controller) {
    return Obx(() {
      final cost = controller.costBreakdown.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cost breakdown · Top pick',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line, width: 1.2),
            ),
            child: Column(
              children: [
                _buildCostRow('Loan amount', cost.loanAmount),
                const Divider(color: AppColors.line, height: 20),
                _buildCostRow('Processing fee (1% + GST)', cost.processingFee),
                const Divider(color: AppColors.line, height: 20),
                _buildCostRow('Total interest', cost.totalInterest),
                const Divider(color: AppColors.line, height: 20),
                _buildCostRow('Monthly EMI', cost.monthlyEmi),
                const Divider(color: AppColors.line, height: 20),
                _buildCostRow(
                  'Total payable',
                  cost.totalPayable,
                  isHighlight: true,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  /// Single line in the cost breakdown card
  Widget _buildCostRow(String title, String amount, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isHighlight ? AppColors.textDark : AppColors.muted,
            fontSize: isHighlight ? 14 : 13,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: isHighlight ? AppColors.navy : AppColors.textDark,
            fontSize: isHighlight ? 16 : 13.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
