// Model for POST /co-applicants response

class AddCoApplicantResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final AddCoApplicantData? data;
  final dynamic errors;

  AddCoApplicantResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
    this.errors,
  });

  factory AddCoApplicantResponseModel.fromJson(Map<String, dynamic> json) {
    return AddCoApplicantResponseModel(
      success: json['success'] as bool?,
      statusCode: json['status_code'] is int
          ? json['status_code']
          : int.tryParse(json['status_code']?.toString() ?? ''),
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AddCoApplicantData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'],
    );
  }
}

class AddCoApplicantData {
  final int? coApplicantId;
  final CoApplicantRecord? coApplicant;
  final String? title;
  final String? employmentType;
  final String? applicantType;
  final List<CoAppDocumentItem> documents;
  final CoAppDocumentAccess? documentAccess;
  final Map<String, dynamic>? summary;
  final Map<String, dynamic>? upload;
  final dynamic otp;
  final String? otpExpiresAt;

  AddCoApplicantData({
    this.coApplicantId,
    this.coApplicant,
    this.title,
    this.employmentType,
    this.applicantType,
    this.documents = const [],
    this.documentAccess,
    this.summary,
    this.upload,
    this.otp,
    this.otpExpiresAt,
  });

  factory AddCoApplicantData.fromJson(Map<String, dynamic> json) {
    return AddCoApplicantData(
      coApplicantId: json['co_applicant_id'] is int
          ? json['co_applicant_id']
          : int.tryParse(json['co_applicant_id']?.toString() ?? ''),
      coApplicant: json['co_applicant'] != null && json['co_applicant'] is Map<String, dynamic>
          ? CoApplicantRecord.fromJson(json['co_applicant'] as Map<String, dynamic>)
          : null,
      title: json['title']?.toString(),
      employmentType: json['employment_type']?.toString(),
      applicantType: json['applicant_type']?.toString(),
      documents: (json['documents'] as List?)
              ?.map((item) => CoAppDocumentItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      documentAccess: json['document_access'] != null && json['document_access'] is Map<String, dynamic>
          ? CoAppDocumentAccess.fromJson(json['document_access'] as Map<String, dynamic>)
          : null,
      summary: json['summary'] as Map<String, dynamic>?,
      upload: json['upload'] as Map<String, dynamic>?,
      otp: json['otp'],
      otpExpiresAt: json['otp_expires_at']?.toString(),
    );
  }
}

class CoApplicantRecord {
  final int? id;
  final String? name;
  final String? phone;
  final String? relationship;
  final dynamic userId;
  final String? applicantType;
  final String? employmentType;
  final String? createdAt;
  final String? updatedAt;
  final String? profileImageUrl;
  final List<dynamic>? aadhaarCardImageUrls;
  final String? panCardImageUrl;
  final dynamic documentUrls;
  final CoAppDocumentAccess? documentAccess;

  CoApplicantRecord({
    this.id,
    this.name,
    this.phone,
    this.relationship,
    this.userId,
    this.applicantType,
    this.employmentType,
    this.createdAt,
    this.updatedAt,
    this.profileImageUrl,
    this.aadhaarCardImageUrls,
    this.panCardImageUrl,
    this.documentUrls,
    this.documentAccess,
  });

