/// Unified model for Aadhaar KYC flow responses
/// Handles data from:
/// - POST /store-aadhaar
/// - POST /resend-aadhaar-otp
/// - POST /verify-aadhaar-otp
/// - POST /upload-aadhaar
/// - GET  /download-verification-receipt
class AadhaarKycModel {
  int? documentId;
  int? userId;
  String? expiresAt;
  dynamic otp;
  String? filename;
  AadhaarUser? user;

  AadhaarKycModel({
    this.documentId,
    this.userId,
    this.expiresAt,
    this.otp,
    this.filename,
    this.user,
  });

  factory AadhaarKycModel.fromJson(Map<String, dynamic> json) {
    return AadhaarKycModel(
      documentId: json['document_id'] is int
          ? json['document_id']
          : int.tryParse(json['document_id']?.toString() ?? ''),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      expiresAt: json['expires_at']?.toString(),
      otp: json['otp'],
      filename: json['filename']?.toString(),
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? AadhaarUser.fromJson(Map<String, dynamic>.from(json['user']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (documentId != null) 'document_id': documentId,
      if (userId != null) 'user_id': userId,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (otp != null) 'otp': otp,
      if (filename != null) 'filename': filename,
      if (user != null) 'user': user?.toJson(),
    };
  }
}

/// User details returned in Aadhaar KYC verification receipt
class AadhaarUser {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? dob;
  final String? gender;
  final String? address;

  AadhaarUser({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.dob,
    this.gender,
    this.address,
  });

  factory AadhaarUser.fromJson(Map<String, dynamic> json) {
    return AadhaarUser(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      phone: json['phone']?.toString() ??
          json['mobile']?.toString() ??
          json['linked_mobile']?.toString(),
      email: json['email']?.toString(),
      dob: json['dob']?.toString() ?? json['date_of_birth']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'dob': dob,
      'gender': gender,
      'address': address,
    };
  }
}
