import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/dashboard_response_model.dart';
import '../models/emi_calculation_model.dart';
import '../services/api_service.dart';
import 'dashboard_controller.dart';

/// Controller for EMI Calculator with dynamic reactive calculation from API.
/// Synchronizes slider configurations from GET /dashboard and calculates via POST /emi-calculate.
/// Provides immediate mathematical local responsiveness during slider drag and syncs with the API response.
class EmiCalculatorController extends GetxController {
  // Loan Amount in INR (Dynamic from dashboard API with standard fallback boundaries)
  final loanAmount = 500000.0.obs;
  final minLoanAmount = 50000.0.obs;
  final maxLoanAmount = 5000000.0.obs;
  final stepLoanAmount = 10000.0.obs;

  // Annual Interest Rate in % (Dynamic from dashboard API)
  final interestRate = 9.5.obs;
  final minInterestRate = 8.5.obs;
  final maxInterestRate = 24.0.obs;
  final stepInterestRate = 0.1.obs;

  // Tenure in Years (Dynamic from dashboard API)
  final tenureYears = 3.0.obs; // 36 months
  final minTenure = 0.5.obs;   // 6 months
  final maxTenure = 5.0.obs;   // 60 months
  final stepTenure = 0.5.obs;

  // Result metrics (Synchronized from API)
  final monthlyEmi = 16016.obs;
  final totalPayable = 576593.obs;
  final totalInterest = 76593.obs;
  final principalPercent = 86.7.obs;
  final interestPercent = 13.3.obs;
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
        if (s.min != null && s.min! > 0) minLoanAmount.value = s.min!.toDouble();
        if (s.max != null && s.max! > 0) maxLoanAmount.value = s.max!.toDouble();
        if (s.step != null && s.step! > 0) stepLoanAmount.value = s.step!.toDouble();
        if (s.defaultValue != null && s.defaultValue! > 0) loanAmount.value = s.defaultValue!.toDouble();
      }

      // 2. Interest Rate Sliders
      if (emiCalc.sliders?.interestRate != null) {
        final s = emiCalc.sliders!.interestRate!;
        if (s.min != null && s.min! > 0) minInterestRate.value = s.min!.toDouble();
        if (s.max != null && s.max! > 0) maxInterestRate.value = s.max!.toDouble();
        if (s.step != null && s.step! > 0) stepInterestRate.value = s.step!.toDouble();
        if (s.defaultValue != null && s.defaultValue! > 0) interestRate.value = s.defaultValue!.toDouble();
      }

      // 3. Tenure Sliders (months -> years)
      if (emiCalc.sliders?.tenureMonths != null) {
        final s = emiCalc.sliders!.tenureMonths!;
        if (s.min != null && s.min! > 0) minTenure.value = s.min!.toDouble() / 12.0;
        if (s.max != null && s.max! > 0) maxTenure.value = s.max!.toDouble() / 12.0;
        if (s.step != null && s.step! > 0) stepTenure.value = s.step!.toDouble() / 12.0;
        if (s.defaultValue != null && s.defaultValue! > 0) tenureYears.value = s.defaultValue!.toDouble() / 12.0;
      }

      // 4. Default API Results
      if (emiCalc.result != null) {
        final r = emiCalc.result!;
        if (r.loanAmount != null && r.loanAmount! > 0) loanAmount.value = r.loanAmount!.toDouble();
        if (r.interestRate != null && r.interestRate! > 0) interestRate.value = r.interestRate!.toDouble();
        if (r.tenureMonths != null && r.tenureMonths! > 0) tenureYears.value = r.tenureMonths!.toDouble() / 12.0;
        if (r.monthlyEmi != null && r.monthlyEmi! > 0) monthlyEmi.value = r.monthlyEmi!.toInt();
        if (r.totalInterest != null && r.totalInterest! > 0) totalInterest.value = r.totalInterest!.toInt();
        if (r.totalPayable != null && r.totalPayable! > 0) totalPayable.value = r.totalPayable!.toInt();
        if (r.principalPercent != null && r.principalPercent! > 0) principalPercent.value = r.principalPercent!.toDouble();
        if (r.interestPercent != null && r.interestPercent! > 0) interestPercent.value = r.interestPercent!.toDouble();
      }
      isLoaded.value = true;
    } else {
      // Calculate initial values via API if dashboard config is unavailable
      calculateEmiApi();
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

  /// Instant local mathematical estimation for smooth 60fps slider dragging
  void _calculateLocalEmi() {
    final p = loanAmount.value;
    final annualRate = interestRate.value;
    final months = (tenureYears.value * 12).round();

    if (p <= 0 || months <= 0) return;

    if (annualRate <= 0) {
      final emi = (p / months).round();
      monthlyEmi.value = emi;
      totalPayable.value = p.round();
      totalInterest.value = 0;
      principalPercent.value = 100.0;
      interestPercent.value = 0.0;
      return;
    }

    final r = annualRate / (12 * 100);
    final powFactor = math.pow(1 + r, months);
    final emi = (p * r * powFactor / (powFactor - 1)).round();

    final total = emi * months;
    final interest = total - p.round();

    monthlyEmi.value = emi;
    totalInterest.value = interest > 0 ? interest : 0;
    totalPayable.value = total;
    if (total > 0) {
      principalPercent.value = double.parse((p / total * 100).toStringAsFixed(1));
      interestPercent.value = double.parse((interest / total * 100).toStringAsFixed(1));
    }
  }

  void _scheduleCalculation() {
    _calculateLocalEmi();
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
