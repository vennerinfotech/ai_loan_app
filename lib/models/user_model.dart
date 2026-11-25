/// Model representing the user entity returned from Finsphere AI APIs.
class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? maritalStatus;
  final String? address;
  final String? addressType;
  final String? photoUrl;
  final String? role;
  final int? currentStep;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.dob,
    this.gender,
    this.maritalStatus,
    this.address,
    this.addressType,
    this.photoUrl,
    this.role,
    this.currentStep,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      dob: (json['dob'] ?? json['date_of_birth'])?.toString(),
      gender: json['gender']?.toString(),
      maritalStatus:
          (json['marital_status'] ?? json['maritalStatus'])?.toString(),
      address: (json['address'] ??
              json['communication_address'] ??
              json['permanent_address'])
          ?.toString(),
      addressType:
          (json['address_type'] ?? json['addressType'])?.toString(),
      photoUrl: (json['photo_url'] ??
              json['profile_photo_url'] ??
              json['profile_photo'] ??
              json['photoUrl'] ??
              json['avatar'])
          ?.toString(),
      role: (json['role'] ?? json['employment_type'])?.toString(),
      currentStep: json['current_step'] is int
          ? json['current_step']
          : int.tryParse(json['current_step']?.toString() ?? ''),
    );
  }

  /// First name extracted from [name]
  String get firstName {
    final parts = (name ?? '').trim().split(' ').where((p) => p.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.first : '';
  }

  /// Last name extracted from [name]
  String get lastName {
    final parts = (name ?? '').trim().split(' ').where((p) => p.isNotEmpty).toList();
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  /// Initials computed from [name]
  String get initials {
    final parts = (name ?? '').trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '';
  }

  /// Formatted masked phone e.g. "+91 98765 •••10"
  String get maskedPhone {
    final raw = (phone ?? '').trim();
    if (raw.isEmpty) return '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      final last2 = digits.substring(digits.length - 2);
      final first5 = digits.substring(digits.length - 10, digits.length - 5);
      return '+91 $first5 •••$last2';
    }
    return raw;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (dob != null) 'dob': dob,
      if (gender != null) 'gender': gender,
      if (maritalStatus != null) 'marital_status': maritalStatus,
      if (address != null) 'address': address,
      if (addressType != null) 'address_type': addressType,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (role != null) 'role': role,
      if (currentStep != null) 'current_step': currentStep,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? dob,
    String? gender,
    String? maritalStatus,
    String? address,
    String? addressType,
    String? photoUrl,
    String? role,
    int? currentStep,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      address: address ?? this.address,
      addressType: addressType ?? this.addressType,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

/// Response model for {{base_url}}/update-personal-info API
class UpdatePersonalInfoResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final UserModel? user;
  final dynamic errors;

  UpdatePersonalInfoResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.user,
    this.errors,
  });

  factory UpdatePersonalInfoResponseModel.fromJson(Map<String, dynamic> json) {
    UserModel? user;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      final data = json['data'] as Map<String, dynamic>;
      if (data['user'] != null && data['user'] is Map<String, dynamic>) {
        user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        user = UserModel.fromJson(data);
      }
    }

    return UpdatePersonalInfoResponseModel(
      success: json['success'] == true,
      statusCode: json['status_code'] is int
          ? json['status_code']
          : int.tryParse(json['status_code']?.toString() ?? '') ?? 0,
      message: json['message']?.toString() ?? '',
      user: user,
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'message': message,
      if (user != null) 'data': {'user': user!.toJson()},
      'errors': errors,
    };
  }
}

/// Response model for {{base_url}}/update-profile-photo API
class UpdateProfilePhotoResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final String? photoUrl;
  final dynamic errors;

  UpdateProfilePhotoResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.photoUrl,
    this.errors,
  });

  factory UpdateProfilePhotoResponseModel.fromJson(Map<String, dynamic> json) {
    String? photoUrl;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      final data = json['data'] as Map<String, dynamic>;
      photoUrl = data['photo_url']?.toString();
    }

    return UpdateProfilePhotoResponseModel(
      success: json['success'] == true,
      statusCode: json['status_code'] is int
          ? json['status_code']
          : int.tryParse(json['status_code']?.toString() ?? '') ?? 0,
      message: json['message']?.toString() ?? '',
      photoUrl: photoUrl,
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'message': message,
      if (photoUrl != null) 'data': {'photo_url': photoUrl},
      'errors': errors,
    };
  }
}
