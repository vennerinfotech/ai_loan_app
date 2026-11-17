import 'dart:math' as math;
import 'package:get/get.dart';

/// Controller for EMI Calculator with dynamic reactive calculation
class EmiCalculatorController extends GetxController {
  // Loan Amount in INR (min 50k, max 50L)
  final loanAmount = 450000.0.obs;
  final minLoanAmount = 50000.0;
  final maxLoanAmount = 5000000.0;

  // Annual Interest Rate in % (min 6%, max 24%)
  final interestRate = 9.5.obs;
  final minInterestRate = 6.0;
  final maxInterestRate = 24.0;

  // Tenure in Years (min 1 yr, max 30 yrs)
  final tenureYears = 15.0.obs;
  final minTenure = 1.0;
  final maxTenure = 30.0;

  /// Monthly EMI using reducing balance formula: [P * r * (1 + r)^n] / [(1 + r)^n - 1]
  int get monthlyEmi {
    final p = loanAmount.value;
    final r = (interestRate.value / 12) / 100;
    final n = tenureYears.value * 12;

    if (r == 0) return (p / n).round();

    final powFactor = math.pow(1 + r, n);
    final emi = (p * r * powFactor) / (powFactor - 1);
    return emi.round();
  }

  /// Total amount payable over tenure
  int get totalPayable {
    final n = (tenureYears.value * 12).round();
    return monthlyEmi * n;
  }

  /// Total interest payable
  int get totalInterest {
    final interest = totalPayable - loanAmount.value.round();
    return interest > 0 ? interest : 0;
  }

  /// Principal fraction for the donut chart (0.0 to 1.0)
  double get principalRatio {
    final total = totalPayable;
    if (total <= 0) return 0.5;
    return (loanAmount.value / total).clamp(0.05, 0.95);
  }

  /// Format currency helper: e.g. "₹4,50,000"
  String formatCurrency(num amount) {
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
    // Snap to nearest 10,000 for smooth usability
    loanAmount.value = (val / 10000).round() * 10000.0;
  }

  void updateInterestRate(double val) {
    // Snap to 0.1% steps
    interestRate.value = (val * 10).round() / 10.0;
  }

  void updateTenure(double val) {
    // Snap to full year steps
    tenureYears.value = val.roundToDouble();
  }
}
