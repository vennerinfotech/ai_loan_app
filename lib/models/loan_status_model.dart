/// Model for GET {{base_url}}/loan/status
/// Designed without success, status_code, message, or errors wrapper
class LoanStatusModel {
  final LoanStatusUser? user;
  final LoanStatusVerification? verificationStatus;

  LoanStatusModel({
    this.user,
    this.verificationStatus,
  });

  factory LoanStatusModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        (json['data'] != null && json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;

    return LoanStatusModel(
      user: data['user'] != null && data['user'] is Map<String, dynamic>
          ? LoanStatusUser.fromJson(data['user'] as Map<String, dynamic>)
          : null,
      verificationStatus: data['verification_status'] != null &&
              data['verification_status'] is Map<String, dynamic>
          ? LoanStatusVerification.fromJson(
              data['verification_status'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (user != null) 'user': user!.toJson(),
        if (verificationStatus != null)
          'verification_status': verificationStatus!.toJson(),
      };
}

class LoanStatusUser {
  final int? id;
  final String? name;
  final String? phone;
  final int? currentStep;
  final num? loanAmount;

  LoanStatusUser({
    this.id,
    this.name,
    this.phone,
    this.currentStep,
    this.loanAmount,
  });

  factory LoanStatusUser.fromJson(Map<String, dynamic> json) {
    return LoanStatusUser(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      currentStep: json['current_step'] is int
          ? json['current_step']
          : int.tryParse(json['current_step']?.toString() ?? ''),
      loanAmount: json['loan_amount'] is num
          ? json['loan_amount']
          : num.tryParse(json['loan_amount']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (currentStep != null) 'current_step': currentStep,
        if (loanAmount != null) 'loan_amount': loanAmount,
      };
}

class LoanStatusVerification {
  final bool? aadhaarVerified;
  final bool? panVerified;
  final bool? businessProof;
  final bool? salariedProof;
  final Map<String, dynamic> rawStatus;

  LoanStatusVerification({
    this.aadhaarVerified,
    this.panVerified,
    this.businessProof,
    this.salariedProof,
    this.rawStatus = const {},
  });

  factory LoanStatusVerification.fromJson(Map<String, dynamic> json) {
    return LoanStatusVerification(
      aadhaarVerified: json['aadhaar_verified'] as bool?,
      panVerified: json['pan_verified'] as bool?,
      businessProof: json['business_proof'] as bool?,
      salariedProof: json['salaried_proof'] as bool?,
      rawStatus: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        ...rawStatus,
        if (aadhaarVerified != null) 'aadhaar_verified': aadhaarVerified,
        if (panVerified != null) 'pan_verified': panVerified,
        if (businessProof != null) 'business_proof': businessProof,
        if (salariedProof != null) 'salaried_proof': salariedProof,
      };
}
