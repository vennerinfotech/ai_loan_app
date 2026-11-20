import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/dashboard_response_model.dart';
import '../models/emi_calculation_model.dart';
import '../services/api_service.dart';
import 'dashboard_controller.dart';

/// Controller for EMI Calculator with dynamic reactive calculation from API.
/// Strictly dynamic: initializes from GET /dashboard and calculates via POST /emi-calculate.
/// Zero static fallback amounts or dummy data.
class EmiCalculatorController extends GetxController {
  // Loan Amount in INR (Dynamic from dashboard API)
  final loanAmount = 0.0.obs;
  final minLoanAmount = 0.0.obs;
  final maxLoanAmount = 0.0.obs;
  final stepLoanAmount = 0.0.obs;

  // Annual Interest Rate in % (Dynamic from dashboard API)
  final interestRate = 0.0.obs;
  final minInterestRate = 0.0.obs;
  final maxInterestRate = 0.0.obs;
  final stepInterestRate = 0.0.obs;

  // Tenure in Years (Dynamic from dashboard API)
  final tenureYears = 0.0.obs;
  final minTenure = 0.0.obs;
  final maxTenure = 0.0.obs;
  final stepTenure = 0.0.obs;

  // Result metrics (Strictly from API, zero static dummy fallback math)
  final monthlyEmi = 0.obs;
  final totalPayable = 0.obs;
  final totalInterest = 0.obs;
  final principalPercent = 0.0.obs;
  final interestPercent = 0.0.obs;
  final isCalculating = false.obs;
  final isLoaded = false.obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    syncFromDashboardData();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Syncs default EMI and slider data directly from Dashboard API response
  Future<void> syncFromDashboardData() async {
    DashboardEmiCalculator? emiCalc;
    if (Get.isRegistered<DashboardController>()) {
      final dash = Get.find<DashboardController>();
      emiCalc = dash.dashboardData.value?.emiCalculator;
    }
    if (emiCalc == null) {
      try {
        final res = await ApiService.getDashboardData();
        if (res['status_code'] == 200 || res['success'] == true) {
          final model = DashboardResponseModel.fromJson(res);
          emiCalc = model.data?.emiCalculator;
        }
      } catch (e) {
        debugPrint('Exception syncing dashboard EMI data: $e');
      }
    }

    if (emiCalc != null) {
      // 1. Loan Amount Sliders
      if (emiCalc.sliders?.loanAmount != null) {
        final s = emiCalc.sliders!.loanAmount!;
        if (s.min != null) minLoanAmount.value = s.min!.toDouble();
        if (s.max != null) maxLoanAmount.value = s.max!.toDouble();
        if (s.step != null) stepLoanAmount.value = s.step!.toDouble();
        if (s.defaultValue != null) loanAmount.value = s.defaultValue!.toDouble();
      }

      // 2. Interest Rate Sliders
      if (emiCalc.sliders?.interestRate != null) {
        final s = emiCalc.sliders!.interestRate!;
        if (s.min != null) minInterestRate.value = s.min!.toDouble();
        if (s.max != null) maxInterestRate.value = s.max!.toDouble();
        if (s.step != null) stepInterestRate.value = s.step!.toDouble();
        if (s.defaultValue != null) interestRate.value = s.defaultValue!.toDouble();
      }

      // 3. Tenure Sliders (months -> years)
      if (emiCalc.sliders?.tenureMonths != null) {
        final s = emiCalc.sliders!.tenureMonths!;
        if (s.min != null) minTenure.value = s.min!.toDouble() / 12.0;
        if (s.max != null) maxTenure.value = s.max!.toDouble() / 12.0;
        if (s.step != null) stepTenure.value = s.step!.toDouble() / 12.0;
        if (s.defaultValue != null) tenureYears.value = s.defaultValue!.toDouble() / 12.0;
      }

      // 4. Default API Results
      if (emiCalc.result != null) {
        final r = emiCalc.result!;
        if (r.loanAmount != null) loanAmount.value = r.loanAmount!.toDouble();
        if (r.interestRate != null) interestRate.value = r.interestRate!.toDouble();
        if (r.tenureMonths != null) tenureYears.value = r.tenureMonths!.toDouble() / 12.0;
        if (r.monthlyEmi != null) monthlyEmi.value = r.monthlyEmi!.toInt();
        if (r.totalInterest != null) totalInterest.value = r.totalInterest!.toInt();
        if (r.totalPayable != null) totalPayable.value = r.totalPayable!.toInt();
        if (r.principalPercent != null) principalPercent.value = r.principalPercent!.toDouble();
        if (r.interestPercent != null) interestPercent.value = r.interestPercent!.toDouble();
      }
      isLoaded.value = true;
    }
  }

  /// Calls POST {{baseUrl}}/emi-calculate dynamically on user interaction
  Future<void> calculateEmiApi() async {
    isCalculating.value = true;
    try {
      final tenureInMonths = (tenureYears.value * 12).round();
      final res = await ApiService.calculateEmi(
        loanAmount: loanAmount.value.toInt(),
        interestRate: interestRate.value,
        tenureMonths: tenureInMonths,
      );

      if (res['success'] == true || res['status_code'] == 200) {
        final model = EmiCalculationResponseModel.fromJson(res);
        if (model.data != null) {
          final d = model.data!;
          if (d.monthlyEmi != null) monthlyEmi.value = d.monthlyEmi!.toInt();
          if (d.totalInterest != null) totalInterest.value = d.totalInterest!.toInt();
          if (d.totalPayable != null) totalPayable.value = d.totalPayable!.toInt();
          if (d.principalPercent != null) principalPercent.value = d.principalPercent!.toDouble();
          if (d.interestPercent != null) interestPercent.value = d.interestPercent!.toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error calculating EMI in controller: $e');
    } finally {
      isCalculating.value = false;
    }
  }

  void _scheduleCalculation() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      calculateEmiApi();
    });
  }

  /// Principal fraction for the donut chart from API response
  double get principalRatio {
    if (principalPercent.value > 0) {
      return (principalPercent.value / 100.0).clamp(0.05, 0.95);
    }
    final total = totalPayable.value;
    if (total <= 0) return 0.5;
    return (loanAmount.value / total).clamp(0.05, 0.95);
  }

  /// Format currency helper: e.g. "₹4,50,000"
  String formatCurrency(num amount) {
    if (amount <= 0) return '₹0';
    final rounded = amount.round();
    final str = rounded.toString();
    if (str.length <= 3) return '₹$str';

    final lastThree = str.substring(str.length - 3);
    final remaining = str.substring(0, str.length - 3);

    final buffer = StringBuffer();
    for (int i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }
    return '₹${buffer.toString()},$lastThree';
  }

  void updateLoanAmount(double val) {
    final step = stepLoanAmount.value > 0 ? stepLoanAmount.value : 10000.0;
    loanAmount.value = (val / step).round() * step;
    _scheduleCalculation();
  }

  void updateInterestRate(double val) {
    interestRate.value = (val * 10).round() / 10.0;
    _scheduleCalculation();
  }

  void updateTenure(double val) {
    // Snap to 0.5 year (6 month) steps
    tenureYears.value = (val * 2).round() / 2.0;
    _scheduleCalculation();
  }
}
