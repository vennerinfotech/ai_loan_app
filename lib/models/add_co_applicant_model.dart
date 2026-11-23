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
  final List<dynamic> documents;
  final Map<String, dynamic>? summary;
  final Map<String, dynamic>? upload;

  AddCoApplicantData({
    this.coApplicantId,
    this.coApplicant,
    this.title,
    this.employmentType,
    this.applicantType,
    this.documents = const [],
    this.summary,
    this.upload,
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
      documents: (json['documents'] as List<dynamic>?) ?? [],
      summary: json['summary'] as Map<String, dynamic>?,
      upload: json['upload'] as Map<String, dynamic>?,
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
    );
  }
}
