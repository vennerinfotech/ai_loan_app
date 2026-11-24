import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';
import 'loan_suggestions_model.dart';

/// Item model representing a recommended bank loan offer
class LoanOfferItem {
  final String id;
  final String bankName;
  final String policySubtitle;
  final String logoText;
  final Color logoColor;
  final String interestRate;
  final double interestRateValue;
  final String maxAmount;
  final String tenure;
  final String processingFee;
  final double processingFeeValue;
  final String monthlyEmi;
  final int matchPercent;
  final bool isTopPick;
  final List<String> keyFeatures;
  final String? reason;
  final List<String> pros;
  final List<String> cons;

  const LoanOfferItem({
    required this.id,
    required this.bankName,
    required this.policySubtitle,
    required this.logoText,
    required this.logoColor,
    required this.interestRate,
    required this.interestRateValue,
    required this.maxAmount,
    required this.tenure,
    required this.processingFee,
    required this.processingFeeValue,
    required this.monthlyEmi,
    required this.matchPercent,
    this.isTopPick = false,
    this.keyFeatures = const [],
    this.reason,
    this.pros = const [],
    this.cons = const [],
  });

  /// Factory constructor to map from API LoanSuggestionItem
  factory LoanOfferItem.fromSuggestion(
    LoanSuggestionItem item, {
    bool isTopPick = false,
  }) {
    // Generate logo initials
    String initials = 'BK';
    final name = (item.bankName ?? '').trim();
    if (name.isNotEmpty) {
      if (name.contains('(') && name.contains(')')) {
        final insideParen = RegExp(r'\((.*?)\)').firstMatch(name)?.group(1);
        if (insideParen != null && insideParen.isNotEmpty) {
          initials = insideParen.toUpperCase();
        }
      }
      if (initials == 'BK') {
        final words = name.split(RegExp(r'\s+'));
        if (words.length >= 2) {
          initials = '${words[0][0]}${words[1][0]}'.toUpperCase();
        } else if (words.isNotEmpty && words[0].isNotEmpty) {
          initials = words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
        }
      }
    }

    // Assign branded bank color
    Color bankColor = const Color(0xFF004C8F);
    final lower = name.toLowerCase();
    if (lower.contains('hdfc')) {
      bankColor = const Color(0xFF004C8F);
    } else if (lower.contains('sbi') || lower.contains('state bank')) {
      bankColor = const Color(0xFF0083CA);
    } else if (lower.contains('icici')) {
      bankColor = const Color(0xFF9E1B32);
    } else if (lower.contains('axis')) {
      bankColor = const Color(0xFF97144D);
    } else if (lower.contains('kotak')) {
      bankColor = const Color(0xFFED1C24);
    } else if (lower.contains('bajaj')) {
      bankColor = const Color(0xFF003366);
    } else {
      bankColor = AppColors.navy;
    }

    // Extract numeric interest rate for sorting
    final rateClean = (item.interestRate ?? '').replaceAll(RegExp(r'[^0-9.]'), '');
    final double rateVal = double.tryParse(rateClean) ?? 8.5;

    // Extract numeric fee for sorting
    final feeClean = (item.processingFee ?? '').replaceAll(RegExp(r'[^0-9.]'), '');
    final double feeVal = double.tryParse(feeClean) ??
        (item.processingFee?.toLowerCase() == 'nil' ? 0.0 : 1.0);

    // Calculate approximate monthly EMI based on max amount or default ₹25L
    String calculatedEmi = '₹12,450';
    try {
      double p = 2500000;
      final maxClean = (item.maxLoanAmount ?? '').replaceAll(RegExp(r'[^0-9]'), '');
      if (maxClean.isNotEmpty) {
        final parsedP = double.tryParse(maxClean);
        if (parsedP != null && parsedP > 0) {
          p = parsedP > 10000000 ? 5000000 : parsedP;
        }
      }
      final double annualRate = rateVal / 100;
      final double monthlyRate = annualRate / 12;
      final tenureClean = (item.tenure ?? '').replaceAll(RegExp(r'[^0-9]'), '');
      final int tenureYears = int.tryParse(tenureClean) ?? 20;
      final int n = tenureYears * 12;
      if (monthlyRate > 0 && n > 0) {
        final double emi = (p * monthlyRate * math.pow(1 + monthlyRate, n)) /
            (math.pow(1 + monthlyRate, n) - 1);
        calculatedEmi =
            '₹${emi.round().toString().replaceAllMapped(RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))'), (Match m) => '${m[1]},')}';
      }
    } catch (_) {}

    return LoanOfferItem(
      id: item.id?.toString() ?? UniqueKey().toString(),
      bankName: item.bankName ?? 'Bank Offer',
      policySubtitle: '${item.bankName ?? "Bank"} recommended scheme',
      logoText: initials,
      logoColor: bankColor,
      interestRate: item.interestRate ?? '8.50%',
      interestRateValue: rateVal,
      maxAmount: item.maxLoanAmount ?? '₹50,00,000',
      tenure: item.tenure ?? '20 Years',
      processingFee: item.processingFee ?? '0.5%',
      processingFeeValue: feeVal,
      monthlyEmi: calculatedEmi,
      matchPercent: item.matchScore ?? 90,
      isTopPick: isTopPick,
      keyFeatures: item.pros.isNotEmpty
          ? item.pros
          : const ['Quick digital approval', 'Zero hidden charges'],
      reason: item.reason,
      pros: item.pros,
      cons: item.cons,
    );
  }

  factory LoanOfferItem.fromJson(Map<String, dynamic> json) {
    Color parsedColor = const Color(0xFF004C8F);
    if (json['logo_color'] != null) {
      final colorStr = json['logo_color'].toString().replaceAll('#', '');
      final intVal = int.tryParse(colorStr, radix: 16);
      if (intVal != null) {
        parsedColor = Color(colorStr.length <= 6 ? (0xFF000000 | intVal) : intVal);
      }
    }

    return LoanOfferItem(
      id: json['id']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? '',
      policySubtitle: json['policy_subtitle']?.toString() ?? '',
      logoText: json['logo_text']?.toString() ?? '',
      logoColor: parsedColor,
      interestRate: json['interest_rate']?.toString() ?? '',
      interestRateValue: (json['interest_rate_value'] as num?)?.toDouble() ?? 8.5,
      maxAmount: json['max_amount']?.toString() ?? '',
      tenure: json['tenure']?.toString() ?? '',
      processingFee: json['processing_fee']?.toString() ?? '',
      processingFeeValue: (json['processing_fee_value'] as num?)?.toDouble() ?? 1.0,
      monthlyEmi: json['monthly_emi']?.toString() ?? '',
      matchPercent: (json['match_percent'] as num?)?.toInt() ?? 90,
      isTopPick: json['is_top_pick'] == true,
      keyFeatures: (json['key_features'] as List?)?.map((e) => e.toString()).toList() ?? [],
      reason: json['reason']?.toString(),
      pros: (json['pros'] as List?)?.map((e) => e.toString()).toList() ?? [],
      cons: (json['cons'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_name': bankName,
      'policy_subtitle': policySubtitle,
      'logo_text': logoText,
      'logo_color': '#${logoColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
      'interest_rate': interestRate,
      'interest_rate_value': interestRateValue,
      'max_amount': maxAmount,
      'tenure': tenure,
      'processing_fee': processingFee,
      'processing_fee_value': processingFeeValue,
      'monthly_emi': monthlyEmi,
      'match_percent': matchPercent,
      'is_top_pick': isTopPick,
      'key_features': keyFeatures,
      'reason': reason,
      'pros': pros,
      'cons': cons,
    };
  }
}

/// Model for a criterion in the "Why you're matched" section
class MatchCriterion {
  final String title;
  final String subtitle;
  final bool isSuccess;

  const MatchCriterion({
    required this.title,
    required this.subtitle,
    required this.isSuccess,
  });

  factory MatchCriterion.fromJson(Map<String, dynamic> json) {
    return MatchCriterion(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      isSuccess: json['is_success'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'is_success': isSuccess,
    };
  }
}

/// Model for the "Why you're matched" data block
class WhyMatchedData {
  final double profileStrength;
  final List<MatchCriterion> criteria;
  final String hintText;

  const WhyMatchedData({
    required this.profileStrength,
    required this.criteria,
    required this.hintText,
  });

  factory WhyMatchedData.fromJson(Map<String, dynamic> json) {
    return WhyMatchedData(
      profileStrength: (json['profile_strength'] as num?)?.toDouble() ?? 0.8,
      criteria: (json['criteria'] as List?)
              ?.map((e) => MatchCriterion.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      hintText: json['hint_text']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_strength': profileStrength,
      'criteria': criteria.map((e) => e.toJson()).toList(),
      'hint_text': hintText,
    };
  }
}

/// Model for Cost Breakdown
class CostBreakdownData {
  final String loanAmount;
  final String processingFee;
  final String totalInterest;
  final String monthlyEmi;
  final String totalPayable;

  const CostBreakdownData({
    required this.loanAmount,
    required this.processingFee,
    required this.totalInterest,
    required this.monthlyEmi,
    required this.totalPayable,
  });

  factory CostBreakdownData.fromJson(Map<String, dynamic> json) {
    return CostBreakdownData(
      loanAmount: json['loan_amount']?.toString() ?? '',
      processingFee: json['processing_fee']?.toString() ?? '',
      totalInterest: json['total_interest']?.toString() ?? '',
      monthlyEmi: json['monthly_emi']?.toString() ?? '',
      totalPayable: json['total_payable']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loan_amount': loanAmount,
      'processing_fee': processingFee,
      'total_interest': totalInterest,
      'monthly_emi': monthlyEmi,
      'total_payable': totalPayable,
    };
  }
}

/// Model for Top Summary Card
class LoanOffersSummaryData {
  final String loanType;
  final String amountAndTenure;
  final String cibilScore;

  const LoanOffersSummaryData({
    required this.loanType,
    required this.amountAndTenure,
    required this.cibilScore,
  });

  factory LoanOffersSummaryData.fromJson(Map<String, dynamic> json) {
    return LoanOffersSummaryData(
      loanType: json['loan_type']?.toString() ?? 'Home loan',
      amountAndTenure: json['amount_and_tenure']?.toString() ?? '₹4,50,000 · 15 yrs',
      cibilScore: json['cibil_score']?.toString() ?? 'CIBIL 762',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loan_type': loanType,
      'amount_and_tenure': amountAndTenure,
      'cibil_score': cibilScore,
    };
  }
}
