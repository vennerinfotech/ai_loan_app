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
    num? parseNum(dynamic val) {
      if (val == null) return null;
      if (val is num) return val;
      return num.tryParse(val.toString());
    }

    return EmiCalculationData(
      loanAmount: parseNum(json['loan_amount']),
      interestRate: parseNum(json['interest_rate']),
      tenureMonths: json['tenure_months'] is int
          ? json['tenure_months'] as int
          : int.tryParse(json['tenure_months']?.toString() ?? ''),
      monthlyEmi: parseNum(json['monthly_emi']),
      totalInterest: parseNum(json['total_interest']),
      totalPayable: parseNum(json['total_payable']),
      principalPercent: parseNum(json['principal_percent']),
      interestPercent: parseNum(json['interest_percent']),
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
