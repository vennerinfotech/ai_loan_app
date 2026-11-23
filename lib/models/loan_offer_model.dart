import 'package:material_ui/material_ui.dart';

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
  });

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
