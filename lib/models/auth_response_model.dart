/// Unified Common Model for all Authentication APIs:
/// - Register
/// - Verify OTP
/// - Resend OTP
/// - Set MPIN
/// - Login with Mobile
/// - Login with MPIN
class AuthResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final AuthData? data;
  final dynamic errors;

  AuthResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.errors,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] == true,
      statusCode: json['status_code'] is int
          ? json['status_code']
          : int.tryParse(json['status_code']?.toString() ?? '') ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AuthData.fromJson(json['data'] as Map<String, dynamic>)
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

class AuthData {
  final int? userId;
  final AuthUser? user;
  final String? phone;
  final dynamic otp;
  final String? otpExpiresAt;
  final String? token;
  final String? tokenType;
  final String? csrfToken;

  AuthData({
    this.userId,
    this.user,
    this.phone,
    this.otp,
    this.otpExpiresAt,
    this.token,
    this.tokenType,
    this.csrfToken,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? AuthUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      phone: json['phone']?.toString(),
      otp: json['otp'],
      // Supports both 'otp_expires_at' and 'expires_at'
      otpExpiresAt: (json['otp_expires_at'] ?? json['expires_at'])?.toString(),
      token: json['token']?.toString(),
      tokenType: json['token_type']?.toString(),
      csrfToken: json['csrf_token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user': user?.toJson(),
      'phone': phone,
      'otp': otp,
      'otp_expires_at': otpExpiresAt,
      'token': token,
      'token_type': tokenType,
      'csrf_token': csrfToken,
    };
  }
}

class AuthUser {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? role;
  final int? currentStep;
  final bool? mpinSet;

  AuthUser({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.role,
    this.currentStep,
    this.mpinSet,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      currentStep: json['current_step'] is int
          ? json['current_step']
          : int.tryParse(json['current_step']?.toString() ?? ''),
      mpinSet: json['mpin_set'] != null
          ? (json['mpin_set'] == true || json['mpin_set'] == 1)
          : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'current_step': currentStep,
      'mpin_set': mpinSet,
    };
  }
}
