/// Model class for Verify OTP API response
class VerifyOtpResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final VerifyOtpData? data;
  final dynamic errors;

  VerifyOtpResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.errors,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      success: json['success'] == true,
      statusCode: json['status_code'] is int ? json['status_code'] : 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? VerifyOtpData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'message': message,
      'data': data?.toJson(),
      'errors': errors,
    };
  }
}

class VerifyOtpData {
  final String? token;
  final String? tokenType;
  final VerifyOtpUser? user;

  VerifyOtpData({
    this.token,
    this.tokenType,
    this.user,
  });

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyOtpData(
      token: json['token']?.toString(),
      tokenType: json['token_type']?.toString(),
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? VerifyOtpUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'token_type': tokenType,
      'user': user?.toJson(),
    };
  }
}

class VerifyOtpUser {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final int? currentStep;
  final bool? mpinSet;

  VerifyOtpUser({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.currentStep,
    this.mpinSet,
  });

  factory VerifyOtpUser.fromJson(Map<String, dynamic> json) {
    return VerifyOtpUser(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      currentStep: json['current_step'] is int ? json['current_step'] : 0,
      mpinSet: json['mpin_set'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'current_step': currentStep,
      'mpin_set': mpinSet,
    };
  }
}
