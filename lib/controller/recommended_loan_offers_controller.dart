import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../models/loan_offer_model.dart';
import '../screens/loan_flow/application_status_screen.dart';
import '../theme/app_colors.dart';

/// GetX controller managing state, filtering, and interactions for Recommended Loan Offers
class RecommendedLoanOffersController extends GetxController {
  // Filter Tabs
  final selectedFilterIndex = 0.obs;
  final filters = const ['Best match', 'Lowest rate', 'Lowest fee'];

  // AI Server unreachable alert state
  final isAiServerUnreachable = true.obs;
  final isRetrying = false.obs;

  // Top Summary Card Data
  final topSummary = const LoanOffersSummaryData(
    loanType: 'Home loan',
    amountAndTenure: '₹4,50,000 · 15 yrs',
    cibilScore: 'CIBIL 762',
  ).obs;

  // Master and filtered Loan Offers
  final allOffers = <LoanOfferItem>[].obs;
  final displayedOffers = <LoanOfferItem>[].obs;

  // Why You're Matched Data
  final whyMatched = const WhyMatchedData(
    profileStrength: 0.8,
    criteria: [
      MatchCriterion(title: 'CIBIL score', subtitle: '762 · Good', isSuccess: true),
      MatchCriterion(title: 'KYC', subtitle: 'Aadhaar + PAN', isSuccess: true),
      MatchCriterion(title: 'Employment', subtitle: 'Salaried', isSuccess: true),
      MatchCriterion(title: 'Loan request', subtitle: '₹4.5L · 15 yrs', isSuccess: true),
      MatchCriterion(title: 'Documents', subtitle: '2 of 4 added', isSuccess: false),
      MatchCriterion(title: 'Co-applicant', subtitle: '1 added', isSuccess: true),
    ],
    hintText:
        'Upload Form 16 / ITR and Employee ID to complete your profile and unlock more offers.',
  ).obs;

  // Cost Breakdown Data
  final costBreakdown = const CostBreakdownData(
    loanAmount: '₹4,50,000',
    processingFee: '₹5,310',
    totalInterest: '₹3,47,639',
    monthlyEmi: '₹4,431',
    totalPayable: '₹8,02,949',
  ).obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialOffers();
  }

  void _loadInitialOffers() {
    final list = [
      const LoanOfferItem(
        id: 'hdfc_home_loan',
        bankName: 'HDFC Bank',
        policySubtitle: 'Home loan policy',
        logoText: 'HD',
        logoColor: Color(0xFF004C8F),
        interestRate: '8.5% – 10.5%',
        interestRateValue: 8.5,
        maxAmount: '₹150L',
        tenure: '20 years',
        processingFee: '1% + GST',
        processingFeeValue: 1.0,
        monthlyEmi: '₹4,431',
        matchPercent: 95,
        isTopPick: true,
        keyFeatures: [
          'Zero prepayment penalty on floating rate loans',
          'Quick sanction within 48 business hours',
          'Transparent charges with zero hidden fees',
          'Digital documentation and door-step assistance',
        ],
      ),
      const LoanOfferItem(
        id: 'idfc_home_loan',
        bankName: 'IDFC FIRST Bank',
        policySubtitle: 'Home loan',
        logoText: 'ID',
        logoColor: Color(0xFF9E1B32),
        interestRate: '8.5% – 10.5%',
        interestRateValue: 8.75,
        maxAmount: '₹150L',
        tenure: '20 years',
        processingFee: '1% + GST',
        processingFeeValue: 1.0,
        monthlyEmi: '₹4,431',
        matchPercent: 92,
        isTopPick: false,
        keyFeatures: [
          'Attractive interest rates starting at 8.75%',
          'Flexible repayment tenure up to 30 years',
          'Minimal documentation with instant e-approval',
        ],
      ),
      const LoanOfferItem(
        id: 'bajaj_home_loan',
        bankName: 'Bajaj Finserv',
        policySubtitle: 'Home loan',
        logoText: 'BF',
        logoColor: Color(0xFF003366),
        interestRate: '8.5% – 10.5%',
        interestRateValue: 8.6,
        maxAmount: '₹150L',
        tenure: '20 years',
        processingFee: '1% + GST',
        processingFeeValue: 1.2,
        monthlyEmi: '₹4,431',
        matchPercent: 88,
        isTopPick: false,
        keyFeatures: [
          'Top-up loan facility available up to ₹1 Crore',
          'Customizable EMI options and part-prepayment facility',
        ],
      ),
      const LoanOfferItem(
        id: 'kotak_home_loan',
        bankName: 'Kotak Mahindra Bank',
        policySubtitle: 'Home loan',
        logoText: 'KM',
        logoColor: Color(0xFFED1C24),
        interestRate: '8.5% – 10.5%',
        interestRateValue: 8.7,
        maxAmount: '₹150L',
        tenure: '20 years',
        processingFee: '1% + GST',
        processingFeeValue: 0.8,
        monthlyEmi: '₹4,431',
        matchPercent: 85,
        isTopPick: false,
        keyFeatures: [
          'Special concession for women borrowers',
          'Speedy processing with doorstep document pickup',
        ],
      ),
    ];

    allOffers.assignAll(list);
    _applySorting();
  }

  /// Change active filter tab and sort offers
  void changeFilter(int index) {
    if (selectedFilterIndex.value != index) {
      selectedFilterIndex.value = index;
      _applySorting();
    }
  }

  void _applySorting() {
    final list = List<LoanOfferItem>.from(allOffers);
    if (selectedFilterIndex.value == 0) {
      // Best match (by match percentage descending)
      list.sort((a, b) => b.matchPercent.compareTo(a.matchPercent));
    } else if (selectedFilterIndex.value == 1) {
      // Lowest rate (by interest rate ascending)
      list.sort((a, b) => a.interestRateValue.compareTo(b.interestRateValue));
    } else if (selectedFilterIndex.value == 2) {
      // Lowest fee (by processing fee ascending)
      list.sort((a, b) => a.processingFeeValue.compareTo(b.processingFeeValue));
    }
    displayedOffers.assignAll(list);
  }

  /// Retry AI recommendations action
  Future<void> retryAiRecommendations() async {
    isRetrying.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isRetrying.value = false;
    Get.snackbar(
      'Recommendations Updated',
      'Local loan offers re-analyzed for your profile.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.navy,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  /// Action on tapping "Apply now +" showing success confirmation dialog
  void applyForOffer(LoanOfferItem offer) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success checkmark badge icon
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: AppColors.successGreenBg,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.successGreen,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Application Initiated',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),

              // Exact message sentence from reference screenshot
              Text(
                'Application for ${offer.bankName} Policy has been initiated successfully!\nOur team will contact you shortly.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),

              // "OK" button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.to(() => const ApplicationStatusScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Show detailed modal for selected offer
  void showOfferDetails(LoanOfferItem offer) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${offer.bankName} Details',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close_rounded, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Key Features:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            ...offer.keyFeatures.map(
              (feat) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppColors.successGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feat,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  applyForOffer(offer);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply with this offer',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
