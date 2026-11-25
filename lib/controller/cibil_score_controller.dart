import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/cibil_score_model.dart';
import '../services/api_service.dart';
import 'pan_kyc_controller.dart';
import 'dashboard_controller.dart';

/// GetX Controller for CIBIL Credit Score fetching and display
class CibilScoreController extends GetxController {
  final isLoading = false.obs;
  final cibilScoreData = Rxn<CibilScoreData>();
  final cibilData = Rxn<CibilData>();

  // Reactive attributes for UI
  final cibilScore = 0.obs;
  final panNumber = ''.obs;
  final reportDate = ''.obs;
  final provider = 'CIBIL TransUnion'.obs;
  final scoreRating = 'Good'.obs;

  @override
  void onInit() {
    super.onInit();

    // Default report date from current DateTime.now()
    reportDate.value = formatReportDate(DateTime.now());

    // Pre-populate score & rating from DashboardController so UI doesn't flash 0
    if (Get.isRegistered<DashboardController>()) {
      final dash = Get.find<DashboardController>();
      if (dash.cibilScore.value > 0) {
        cibilScore.value = dash.cibilScore.value;
        scoreRating.value = dash.cibilStatus.value.isNotEmpty
            ? dash.cibilStatus.value
            : getRatingForScore(dash.cibilScore.value);
      }
    }

    // Pre-populate PAN from PanKycController if registered
    if (Get.isRegistered<PanKycController>()) {
      final pan = Get.find<PanKycController>().panNumber.value.trim();
      if (pan.isNotEmpty) {
        panNumber.value = pan;
      }
    }

    // Fetch live CIBIL score from POST /loan/cibil-score
    fetchCibilScore();
  }

  /// Formats a DateTime using intl DateFormat into 'MMM dd, yyyy' (e.g. 'Dec 09, 2024')
  static String formatReportDate([DateTime? dt]) {
    final target = dt ?? DateTime.now();
    return DateFormat('MMM dd, yyyy').format(target);
  }

  /// Calculates rating string from numerical score:
  /// - Below 650: Poor
  /// - 650–699: Average
  /// - 700–749: Good
  /// - 750–900: Excellent
  String getRatingForScore(int score) {
    if (score >= 750) return 'Excellent';
    if (score >= 700) return 'Good';
    if (score >= 650) return 'Average';
    return 'Poor';
  }

  /// Fetch CIBIL Score from POST /loan/cibil-score
  Future<bool> fetchCibilScore({String? pan}) async {
    String targetPan = (pan ?? '').trim();
    if (targetPan.isEmpty && panNumber.value.trim().isNotEmpty) {
      targetPan = panNumber.value.trim();
    } else if (targetPan.isEmpty && Get.isRegistered<PanKycController>()) {
      targetPan = Get.find<PanKycController>().panNumber.value.trim();
    }

    isLoading.value = true;

    try {
      final response = await ApiService.fetchCibilScore(
        panNumber: targetPan.isNotEmpty ? targetPan : null,
      );
      isLoading.value = false;

      final isSuccess = response['success'] == true ||
          response['status_code'] == 200;

      if (isSuccess && response['data'] != null && response['data'] is Map) {
        // Parse directly into CibilScoreData model
        final data = CibilScoreData.fromJson(Map<String, dynamic>.from(response['data']));
        cibilScoreData.value = data;

        // Store separate CIBIL data model
        final separateCibilData = data.cibilData;
        cibilData.value = separateCibilData;

        if (data.panNumber != null && data.panNumber!.isNotEmpty) {
          panNumber.value = data.panNumber!;
        }

        if (separateCibilData != null) {
          if (separateCibilData.cibilScore != null) {
            cibilScore.value = separateCibilData.cibilScore!;
            scoreRating.value = getRatingForScore(separateCibilData.cibilScore!);

            // Synchronize with DashboardController if registered
            if (Get.isRegistered<DashboardController>()) {
              final dashController = Get.find<DashboardController>();
              dashController.cibilScore.value = separateCibilData.cibilScore!;
              dashController.cibilStatus.value = scoreRating.value;
            }
          }
          // Parse report date from API if available
          if (separateCibilData.reportDate != null &&
              separateCibilData.reportDate!.isNotEmpty) {
            final parsedDate = DateTime.tryParse(separateCibilData.reportDate!);
            reportDate.value = parsedDate != null
                ? formatReportDate(parsedDate)
                : separateCibilData.reportDate!;
          } else {
            reportDate.value = formatReportDate(DateTime.now());
          }
          // Parse provider from API if available
          if (separateCibilData.provider != null &&
              separateCibilData.provider!.isNotEmpty) {
            provider.value = separateCibilData.provider!;
          } else {
            provider.value = 'CIBIL TransUnion';
          }
        } else {
          reportDate.value = formatReportDate(DateTime.now());
          provider.value = 'CIBIL TransUnion';
        }

        return true;
      } else {
        final errorMsg = ApiService.getErrorMessage(response);
        debugPrint('Fetch CIBIL Score Error: $errorMsg');
        Get.snackbar(
          'Error',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('Fetch CIBIL Score Exception: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch CIBIL score: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
  }
}
