/// Model class for Register API response
class RegisterResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final RegisterData? data;
  final dynamic errors;

  RegisterResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.errors,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] == true,
      statusCode: json['status_code'] is int ? json['status_code'] : 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? RegisterData.fromJson(json['data'] as Map<String, dynamic>)
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

class RegisterData {
  final int? userId;
  final RegisterUser? user;
  final String? phone;
  final dynamic otp;
  final String? otpExpiresAt;
  final String? csrfToken;

  RegisterData({
    this.userId,
    this.user,
    this.phone,
    this.otp,
    this.otpExpiresAt,
    this.csrfToken,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id']?.toString() ?? ''),
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? RegisterUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      phone: json['phone']?.toString(),
      otp: json['otp'],
      otpExpiresAt: json['otp_expires_at']?.toString(),
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
      'csrf_token': csrfToken,
    };
  }
}

class RegisterUser {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;

  RegisterUser({
    this.id,
    this.name,
    this.phone,
    this.email,
  });

  factory RegisterUser.fromJson(Map<String, dynamic> json) {
    return RegisterUser(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }
}
