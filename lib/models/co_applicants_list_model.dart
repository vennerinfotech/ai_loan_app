// Model for GET {{baseUrl}}/co-applicants response

import 'add_co_applicant_model.dart' show CoAppDocumentAccess;

class CoApplicantsListResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final CoApplicantsListData? data;
  final dynamic errors;

  CoApplicantsListResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
    this.errors,
  });

  factory CoApplicantsListResponseModel.fromJson(Map<String, dynamic> json) {
    return CoApplicantsListResponseModel(
      success: json['success'] as bool?,
      statusCode: json['status_code'] is int
          ? json['status_code']
          : int.tryParse(json['status_code']?.toString() ?? ''),
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? CoApplicantsListData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'],
    );
  }
}

class CoApplicantsListData {
  final List<CoApplicantItem> coApplicants;

  CoApplicantsListData({
    this.coApplicants = const [],
  });

  factory CoApplicantsListData.fromJson(Map<String, dynamic> json) {
    return CoApplicantsListData(
      coApplicants: (json['co_applicants'] as List?)
              ?.map((item) => CoApplicantItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
    );
  }
}

class CoApplicantItem {
  final int? id;
  final dynamic userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? panCardNumber;
  final String? aadhaarCardNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? relationship;
  final String? profileImage;
  final String? createdAt;
  final String? updatedAt;
  final String? aadhaarCardImage;
  final String? panCardImage;
  final String? employmentType;
  final dynamic documents;
  final String? applicantType;
  final String? maritalStatus;
  final String? religion;
  final String? fatherName;
  final String? motherName;
  final String? currentResidenceType;
  final String? permanentAddress;
  final String? communicationAddress;
  final String? companyName;
  final String? sector;
  final String? companyType;
  final dynamic monthlySalary;
  final String? designation;
  final dynamic workExperience;
  final dynamic currentExperience;
  final String? incomeType;
  final dynamic bankSalaryAmount;
  final dynamic cashSalaryAmount;
  final String? companyAddress;
  final String? businessName;
  final String? businessEntity;
  final String? natureOfBusiness;
  final dynamic businessEstablishedYear;
  final dynamic yearsInCurrentBusiness;
  final String? businessVintage;
  final String? businessTurnover;
  final String? officeType;
  final String? itr;
  final String? businessAddress;
  final dynamic cibilScore;
  final String? cibilIssue;
  final dynamic obligations;
  final String? profileImageUrl;
  final List<dynamic>? aadhaarCardImageUrls;
  final String? panCardImageUrl;
  final dynamic documentUrls;
  final CoAppDocumentAccess? documentAccess;

  CoApplicantItem({
    this.id,
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.panCardNumber,
    this.aadhaarCardNumber,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.relationship,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
    this.aadhaarCardImage,
    this.panCardImage,
    this.employmentType,
    this.documents,
    this.applicantType,
    this.maritalStatus,
    this.religion,
    this.fatherName,
    this.motherName,
    this.currentResidenceType,
    this.permanentAddress,
    this.communicationAddress,
    this.companyName,
    this.sector,
    this.companyType,
    this.monthlySalary,
    this.designation,
    this.workExperience,
    this.currentExperience,
    this.incomeType,
    this.bankSalaryAmount,
    this.cashSalaryAmount,
    this.companyAddress,
    this.businessName,
    this.businessEntity,
    this.natureOfBusiness,
    this.businessEstablishedYear,
    this.yearsInCurrentBusiness,
    this.businessVintage,
    this.businessTurnover,
    this.officeType,
    this.itr,
    this.businessAddress,
    this.cibilScore,
    this.cibilIssue,
    this.obligations,
    this.profileImageUrl,
    this.aadhaarCardImageUrls,
    this.panCardImageUrl,
    this.documentUrls,
    this.documentAccess,
  });

  factory CoApplicantItem.fromJson(Map<String, dynamic> json) {
    return CoApplicantItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['user_id'],
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      panCardNumber: json['pan_card_number']?.toString(),
      aadhaarCardNumber: json['aadhaar_card_number']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      relationship: json['relationship']?.toString(),
      profileImage: json['profile_image']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      aadhaarCardImage: json['aadhaar_card_image']?.toString(),
      panCardImage: json['pan_card_image']?.toString(),
      employmentType: json['employment_type']?.toString(),
      documents: json['documents'],
      applicantType: json['applicant_type']?.toString(),
      maritalStatus: json['marital_status']?.toString(),
      religion: json['religion']?.toString(),
      fatherName: json['father_name']?.toString(),
      motherName: json['mother_name']?.toString(),
      currentResidenceType: json['current_residence_type']?.toString(),
      permanentAddress: json['permanent_address']?.toString(),
      communicationAddress: json['communication_address']?.toString(),
      companyName: json['company_name']?.toString(),
      sector: json['sector']?.toString(),
      companyType: json['company_type']?.toString(),
      monthlySalary: json['monthly_salary'],
      designation: json['designation']?.toString(),
      workExperience: json['work_experience'],
      currentExperience: json['current_experience'],
      incomeType: json['income_type']?.toString(),
      bankSalaryAmount: json['bank_salary_amount'],
      cashSalaryAmount: json['cash_salary_amount'],
      companyAddress: json['company_address']?.toString(),
      businessName: json['business_name']?.toString(),
      businessEntity: json['business_entity']?.toString(),
      natureOfBusiness: json['nature_of_business']?.toString(),
      businessEstablishedYear: json['business_established_year'],
      yearsInCurrentBusiness: json['years_in_current_business'],
      businessVintage: json['business_vintage']?.toString(),
      businessTurnover: json['business_turnover']?.toString(),
      officeType: json['office_type']?.toString(),
      itr: json['itr']?.toString(),
      businessAddress: json['business_address']?.toString(),
      cibilScore: json['cibil_score'],
      cibilIssue: json['cibil_issue']?.toString(),
      obligations: json['obligations'],
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
