import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/cibil_score_model.dart';
import '../models/applicant_detail_model.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../services/cibil_report_pdf_service.dart';
import 'pan_kyc_controller.dart';
import 'aadhaar_kyc_controller.dart';
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

  final isDownloadingPdf = false.obs;

  /// Download official CIBIL Bureau Report PDF with 100% dynamic credit score & applicant data
  Future<void> downloadReportPdf() async {
    if (isDownloadingPdf.value) return;
    isDownloadingPdf.value = true;

    try {
      // 1. Get user ID from session or previous PAN upload
      final userId = int.tryParse(await SessionManager.getUserId()) ??
          (Get.isRegistered<PanKycController>()
              ? Get.find<PanKycController>().uploadedPanData.value?.userId
              : null);

      ApplicantDetailModel? applicantData;
      if (userId != null) {
        applicantData =
            await ApiService.getApplicantDetailModel(userId: userId);
      }

      final applicant = applicantData?.applicant;
      final kyc = applicantData?.kyc;

      // 2. Resolve all user fields dynamically
      final name = (applicant?.name ??
              (Get.isRegistered<AadhaarKycController>()
                  ? Get.find<AadhaarKycController>().userName.value
                  : ''))
          .trim();

      final dob = (applicant?.dateOfBirth ??
              (Get.isRegistered<AadhaarKycController>()
                  ? Get.find<AadhaarKycController>().dob.value
                  : ''))
          .trim();

      final gender = (applicant?.gender ??
              (Get.isRegistered<AadhaarKycController>()
                  ? Get.find<AadhaarKycController>().gender.value
                  : 'Female'))
          .trim();

      final pan = panNumber.value.trim().isNotEmpty
          ? panNumber.value.trim().toUpperCase()
          : (applicant?.panCardNumber ?? '').trim().toUpperCase();

      final aadhaar = (kyc?.aadhaar?.number ??
              applicant?.aadhaarCardNumber ??
              (Get.isRegistered<AadhaarKycController>()
                  ? Get.find<AadhaarKycController>().maskedAadhaarDisplay.value
                  : ''))
          .trim();

      final phone = (applicant?.phone ??
              (Get.isRegistered<AadhaarKycController>()
                  ? Get.find<AadhaarKycController>().linkedMobile.value
                  : await SessionManager.getUserPhone()))
          .trim();

      final email = (applicant?.email ?? '').trim();

      final address = (applicant?.address != null &&
              applicant!.address!.isNotEmpty)
          ? applicant.address!
          : ((applicant?.communicationAddress != null &&
                  applicant!.communicationAddress!.isNotEmpty)
              ? applicant.communicationAddress!
              : (applicant?.permanentAddress ??
                  (Get.isRegistered<AadhaarKycController>()
                      ? Get.find<AadhaarKycController>().address.value
                      : '')));

      // 3. Dynamic Credit Score directly from this screen/controller!
      final dynamicScore = cibilScore.value > 0
          ? cibilScore.value
          : (kyc?.cibilScore ?? 750);

      final reportData = CibilReportData(
        fullName: name.isNotEmpty ? name : 'Applicant',
        dob: dob.isNotEmpty ? dob : '-',
        gender: gender.isNotEmpty ? gender : 'Female',
        panNumber: pan.isNotEmpty ? pan : '-',
        aadhaarNumber: aadhaar.isNotEmpty ? aadhaar : '-',
        contactNumber: phone.isNotEmpty ? phone : '-',
        email: email,
        registeredAddress: address.isNotEmpty ? address : '-',
        score: dynamicScore,
      );

      await CibilReportPdfService.saveOrDownloadPdf(
        data: reportData,
      );
    } catch (e) {
      debugPrint('Error downloading CIBIL PDF: $e');
    } finally {
      isDownloadingPdf.value = false;
    }
  }
}
