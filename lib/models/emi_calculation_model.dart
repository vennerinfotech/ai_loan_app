/// Model for POST {{baseUrl}}/emi-calculate response
class EmiCalculationResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final EmiCalculationData? data;

  EmiCalculationResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory EmiCalculationResponseModel.fromJson(Map<String, dynamic> json) {
    return EmiCalculationResponseModel(
      success: json['success'] as bool?,
      statusCode: json['status_code'] as int?,
      message: json['message'] as String?,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? EmiCalculationData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class EmiCalculationData {
  final num? loanAmount;
  final num? interestRate;
  final int? tenureMonths;
  final num? monthlyEmi;
  final num? totalInterest;
  final num? totalPayable;
  final num? principalPercent;
  final num? interestPercent;

  EmiCalculationData({
    this.loanAmount,
    this.interestRate,
    this.tenureMonths,
    this.monthlyEmi,
    this.totalInterest,
    this.totalPayable,
    this.principalPercent,
    this.interestPercent,
  });

  factory EmiCalculationData.fromJson(Map<String, dynamic> json) {
    return EmiCalculationData(
      loanAmount: json['loan_amount'] as num?,
      interestRate: json['interest_rate'] as num?,
      tenureMonths: json['tenure_months'] is int
          ? json['tenure_months'] as int
          : int.tryParse(json['tenure_months']?.toString() ?? ''),
      monthlyEmi: json['monthly_emi'] as num?,
      totalInterest: json['total_interest'] as num?,
      totalPayable: json['total_payable'] as num?,
      principalPercent: json['principal_percent'] as num?,
      interestPercent: json['interest_percent'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loan_amount': loanAmount,
      'interest_rate': interestRate,
      'tenure_months': tenureMonths,
      'monthly_emi': monthlyEmi,
      'total_interest': totalInterest,
      'total_payable': totalPayable,
      'principal_percent': principalPercent,
      'interest_percent': interestPercent,
    };
  }
}
