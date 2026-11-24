/// Model representing GET {{base_url}}/my-documents response data.
/// Clean entity without status_code, success, message, or errors.
class MyDocumentsResponseData {
  final MyDocumentsUser? user;
  final MyDocumentItem? document;
  final List<MyDocumentsCoApplicant> coApplicants;
  final List<MyDocumentsLead> leads;

  MyDocumentsResponseData({
    this.user,
    this.document,
    this.coApplicants = const [],
    this.leads = const [],
  });

  factory MyDocumentsResponseData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        (json['data'] != null && json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;

    return MyDocumentsResponseData(
      user: data['user'] != null && data['user'] is Map<String, dynamic>
          ? MyDocumentsUser.fromJson(data['user'] as Map<String, dynamic>)
          : null,
      document: data['document'] != null && data['document'] is Map<String, dynamic>
          ? MyDocumentItem.fromJson(data['document'] as Map<String, dynamic>)
          : null,
      coApplicants: data['co_applicants'] != null && data['co_applicants'] is List
          ? (data['co_applicants'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => MyDocumentsCoApplicant.fromJson(e))
              .toList()
          : const [],
      leads: data['leads'] != null && data['leads'] is List
          ? (data['leads'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => MyDocumentsLead.fromJson(e))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        if (user != null) 'user': user!.toJson(),
        if (document != null) 'document': document!.toJson(),
        'co_applicants': coApplicants.map((e) => e.toJson()).toList(),
        'leads': leads.map((e) => e.toJson()).toList(),
      };
}

class MyDocumentsUser {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;

  MyDocumentsUser({this.id, this.name, this.phone, this.email});

  factory MyDocumentsUser.fromJson(Map<String, dynamic> json) {
    return MyDocumentsUser(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      };
}

class MyDocumentItem {
  final int? id;
  final dynamic userId;
  final dynamic customerId;
  final String? customerName;
  final String? aadharCardNumber;
  final String? aadharCardImage;
  final String? panCardNumber;
  final String? panCardImage;
  final String? createdAt;
  final String? updatedAt;
  final dynamic cibilScore;
  final String? aadhaarStatus;
  final String? aadhaarRejectReason;
  final String? panStatus;
  final String? panRejectReason;
  final String? businessProofImage;
  final String? salariedProofImage;

  MyDocumentItem({
    this.id,
    this.userId,
    this.customerId,
    this.customerName,
    this.aadharCardNumber,
    this.aadharCardImage,
    this.panCardNumber,
    this.panCardImage,
    this.createdAt,
    this.updatedAt,
    this.cibilScore,
    this.aadhaarStatus,
    this.aadhaarRejectReason,
    this.panStatus,
    this.panRejectReason,
    this.businessProofImage,
    this.salariedProofImage,
  });

  factory MyDocumentItem.fromJson(Map<String, dynamic> json) {
    return MyDocumentItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['user_id'],
      customerId: json['customer_id'],
      customerName: json['customer_name']?.toString(),
      aadharCardNumber: json['aadhar_card_number']?.toString(),
      aadharCardImage: json['aadhar_card_image']?.toString(),
      panCardNumber: json['pan_card_number']?.toString(),
      panCardImage: json['pan_card_image']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      cibilScore: json['cibil_score'],
      aadhaarStatus: json['aadhaar_status']?.toString(),
      aadhaarRejectReason: json['aadhaar_reject_reason']?.toString(),
      panStatus: json['pan_status']?.toString(),
      panRejectReason: json['pan_reject_reason']?.toString(),
      businessProofImage: json['business_proof_image']?.toString(),
      salariedProofImage: json['salaried_proof_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (userId != null) 'user_id': userId,
        if (customerId != null) 'customer_id': customerId,
        if (customerName != null) 'customer_name': customerName,
        if (aadharCardNumber != null) 'aadhar_card_number': aadharCardNumber,
        if (aadharCardImage != null) 'aadhar_card_image': aadharCardImage,
        if (panCardNumber != null) 'pan_card_number': panCardNumber,
        if (panCardImage != null) 'pan_card_image': panCardImage,
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt,
        if (cibilScore != null) 'cibil_score': cibilScore,
        if (aadhaarStatus != null) 'aadhaar_status': aadhaarStatus,
        if (aadhaarRejectReason != null) 'aadhaar_reject_reason': aadhaarRejectReason,
        if (panStatus != null) 'pan_status': panStatus,
        if (panRejectReason != null) 'pan_reject_reason': panRejectReason,
        if (businessProofImage != null) 'business_proof_image': businessProofImage,
        if (salariedProofImage != null) 'salaried_proof_image': salariedProofImage,
      };
}

class MyDocumentsCoApplicant {
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
  final String? aadhaarCardImage;
  final String? panCardImage;
  final String? employmentType;
  final dynamic documents;
  final String? applicantType;

  MyDocumentsCoApplicant({
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
    this.aadhaarCardImage,
    this.panCardImage,
    this.employmentType,
    this.documents,
    this.applicantType,
  });

  factory MyDocumentsCoApplicant.fromJson(Map<String, dynamic> json) {
    return MyDocumentsCoApplicant(
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
      aadhaarCardImage: json['aadhaar_card_image']?.toString(),
      panCardImage: json['pan_card_image']?.toString(),
      employmentType: json['employment_type']?.toString(),
      documents: json['documents'],
      applicantType: json['applicant_type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (userId != null) 'user_id': userId,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (panCardNumber != null) 'pan_card_number': panCardNumber,
        if (aadhaarCardNumber != null) 'aadhaar_card_number': aadhaarCardNumber,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (gender != null) 'gender': gender,
        if (address != null) 'address': address,
        if (relationship != null) 'relationship': relationship,
        if (profileImage != null) 'profile_image': profileImage,
        if (aadhaarCardImage != null) 'aadhaar_card_image': aadhaarCardImage,
        if (panCardImage != null) 'pan_card_image': panCardImage,
        if (employmentType != null) 'employment_type': employmentType,
        if (documents != null) 'documents': documents,
        if (applicantType != null) 'applicant_type': applicantType,
      };
}

class MyDocumentsLead {
  final int? id;
  final dynamic userId;
  final String? loanType;
  final num? loanAmount;
  final String? employmentType;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? bankStatement;
  final String? salariedProofImage;
  final String? businessProofImage;
  final String? form16Itr;
  final String? latestSalarySlips;
  final String? salaryLetterpad;
  final String? gstRegistration;
  final String? udyamRegistration;
  final String? otherDoc;

  MyDocumentsLead({
    this.id,
    this.userId,
    this.loanType,
    this.loanAmount,
    this.employmentType,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.bankStatement,
    this.salariedProofImage,
    this.businessProofImage,
    this.form16Itr,
    this.latestSalarySlips,
    this.salaryLetterpad,
    this.gstRegistration,
    this.udyamRegistration,
    this.otherDoc,
  });

  factory MyDocumentsLead.fromJson(Map<String, dynamic> json) {
    return MyDocumentsLead(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['user_id'],
      loanType: json['loan_type']?.toString(),
      loanAmount: json['loan_amount'] is num
          ? json['loan_amount']
          : num.tryParse(json['loan_amount']?.toString() ?? ''),
      employmentType: json['employment_type']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      bankStatement: json['bank_statement']?.toString(),
      salariedProofImage: json['salaried_proof_image']?.toString(),
      businessProofImage: json['business_proof_image']?.toString(),
      form16Itr: json['form_16_itr']?.toString(),
      latestSalarySlips: json['latest_salary_slips']?.toString(),
      salaryLetterpad: json['salary_letterpad']?.toString(),
      gstRegistration: json['gst_registration']?.toString(),
      udyamRegistration: json['udyam_registration']?.toString(),
      otherDoc: json['other_doc']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (userId != null) 'user_id': userId,
        if (loanType != null) 'loan_type': loanType,
        if (loanAmount != null) 'loan_amount': loanAmount,
        if (employmentType != null) 'employment_type': employmentType,
        if (status != null) 'status': status,
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt,
        if (bankStatement != null) 'bank_statement': bankStatement,
      };
}
