import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

class LoanTypeOption {
  final String title;
  final String subtitle;
  final String iconKey;

  const LoanTypeOption({
    required this.title,
    required this.subtitle,
    required this.iconKey,
  });
}

class EmploymentTypeOption {
  final String title;
  final String subtitle;
  final String iconKey;

  const EmploymentTypeOption({
    required this.title,
    required this.subtitle,
    required this.iconKey,
  });
}

/// GetX controller managing the 4-step Apply Loan Flow
class ApplyLoanController extends GetxController {
  // Step 1: Loan Type
  final selectedLoanType = 'Home loan'.obs;
  final isOtherLoansExpanded = false.obs;

  final loanTypes = const [
    LoanTypeOption(
      title: 'Home loan',
      subtitle: 'Buy or build a home',
      iconKey: 'home',
    ),
    LoanTypeOption(
      title: 'Mortgage loan',
      subtitle: 'Against your property',
      iconKey: 'property',
    ),
    LoanTypeOption(
      title: 'Business loan',
      subtitle: 'Grow your business',
      iconKey: 'business',
    ),
    LoanTypeOption(
      title: 'Personal loan',
      subtitle: 'For life\'s plans',
      iconKey: 'personal',
    ),
    LoanTypeOption(
      title: 'Car loan',
      subtitle: 'New or used car',
      iconKey: 'car',
    ),
    LoanTypeOption(
      title: 'CC / OD loan',
      subtitle: 'Working capital limit',
      iconKey: 'card',
    ),
  ];

  final otherLoanTypes = const [
    LoanTypeOption(
      title: 'Education loan',
      subtitle: 'Higher education in India or abroad',
      iconKey: 'education',
    ),
    LoanTypeOption(
      title: 'Machinery loan',
      subtitle: 'Finance new or used equipment',
      iconKey: 'machinery',
    ),
    LoanTypeOption(
      title: 'BT + Top-up loan',
      subtitle: 'Balance transfer with extra top-up',
      iconKey: 'bt_topup',
    ),
    LoanTypeOption(
      title: 'Agri loan',
      subtitle: 'Farming & allied agricultural activities',
      iconKey: 'agri',
    ),
  ];

  void toggleOtherLoans() {
    isOtherLoansExpanded.toggle();
  }

  void selectLoanType(String type) {
    selectedLoanType.value = type;
  }

  IconData getIconForLoanType(String title) {
    switch (title.toLowerCase()) {
      case 'home loan':
        return Icons.home_rounded;
      case 'mortgage loan':
        return Icons.account_balance_rounded;
      case 'business loan':
        return Icons.work_outline_rounded;
      case 'personal loan':
        return Icons.person_outline_rounded;
      case 'car loan':
        return Icons.directions_car_rounded;
      case 'cc / od loan':
      case 'cc- od loan':
        return Icons.credit_card_rounded;
      case 'education loan':
        return Icons.school_rounded;
      case 'machinery loan':
        return Icons.precision_manufacturing_rounded;
      case 'bt + top-up loan':
      case 'bt+top-up loan':
        return Icons.trending_up_rounded;
      case 'agri loan':
        return Icons.eco_rounded;
      default:
        return Icons.monetization_on_rounded;
    }
  }

  // Step 2: Loan Amount and Tenure
  final loanAmount = 450000.0.obs;
  final selectedTenureYears = 15.obs;
  final annualInterestRate = 9.5.obs;

  final tenureOptions = const [5, 10, 15, 20];
  final quickAmountPresets = const [100000.0, 300000.0, 450000.0, 1000000.0, 2500000.0];

  void setLoanAmount(double amount) {
    loanAmount.value = amount.clamp(50000.0, 5000000.0);
  }

  void setTenureYears(int years) {
    selectedTenureYears.value = years;
  }

  /// Accurate Indian EMI calculation: P * r * (1+r)^n / ((1+r)^n - 1)
  int get estimatedMonthlyEmi {
    final p = loanAmount.value;
    final r = (annualInterestRate.value / 12) / 100;
    final n = selectedTenureYears.value * 12;

    if (r == 0) return (p / n).round();
    final factor = math.pow(1 + r, n).toDouble();
    final emi = p * r * factor / (factor - 1);
    return emi.round();
  }

  /// Total Interest Payable = (EMI * n) - P
  int get totalInterestPayable {
    final emi = estimatedMonthlyEmi;
    final n = selectedTenureYears.value * 12;
    final totalPayment = emi * n;
    final interest = totalPayment - loanAmount.value.round();
    return math.max(0, interest);
  }

  /// Formatted currency string in Indian Numbering System (e.g. ₹4,50,000)
  String formatIndianCurrency(num amount) {
    final numStr = amount.round().toString();
    if (numStr.length <= 3) return '₹$numStr';

    final lastThree = numStr.substring(numStr.length - 3);
    final remaining = numStr.substring(0, numStr.length - 3);

    final buffer = StringBuffer();
    for (int i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }
    buffer.write(',');
    buffer.write(lastThree);

    return '₹${buffer.toString()}';
  }

  // Step 3: Employment Type
  final selectedEmploymentType = 'Salaried'.obs;

  final employmentTypes = const [
    EmploymentTypeOption(
      title: 'Salaried',
      subtitle: 'Regular monthly salary from an employer',
      iconKey: 'briefcase',
    ),
    EmploymentTypeOption(
      title: 'Self-employed / Business',
      subtitle: 'You run your own business or practice',
      iconKey: 'home_office',
    ),
    EmploymentTypeOption(
      title: 'Freelancer',
      subtitle: 'Project-based work for multiple clients',
      iconKey: 'laptop',
    ),
    EmploymentTypeOption(
      title: 'Pensioner',
      subtitle: 'Receiving retirement or pension benefits',
      iconKey: 'pension',
    ),
  ];

  void selectEmploymentType(String type) {
    selectedEmploymentType.value = type;
  }
}
