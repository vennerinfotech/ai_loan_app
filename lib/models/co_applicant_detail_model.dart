// Co-Applicant Details API Data Model
// Endpoint: GET {{baseUrl}}/co-applicants/{co_applicant_id}
// Model for applicant data only (without success, status_code, message wrapper)

import 'add_co_applicant_model.dart' show CoAppDocumentAccess;

class CoApplicantDetailData {
  final int? coApplicantId;
  final CoApplicantDetailProfile? coApplicant;
  final String? title;
  final String? employmentType;
  final String? applicantType;
  final List<CoApplicantDocumentConfig> documents;
  final CoAppDocumentAccess? documentAccess;
  final CoApplicantSummary? summary;
  final CoApplicantUploadConfig? upload;

  CoApplicantDetailData({
    this.coApplicantId,
    this.coApplicant,
    this.title,
    this.employmentType,
    this.applicantType,
    this.documents = const [],
    this.documentAccess,
    this.summary,
    this.upload,
  });

  factory CoApplicantDetailData.fromJson(Map<String, dynamic> json) {
    final profile = json['co_applicant'] != null && json['co_applicant'] is Map<String, dynamic>
        ? CoApplicantDetailProfile.fromJson(json['co_applicant'] as Map<String, dynamic>)
        : null;

    final docUrlsMap = profile?.documentUrls ??
        (json['co_applicant'] is Map<String, dynamic>
            ? json['co_applicant']['document_urls'] as Map<String, dynamic>?
            : null);

    List<CoApplicantDocumentConfig> parsedDocs = (json['documents'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => CoApplicantDocumentConfig.fromJson(e))
            .toList() ??
        [];

    // In GET /co-applicants/{id}, the backend provides uploaded documents in co_applicant.documents
    if (parsedDocs.isEmpty && profile?.documents != null && profile!.documents!.isNotEmpty) {
      parsedDocs = _parseDocumentsFromProfileMap(profile.documents!, docUrlsMap: docUrlsMap);
    }

    return CoApplicantDetailData(
      coApplicantId: json['co_applicant_id'] is int
          ? json['co_applicant_id']
          : int.tryParse(json['co_applicant_id']?.toString() ?? ''),
      coApplicant: profile,
      title: json['title']?.toString(),
      employmentType: json['employment_type']?.toString(),
      applicantType: json['applicant_type']?.toString(),
      documents: parsedDocs,
      documentAccess: json['document_access'] != null && json['document_access'] is Map<String, dynamic>
          ? CoAppDocumentAccess.fromJson(json['document_access'] as Map<String, dynamic>)
          : null,
      summary: json['summary'] != null && json['summary'] is Map<String, dynamic>
          ? CoApplicantSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      upload: json['upload'] != null && json['upload'] is Map<String, dynamic>
          ? CoApplicantUploadConfig.fromJson(json['upload'] as Map<String, dynamic>)
          : null,
    );
  }

  static List<CoApplicantDocumentConfig> _parseDocumentsFromProfileMap(
    Map<String, dynamic> docsMap, {
    Map<String, dynamic>? docUrlsMap,
  }) {
    final List<CoApplicantDocumentConfig> result = [];
    for (final entry in docsMap.entries) {
      final key = entry.key;
      final val = entry.value;
      if (val == null) continue;

      final urlVal = docUrlsMap != null ? docUrlsMap[key] : null;

      final List<CoApplicantDocFileItem> files = [];
      if (val is String && val.trim().isNotEmpty) {
        String? itemUrl;
        if (urlVal is String && urlVal.isNotEmpty) {
          itemUrl = urlVal;
        } else if (urlVal is List && urlVal.isNotEmpty) {
          itemUrl = urlVal.first?.toString();
        }
        files.add(
          CoApplicantDocFileItem(
            docKey: key,
            index: 0,
            name: val.split('/').last,
            url: itemUrl,
          ),
        );
      } else if (val is List) {
        for (int i = 0; i < val.length; i++) {
          final item = val[i];
          String? itemUrl;
          if (urlVal is List && i < urlVal.length) {
            itemUrl = urlVal[i]?.toString();
          } else if (urlVal is String && i == 0) {
            itemUrl = urlVal;
          }
          if (item is Map) {
            final filePath = item['file']?.toString() ?? '';
            final itemName = item['name']?.toString();
            files.add(
              CoApplicantDocFileItem(
                docKey: key,
                index: i,
                name: (itemName != null && itemName.isNotEmpty)
                    ? itemName
                    : filePath.split('/').last,
                status: item['status']?.toString(),
                url: itemUrl ?? item['url']?.toString(),
              ),
            );
          } else if (item is String && item.trim().isNotEmpty) {
            files.add(
              CoApplicantDocFileItem(
                docKey: key,
                index: i,
                name: item.split('/').last,
                url: itemUrl,
              ),
            );
          }
        }
      }

      if (files.isNotEmpty) {
        result.add(
          CoApplicantDocumentConfig(
            key: key,
            label: _formatDocKey(key),
            allowMultiple: val is List,
            uploaded: true,
            status: files.first.status ?? 'uploaded',
            files: files,
          ),
        );
      }
    }
    return result;
  }

  static String _formatDocKey(String key) {
    if (key == 'aadhar_card_front') return 'Aadhaar Card (Front)';
    if (key == 'aadhar_card_back') return 'Aadhaar Card (Back)';
    if (key == 'aadhar_card_combined_pdf') return 'Aadhaar Card (Single PDF)';
    if (key == 'aadhar_card' || key == 'aadhaar_card') return 'Aadhaar Card';
    if (key == 'pan_card_image' || key == 'pan_card') return 'PAN Card';
    if (key == 'profile_image') return 'Co-Applicant Photo';
    if (key == 'latest_salary_slips') return 'Salary Slip';
    if (key == 'bank_statement') return 'Bank Statement';
    if (key == 'form_16_itr') return 'Form 16 / ITR';
    if (key == 'salary_letterpad') return 'Company Letterpad';
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Map<String, dynamic> toJson() {
    return {
      if (coApplicantId != null) 'co_applicant_id': coApplicantId,
      if (coApplicant != null) 'co_applicant': coApplicant!.toJson(),
      if (title != null) 'title': title,
      if (employmentType != null) 'employment_type': employmentType,
      if (applicantType != null) 'applicant_type': applicantType,
      'documents': documents.map((e) => e.toJson()).toList(),
      if (documentAccess != null) 'document_access': documentAccess!.toJson(),
      if (summary != null) 'summary': summary!.toJson(),
      if (upload != null) 'upload': upload!.toJson(),
    };
  }
}

class CoApplicantDetailProfile {
  final int? id;
  final dynamic userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? panCardNumber;
  final String? panCardImage;
  final String? aadhaarCardNumber;
  final String? aadhaarCardImage;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? religion;
  final String? fatherName;
  final String? motherName;
  final String? currentResidenceType;
  final String? permanentAddress;
  final String? communicationAddress;
  final String? address;
  final String? relationship;
  final String? applicantType;
  final String? employmentType;
  final String? companyName;
  final String? sector;
  final String? companyType;
  final String? monthlySalary;
  final String? designation;
  final String? workExperience;
  final String? currentExperience;
  final String? incomeType;
  final String? bankSalaryAmount;
  final String? cashSalaryAmount;
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
  final int? cibilScore;
  final String? cibilIssue;
  final List<CoApplicantObligation> obligations;
  final String? propertyType;
  final String? constructionStage;
  final dynamic propertyValue;
  final dynamic areaSqft;
  final String? areaUnit;
  final dynamic agreementValue;
  final String? propertyLocation;
  final String? propertyShare;
  final Map<String, dynamic>? documents;
  final String? profileImage;
  final String? createdAt;
  final String? updatedAt;
  final String? netMonthlyIncome;
  final String? grossMonthlyIncome;
  final String? annualIncome;
  final String? otherIncome;
  final String? rentalIncome;
  final dynamic itrFiledYrs;
  final String? bankAccountType;
  final String? salaryMode;
  final dynamic avgBankBalance;
  final Map<String, dynamic>? documentUrls;
  final String? panCardImageUrl;
  final List<dynamic>? aadhaarCardImageUrls;
  final String? profileImageUrl;
  final CoAppDocumentAccess? documentAccess;

  CoApplicantDetailProfile({
    this.id,
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.panCardNumber,
    this.panCardImage,
    this.aadhaarCardNumber,
    this.aadhaarCardImage,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    this.religion,
    this.fatherName,
    this.motherName,
    this.currentResidenceType,
    this.permanentAddress,
    this.communicationAddress,
    this.address,
    this.relationship,
    this.applicantType,
    this.employmentType,
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
    this.obligations = const [],
    this.propertyType,
    this.constructionStage,
    this.propertyValue,
    this.areaSqft,
    this.areaUnit,
    this.agreementValue,
    this.propertyLocation,
    this.propertyShare,
    this.documents,
    this.profileImage,
    this.createdAt,
    this.updatedAt,
    this.netMonthlyIncome,
    this.grossMonthlyIncome,
    this.annualIncome,
    this.otherIncome,
    this.rentalIncome,
    this.itrFiledYrs,
    this.bankAccountType,
    this.salaryMode,
    this.avgBankBalance,
    this.documentUrls,
    this.panCardImageUrl,
    this.aadhaarCardImageUrls,
    this.profileImageUrl,
    this.documentAccess,
  });

  factory CoApplicantDetailProfile.fromJson(Map<String, dynamic> json) {
    return CoApplicantDetailProfile(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['user_id'],
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      panCardNumber: json['pan_card_number']?.toString(),
      panCardImage: json['pan_card_image']?.toString(),
      aadhaarCardNumber: json['aadhaar_card_number']?.toString(),
      aadhaarCardImage: json['aadhaar_card_image']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      gender: json['gender']?.toString(),
      maritalStatus: json['marital_status']?.toString(),
      religion: json['religion']?.toString(),
      fatherName: json['father_name']?.toString(),
      motherName: json['mother_name']?.toString(),
      currentResidenceType: json['current_residence_type']?.toString(),
      permanentAddress: json['permanent_address']?.toString(),
      communicationAddress: json['communication_address']?.toString(),
      address: json['address']?.toString(),
      relationship: json['relationship']?.toString(),
      applicantType: json['applicant_type']?.toString(),
      employmentType: json['employment_type']?.toString(),
      companyName: json['company_name']?.toString(),
      sector: json['sector']?.toString(),
      companyType: json['company_type']?.toString(),
      monthlySalary: json['monthly_salary']?.toString(),
      designation: json['designation']?.toString(),
      workExperience: json['work_experience']?.toString(),
      currentExperience: json['current_experience']?.toString(),
      incomeType: json['income_type']?.toString(),
      bankSalaryAmount: json['bank_salary_amount']?.toString(),
      cashSalaryAmount: json['cash_salary_amount']?.toString(),
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
      cibilScore: json['cibil_score'] is int
          ? json['cibil_score']
          : int.tryParse(json['cibil_score']?.toString() ?? ''),
      cibilIssue: json['cibil_issue']?.toString(),
      obligations: (json['obligations'] as List<dynamic>?)
              ?.map((e) => CoApplicantObligation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      propertyType: json['property_type']?.toString(),
      constructionStage: json['construction_stage']?.toString(),
      propertyValue: json['property_value'],
      areaSqft: json['area_sqft'],
      areaUnit: json['area_unit']?.toString(),
      agreementValue: json['agreement_value'],
      propertyLocation: json['property_location']?.toString(),
      propertyShare: json['property_share']?.toString(),
      documents: json['documents'] as Map<String, dynamic>?,
      profileImage: json['profile_image']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      netMonthlyIncome: json['net_monthly_income']?.toString(),
      grossMonthlyIncome: json['gross_monthly_income']?.toString(),
      annualIncome: json['annual_income']?.toString(),
      otherIncome: json['other_income']?.toString(),
      rentalIncome: json['rental_income']?.toString(),
      itrFiledYrs: json['itr_filed_yrs'],
      bankAccountType: json['bank_account_type']?.toString(),
      salaryMode: json['salary_mode']?.toString(),
      avgBankBalance: json['avg_bank_balance'],
      documentUrls: json['document_urls'] as Map<String, dynamic>?,
      panCardImageUrl: json['pan_card_image_url']?.toString(),
      aadhaarCardImageUrls: json['aadhaar_card_image_urls'] as List<dynamic>?,
      profileImageUrl: json['profile_image_url']?.toString(),
      documentAccess: json['document_access'] != null && json['document_access'] is Map<String, dynamic>
          ? CoAppDocumentAccess.fromJson(json['document_access'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (panCardNumber != null) 'pan_card_number': panCardNumber,
      if (panCardImage != null) 'pan_card_image': panCardImage,
      if (aadhaarCardNumber != null) 'aadhaar_card_number': aadhaarCardNumber,
      if (aadhaarCardImage != null) 'aadhaar_card_image': aadhaarCardImage,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (maritalStatus != null) 'marital_status': maritalStatus,
      if (religion != null) 'religion': religion,
      if (fatherName != null) 'father_name': fatherName,
      if (motherName != null) 'mother_name': motherName,
      if (currentResidenceType != null) 'current_residence_type': currentResidenceType,
      if (permanentAddress != null) 'permanent_address': permanentAddress,
      if (communicationAddress != null) 'communication_address': communicationAddress,
      if (address != null) 'address': address,
      if (relationship != null) 'relationship': relationship,
      if (applicantType != null) 'applicant_type': applicantType,
      if (employmentType != null) 'employment_type': employmentType,
      if (companyName != null) 'company_name': companyName,
      if (sector != null) 'sector': sector,
      if (companyType != null) 'company_type': companyType,
      if (monthlySalary != null) 'monthly_salary': monthlySalary,
      if (designation != null) 'designation': designation,
      if (workExperience != null) 'work_experience': workExperience,
      if (currentExperience != null) 'current_experience': currentExperience,
      if (incomeType != null) 'income_type': incomeType,
      if (bankSalaryAmount != null) 'bank_salary_amount': bankSalaryAmount,
      if (cashSalaryAmount != null) 'cash_salary_amount': cashSalaryAmount,
      if (companyAddress != null) 'company_address': companyAddress,
      if (cibilScore != null) 'cibil_score': cibilScore,
      if (cibilIssue != null) 'cibil_issue': cibilIssue,
      'obligations': obligations.map((e) => e.toJson()).toList(),
      if (profileImage != null) 'profile_image': profileImage,
    };
  }
}

class CoApplicantObligation {
  final String? bankName;
  final String? loanType;
  final num? emiAmount;
  final num? outstandingAmount;
  final String? remainingTenure;
  final num? overdueAmount;

  CoApplicantObligation({
    this.bankName,
    this.loanType,
    this.emiAmount,
    this.outstandingAmount,
    this.remainingTenure,
    this.overdueAmount,
  });

  factory CoApplicantObligation.fromJson(Map<String, dynamic> json) {
    return CoApplicantObligation(
      bankName: json['bank_name']?.toString(),
      loanType: json['loan_type']?.toString(),
      emiAmount: json['emi_amount'] as num?,
      outstandingAmount: json['outstanding_amount'] as num?,
      remainingTenure: json['remaining_tenure']?.toString(),
      overdueAmount: json['overdue_amount'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bankName != null) 'bank_name': bankName,
      if (loanType != null) 'loan_type': loanType,
      if (emiAmount != null) 'emi_amount': emiAmount,
      if (outstandingAmount != null) 'outstanding_amount': outstandingAmount,
      if (remainingTenure != null) 'remaining_tenure': remainingTenure,
      if (overdueAmount != null) 'overdue_amount': overdueAmount,
    };
  }
}

class CoApplicantDocumentConfig {
  final String? key;
  final String? label;
  final bool? allowMultiple;
  final List<String> acceptedFormats;
  final int? maxSizeMb;
  final String? uploadField;
  final bool? ocrAutofill;
  final bool? uploaded;
  final String? status;
  final List<CoApplicantDocFileItem> files;
  final List<CoApplicantUploadMode>? uploadModes;

  CoApplicantDocumentConfig({
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

  factory CoApplicantDocumentConfig.fromJson(Map<String, dynamic> json) {
    return CoApplicantDocumentConfig(
      key: json['key']?.toString(),
      label: json['label']?.toString(),
      allowMultiple: json['allow_multiple'] as bool?,
      acceptedFormats: (json['accepted_formats'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      maxSizeMb: json['max_size_mb'] is int ? json['max_size_mb'] : int.tryParse(json['max_size_mb']?.toString() ?? ''),
      uploadField: json['upload_field']?.toString(),
      ocrAutofill: json['ocr_autofill'] as bool?,
      uploaded: json['uploaded'] as bool?,
      status: json['status']?.toString(),
      files: (json['files'] as List<dynamic>?)
              ?.map((e) => CoApplicantDocFileItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      uploadModes: (json['upload_modes'] as List<dynamic>?)
              ?.map((e) => CoApplicantUploadMode.fromJson(e as Map<String, dynamic>))
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
      'files': files.map((e) => e.toJson()).toList(),
    };
  }
}

class CoApplicantDocFileItem {
  final String? docKey;
  final int? index;
  final String? name;
  final String? status;
  final String? url;

  CoApplicantDocFileItem({
    this.docKey,
    this.index,
    this.name,
    this.status,
    this.url,
  });

  factory CoApplicantDocFileItem.fromJson(Map<String, dynamic> json) {
    return CoApplicantDocFileItem(
      docKey: json['doc_key']?.toString(),
      index: json['index'] is int ? json['index'] : int.tryParse(json['index']?.toString() ?? ''),
      name: json['name']?.toString(),
      status: json['status']?.toString(),
      url: json['url']?.toString() ?? json['file']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (docKey != null) 'doc_key': docKey,
      if (index != null) 'index': index,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (url != null) 'url': url,
    };
  }
}

class CoApplicantUploadMode {
  final String? key;
  final String? label;
  final List<String> fields;
  final List<String> acceptedFormats;

  CoApplicantUploadMode({
    this.key,
    this.label,
    this.fields = const [],
    this.acceptedFormats = const [],
  });

  factory CoApplicantUploadMode.fromJson(Map<String, dynamic> json) {
    return CoApplicantUploadMode(
      key: json['key']?.toString(),
      label: json['label']?.toString(),
      fields: (json['fields'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      acceptedFormats: (json['accepted_formats'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class CoApplicantSummary {
  final int? total;
  final int? uploaded;

  CoApplicantSummary({this.total, this.uploaded});

  factory CoApplicantSummary.fromJson(Map<String, dynamic> json) {
    return CoApplicantSummary(
      total: json['total'] is int ? json['total'] : int.tryParse(json['total']?.toString() ?? ''),
      uploaded: json['uploaded'] is int ? json['uploaded'] : int.tryParse(json['uploaded']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (total != null) 'total': total,
      if (uploaded != null) 'uploaded': uploaded,
    };
  }
}

class CoApplicantUploadConfig {
  final String? method;
  final String? endpoint;
  final String? note;

  CoApplicantUploadConfig({this.method, this.endpoint, this.note});

  factory CoApplicantUploadConfig.fromJson(Map<String, dynamic> json) {
    return CoApplicantUploadConfig(
      method: json['method']?.toString(),
      endpoint: json['endpoint']?.toString(),
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (method != null) 'method': method,
      if (endpoint != null) 'endpoint': endpoint,
      if (note != null) 'note': note,
    };
  }
}
