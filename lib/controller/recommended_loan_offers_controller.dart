import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../models/loan_suggestions_model.dart';
import '../services/api_service.dart';
import '../screens/loan_flow/application_status_screen.dart';
import '../theme/app_colors.dart';

/// Controller managing live Bank Loan Suggestions fetched directly from API
class RecommendedLoanOffersController extends GetxController {
  // Loading state
  final isLoading = false.obs;

  // User details returned directly from GET /loan-suggestions
  final suggestionsUser = Rxn<LoanSuggestionUser>();

  // Suggestions list directly from API
  final suggestions = <LoanSuggestionItem>[].obs;
  final displayedSuggestions = <LoanSuggestionItem>[].obs;

  // Filter tabs: 'Best match', 'Lowest rate', 'Lowest fee'
  final selectedFilterIndex = 0.obs;
  final filters = const ['Best match', 'Lowest rate', 'Lowest fee'];

  @override
  void onInit() {
    super.onInit();
    fetchLoanSuggestions();
  }

  /// Fetch Bank Loan Suggestions API: GET {{baseUrl}}/loan-suggestions
  Future<void> fetchLoanSuggestions() async {
    isLoading.value = true;
    try {
      final res = await ApiService.getLoanSuggestions();
      if (res['success'] == true || res['status_code'] == 200) {
        final model = LoanSuggestionsResponseModel.fromJson(res);
        if (model.data != null) {
          suggestionsUser.value = model.data!.user;
          suggestions.assignAll(model.data!.suggestions);
          _applySorting();
        }
      } else {
        final msg = ApiService.getErrorMessage(res);
        Get.snackbar(
          'Notice',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.navy,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      debugPrint('Exception in fetchLoanSuggestions: $e');
      Get.snackbar(
        'Notice',
        'Failed to fetch loan suggestions. Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.navy,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Change active filter tab and sort suggestions
  void changeFilter(int index) {
    if (selectedFilterIndex.value != index) {
      selectedFilterIndex.value = index;
      _applySorting();
    }
  }

  void _applySorting() {
    final list = List<LoanSuggestionItem>.from(suggestions);
    if (selectedFilterIndex.value == 0) {
      // Best match (by match_score descending)
      list.sort((a, b) => (b.matchScore ?? 0).compareTo(a.matchScore ?? 0));
    } else if (selectedFilterIndex.value == 1) {
      // Lowest rate (by interest rate value ascending)
      list.sort((a, b) => a.interestRateValue.compareTo(b.interestRateValue));
    } else if (selectedFilterIndex.value == 2) {
      // Lowest fee (by processing fee value ascending)
      list.sort((a, b) => a.processingFeeValue.compareTo(b.processingFeeValue));
    }
    displayedSuggestions.assignAll(list);
  }

  /// Action on tapping "Apply now"
  void applyForOffer(LoanSuggestionItem offer) {
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
              Text(
                'Application for ${offer.bankName ?? "Selected Bank"} has been initiated successfully!\nOur team will contact you shortly.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
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
}