  factory CoApplicantRecord.fromJson(Map<String, dynamic> json) {
    return CoApplicantRecord(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      relationship: json['relationship']?.toString(),
      userId: json['user_id'],
      applicantType: json['applicant_type']?.toString(),
      employmentType: json['employment_type']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      profileImageUrl: json['profile_image_url']?.toString(),
      aadhaarCardImageUrls: json['aadhaar_card_image_urls'] as List<dynamic>?,
      panCardImageUrl: json['pan_card_image_url']?.toString(),
      documentUrls: json['document_urls'],
      documentAccess: json['document_access'] != null && json['document_access'] is Map<String, dynamic>
          ? CoAppDocumentAccess.fromJson(json['document_access'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Dynamic document item directly parsed from the API response
class CoAppDocumentItem {
  final String? key;
  final String? label;
  final bool? allowMultiple;
  final List<String> acceptedFormats;
  final int? maxSizeMb;
  final String? uploadField;
  final bool? ocrAutofill;
  final bool? uploaded;
  final String? status;
  final List<dynamic> files;
  final List<CoAppUploadMode>? uploadModes;

  CoAppDocumentItem({
    this.key,
    this.label,
    this.allowMultiple,
    this.acceptedFormats = const [],
    this.maxSizeMb,
    this.uploadField,
    this.ocrAutofill,
    this.uploaded,
    this.status,
    this.files = const [],
    this.uploadModes,
  });

  factory CoAppDocumentItem.fromJson(Map<String, dynamic> json) {
    return CoAppDocumentItem(
      key: json['key']?.toString(),
      label: json['label']?.toString(),
      allowMultiple: json['allow_multiple'] as bool?,
      acceptedFormats: (json['accepted_formats'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      maxSizeMb: json['max_size_mb'] is int
          ? json['max_size_mb']
          : int.tryParse(json['max_size_mb']?.toString() ?? ''),
      uploadField: json['upload_field']?.toString(),
      ocrAutofill: json['ocr_autofill'] as bool?,
      uploaded: json['uploaded'] as bool?,
      status: json['status']?.toString(),
      files: (json['files'] as List?) ?? [],
      uploadModes: (json['upload_modes'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => CoAppUploadMode.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (key != null) 'key': key,
      if (label != null) 'label': label,
      if (allowMultiple != null) 'allow_multiple': allowMultiple,
      if (acceptedFormats.isNotEmpty) 'accepted_formats': acceptedFormats,
      if (maxSizeMb != null) 'max_size_mb': maxSizeMb,
      if (uploadField != null) 'upload_field': uploadField,
      if (ocrAutofill != null) 'ocr_autofill': ocrAutofill,
      if (uploaded != null) 'uploaded': uploaded,
      if (status != null) 'status': status,
      'files': files,
      if (uploadModes != null)
        'upload_modes': uploadModes!.map((e) => e.toJson()).toList(),
    };
  }
}

/// Upload mode option for a document (e.g. separate front/back or single combined PDF)
class CoAppUploadMode {
  final String? key;
  final String? label;
  final List<String> fields;
  final List<String> acceptedFormats;

  CoAppUploadMode({
    this.key,
    this.label,
    this.fields = const [],
    this.acceptedFormats = const [],
  });

  factory CoAppUploadMode.fromJson(Map<String, dynamic> json) {
    return CoAppUploadMode(
      key: json['key']?.toString(),
      label: json['label']?.toString(),
      fields: (json['fields'] as List?)?.map((e) => e.toString()).toList() ?? [],
      acceptedFormats: (json['accepted_formats'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (key != null) 'key': key,
      if (label != null) 'label': label,
      'fields': fields,
      'accepted_formats': acceptedFormats,
    };
  }
}

/// Document access / OTP verification status for co-applicant
class CoAppDocumentAccess {
  final bool? required;
  final bool? verified;
  final String? verifiedAt;
  final String? sendOtpEndpoint;
  final String? verifyOtpEndpoint;

  CoAppDocumentAccess({
    this.required,
    this.verified,
    this.verifiedAt,
    this.sendOtpEndpoint,
    this.verifyOtpEndpoint,
  });

  factory CoAppDocumentAccess.fromJson(Map<String, dynamic> json) {
    return CoAppDocumentAccess(
      required: json['required'] as bool?,
      verified: json['verified'] as bool?,
      verifiedAt: json['verified_at']?.toString(),
      sendOtpEndpoint: json['send_otp_endpoint']?.toString(),
      verifyOtpEndpoint: json['verify_otp_endpoint']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (required != null) 'required': required,
      if (verified != null) 'verified': verified,
      if (verifiedAt != null) 'verified_at': verifiedAt,
      if (sendOtpEndpoint != null) 'send_otp_endpoint': sendOtpEndpoint,
      if (verifyOtpEndpoint != null) 'verify_otp_endpoint': verifyOtpEndpoint,
    };
  }
}
