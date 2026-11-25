import 'user_model.dart';

/// Model representing the Applicant Details response data.
/// Styled like [UserModel], directly mapping the applicant data entity
/// without storing status_code, success, message, or errors.
class ApplicantDetailModel {
  final ApplicantProfile? applicant;
  final ApplicantKyc? kyc;
  final ApplicantApplicationStatus? applicationStatus;
  final List<ApplicantLoanApplication> loanApplications;
  final List<ApplicantCoApplicantItem> coApplicants;
  final ApplicantSummary? summary;

  ApplicantDetailModel({
    this.applicant,
    this.kyc,
    this.applicationStatus,
    this.loanApplications = const [],
    this.coApplicants = const [],
    this.summary,
  });

  factory ApplicantDetailModel.fromJson(Map<String, dynamic> json) {
    // If the full response wrapper is passed, unwrap 'data'
    final Map<String, dynamic> data =
        (json['data'] != null && json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;

    return ApplicantDetailModel(
      applicant: data['applicant'] != null && data['applicant'] is Map<String, dynamic>
          ? ApplicantProfile.fromJson(data['applicant'] as Map<String, dynamic>)
          : null,
      kyc: data['kyc'] != null && data['kyc'] is Map<String, dynamic>
          ? ApplicantKyc.fromJson(data['kyc'] as Map<String, dynamic>)
          : null,
      applicationStatus: data['application_status'] != null &&
              data['application_status'] is Map<String, dynamic>
          ? ApplicantApplicationStatus.fromJson(
              data['application_status'] as Map<String, dynamic>)
          : null,
      loanApplications: data['loan_applications'] != null &&
              data['loan_applications'] is List
          ? (data['loan_applications'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ApplicantLoanApplication.fromJson(e))
              .toList()
          : const [],
      coApplicants: data['co_applicants'] != null && data['co_applicants'] is List
          ? (data['co_applicants'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ApplicantCoApplicantItem.fromJson(e))
              .toList()
          : const [],
      summary: data['summary'] != null && data['summary'] is Map<String, dynamic>
          ? ApplicantSummary.fromJson(data['summary'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (applicant != null) 'applicant': applicant!.toJson(),
      if (kyc != null) 'kyc': kyc!.toJson(),
      if (applicationStatus != null)
        'application_status': applicationStatus!.toJson(),
      'loan_applications': loanApplications.map((e) => e.toJson()).toList(),
      'co_applicants': coApplicants.map((e) => e.toJson()).toList(),
      if (summary != null) 'summary': summary!.toJson(),
    };
  }

  /// Converts [ApplicantProfile] + active employment role directly into a unified [UserModel]
  UserModel? toUserModel() {
    if (applicant == null) return null;
    final p = applicant!;
    final empType = loanApplications.isNotEmpty
        ? loanApplications.first.employmentDetails?.employmentType
        : null;

    return UserModel(
      id: p.id,
      name: p.name,
      email: p.email,
      phone: p.phone,
      dob: p.dateOfBirth,
      gender: p.gender,
      maritalStatus: p.maritalStatus,
      address: (p.address != null && p.address!.isNotEmpty)
          ? p.address
          : (p.communicationAddress != null && p.communicationAddress!.isNotEmpty)
              ? p.communicationAddress
              : p.permanentAddress,
      addressType: p.addressType,
      photoUrl: p.profilePhotoUrl,
      role: empType,
      currentStep: p.currentStep,
    );
  }
}

/// Primary Applicant Personal & Contact Information
class ApplicantProfile {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? altPhone;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? fatherName;
  final String? motherName;
  final String? religion;
  final String? panCardNumber;
  final String? aadhaarCardNumber;
  final String? address;
  final String? addressType;
  final String? currentResidenceType;
  final String? communicationAddress;
  final String? permanentAddress;
  final String? city;
  final String? state;
  final String? profilePhotoUrl;
  final String? referenceCode;
  final int? currentStep;
  final String? registeredAt;
  final String? updatedAt;

  ApplicantProfile({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.altPhone,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    this.fatherName,
    this.motherName,
    this.religion,
    this.panCardNumber,
    this.aadhaarCardNumber,
    this.address,
    this.addressType,
    this.currentResidenceType,
    this.communicationAddress,
    this.permanentAddress,
    this.city,
    this.state,
    this.profilePhotoUrl,
    this.referenceCode,
    this.currentStep,
    this.registeredAt,
    this.updatedAt,
  });

  factory ApplicantProfile.fromJson(Map<String, dynamic> json) {
    return ApplicantProfile(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      altPhone: json['alt_phone']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      gender: json['gender']?.toString(),
      maritalStatus: json['marital_status']?.toString(),
      fatherName: json['father_name']?.toString(),
      motherName: json['mother_name']?.toString(),
      religion: json['religion']?.toString(),
      panCardNumber: json['pan_card_number']?.toString(),
      aadhaarCardNumber: json['aadhaar_card_number']?.toString(),
      address: json['address']?.toString(),
      addressType: json['address_type']?.toString(),
      currentResidenceType: json['current_residence_type']?.toString(),
      communicationAddress: json['communication_address']?.toString(),
      permanentAddress: json['permanent_address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      profilePhotoUrl: json['profile_photo_url']?.toString(),
      referenceCode: json['reference_code']?.toString(),
      currentStep: json['current_step'] is int
          ? json['current_step']
          : int.tryParse(json['current_step']?.toString() ?? ''),
      registeredAt: json['registered_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (altPhone != null) 'alt_phone': altPhone,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (maritalStatus != null) 'marital_status': maritalStatus,
      if (fatherName != null) 'father_name': fatherName,
      if (motherName != null) 'mother_name': motherName,
      if (religion != null) 'religion': religion,
      if (panCardNumber != null) 'pan_card_number': panCardNumber,
      if (aadhaarCardNumber != null) 'aadhaar_card_number': aadhaarCardNumber,
      if (address != null) 'address': address,
      if (addressType != null) 'address_type': addressType,
      if (currentResidenceType != null)
        'current_residence_type': currentResidenceType,
      if (communicationAddress != null)
        'communication_address': communicationAddress,
      if (permanentAddress != null) 'permanent_address': permanentAddress,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (profilePhotoUrl != null) 'profile_photo_url': profilePhotoUrl,
      if (referenceCode != null) 'reference_code': referenceCode,
      if (currentStep != null) 'current_step': currentStep,
      if (registeredAt != null) 'registered_at': registeredAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }
}

/// KYC details including Aadhaar, PAN, and CIBIL
class ApplicantKyc {
  final ApplicantKycDocument? aadhaar;
  final ApplicantKycDocument? pan;
  final int? cibilScore;
  final String? updatedAt;

  ApplicantKyc({
    this.aadhaar,
    this.pan,
    this.cibilScore,
    this.updatedAt,
  });

  factory ApplicantKyc.fromJson(Map<String, dynamic> json) {
    return ApplicantKyc(
      aadhaar: json['aadhaar'] != null && json['aadhaar'] is Map<String, dynamic>
          ? ApplicantKycDocument.fromJson(json['aadhaar'] as Map<String, dynamic>)
          : null,
      pan: json['pan'] != null && json['pan'] is Map<String, dynamic>
          ? ApplicantKycDocument.fromJson(json['pan'] as Map<String, dynamic>)
          : null,
      cibilScore: json['cibil_score'] is int
          ? json['cibil_score']
          : int.tryParse(json['cibil_score']?.toString() ?? ''),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (aadhaar != null) 'aadhaar': aadhaar!.toJson(),
      if (pan != null) 'pan': pan!.toJson(),
      if (cibilScore != null) 'cibil_score': cibilScore,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }
}

class ApplicantKycDocument {
  final String? number;
  final String? nameOnCard;
  final bool? uploaded;
  final String? status;
  final String? rejectReason;
  final String? viewEndpoint;
  final String? viewUrl;
  final List<ApplicantDocFile> files;

  ApplicantKycDocument({
    this.number,
    this.nameOnCard,
    this.uploaded,
    this.status,
    this.rejectReason,
    this.viewEndpoint,
    this.viewUrl,
    this.files = const [],
  });

  factory ApplicantKycDocument.fromJson(Map<String, dynamic> json) {
    return ApplicantKycDocument(
      number: json['number']?.toString(),
      nameOnCard: json['name_on_card']?.toString(),
      uploaded: json['uploaded'] is bool
          ? json['uploaded']
          : json['uploaded']?.toString() == 'true',
      status: json['status']?.toString(),
      rejectReason: json['reject_reason']?.toString(),
      viewEndpoint: json['view_endpoint']?.toString(),
      viewUrl: json['view_url']?.toString(),
      files: json['files'] != null && json['files'] is List
          ? (json['files'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ApplicantDocFile.fromJson(e))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (number != null) 'number': number,
      if (nameOnCard != null) 'name_on_card': nameOnCard,
      if (uploaded != null) 'uploaded': uploaded,
      if (status != null) 'status': status,
      if (rejectReason != null) 'reject_reason': rejectReason,
      if (viewEndpoint != null) 'view_endpoint': viewEndpoint,
      if (viewUrl != null) 'view_url': viewUrl,
      'files': files.map((e) => e.toJson()).toList(),
    };
  }
}

/// Overall application progress and status
class ApplicantApplicationStatus {
  final int? currentStep;
  final num? progressPercent;
  final bool? isSubmitted;
  final bool? hasCoApplicant;
  final String? coApplicantStatus;
  final String? activeStep;
  final List<ApplicantStepItem> steps;
  final ApplicantNextAction? nextAction;
  final ApplicantLatestLead? latestLead;

  ApplicantApplicationStatus({
    this.currentStep,
    this.progressPercent,
    this.isSubmitted,
    this.hasCoApplicant,
    this.coApplicantStatus,
    this.activeStep,
    this.steps = const [],
    this.nextAction,
    this.latestLead,
  });

  factory ApplicantApplicationStatus.fromJson(Map<String, dynamic> json) {
    return ApplicantApplicationStatus(
      currentStep: json['current_step'] is int
          ? json['current_step']
          : int.tryParse(json['current_step']?.toString() ?? ''),
      progressPercent: json['progress_percent'] is num
          ? json['progress_percent']
          : num.tryParse(json['progress_percent']?.toString() ?? ''),
      isSubmitted: json['is_submitted'] is bool
          ? json['is_submitted']
          : json['is_submitted']?.toString() == 'true',
      hasCoApplicant: json['has_co_applicant'] is bool
          ? json['has_co_applicant']
          : json['has_co_applicant']?.toString() == 'true',
      coApplicantStatus: json['co_applicant_status']?.toString(),
      activeStep: json['active_step']?.toString(),
      steps: json['steps'] != null && json['steps'] is List
          ? (json['steps'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ApplicantStepItem.fromJson(e))
              .toList()
          : const [],
      nextAction: json['next_action'] != null &&
              json['next_action'] is Map<String, dynamic>
          ? ApplicantNextAction.fromJson(
              json['next_action'] as Map<String, dynamic>)
          : null,
      latestLead: json['latest_lead'] != null &&
              json['latest_lead'] is Map<String, dynamic>
          ? ApplicantLatestLead.fromJson(
              json['latest_lead'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (currentStep != null) 'current_step': currentStep,
      if (progressPercent != null) 'progress_percent': progressPercent,
      if (isSubmitted != null) 'is_submitted': isSubmitted,
      if (hasCoApplicant != null) 'has_co_applicant': hasCoApplicant,
      if (coApplicantStatus != null) 'co_applicant_status': coApplicantStatus,
      if (activeStep != null) 'active_step': activeStep,
      'steps': steps.map((e) => e.toJson()).toList(),
      if (nextAction != null) 'next_action': nextAction!.toJson(),
      if (latestLead != null) 'latest_lead': latestLead!.toJson(),
    };
  }
}

class ApplicantStepItem {
  final String? key;
  final String? title;
  final String? icon;
  final String? status;
  final bool? isCompleted;
  final int? stepNumber;
  final String? stepLabel;

  ApplicantStepItem({
    this.key,
    this.title,
    this.icon,
    this.status,
    this.isCompleted,
    this.stepNumber,
    this.stepLabel,
  });

  factory ApplicantStepItem.fromJson(Map<String, dynamic> json) {
    return ApplicantStepItem(
      key: json['key']?.toString(),
      title: json['title']?.toString(),
      icon: json['icon']?.toString(),
      status: json['status']?.toString(),
      isCompleted: json['is_completed'] is bool
          ? json['is_completed']
          : json['is_completed']?.toString() == 'true',
      stepNumber: json['step_number'] is int
          ? json['step_number']
          : int.tryParse(json['step_number']?.toString() ?? ''),
      stepLabel: json['step_label']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (icon != null) 'icon': icon,
      if (status != null) 'status': status,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (stepNumber != null) 'step_number': stepNumber,
      if (stepLabel != null) 'step_label': stepLabel,
    };
  }
}

class ApplicantNextAction {
  final String? screen;
  final String? label;

  ApplicantNextAction({this.screen, this.label});

  factory ApplicantNextAction.fromJson(Map<String, dynamic> json) {
    return ApplicantNextAction(
      screen: json['screen']?.toString(),
      label: json['label']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (screen != null) 'screen': screen,
      if (label != null) 'label': label,
    };
  }
}

class ApplicantLatestLead {
  final int? id;
  final String? loanType;
  final num? loanAmount;
  final String? employmentType;
  final String? status;
  final String? createdAt;

  ApplicantLatestLead({
    this.id,
    this.loanType,
    this.loanAmount,
    this.employmentType,
    this.status,
    this.createdAt,
  });

  factory ApplicantLatestLead.fromJson(Map<String, dynamic> json) {
    return ApplicantLatestLead(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      loanType: json['loan_type']?.toString(),
      loanAmount: json['loan_amount'] is num
          ? json['loan_amount']
          : num.tryParse(json['loan_amount']?.toString() ?? ''),
      employmentType: json['employment_type']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (loanType != null) 'loan_type': loanType,
      if (loanAmount != null) 'loan_amount': loanAmount,
      if (employmentType != null) 'employment_type': employmentType,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}

/// Loan Application entity attached to the Applicant
class ApplicantLoanApplication {
  final int? id;
  final String? loanApplicationNumber;
  final String? loanType;
  final num? loanAmount;
  final String? status;
  final String? statusLabel;
  final bool? isActive;
  final String? leadSource;
  final String? requirementSummary;
  final String? loanProduct;
  final dynamic projectId;
  final ApplicantAssignedTo? assignedTo;
  final String? createdAt;
  final String? updatedAt;
  final String? lastActivityAt;
  final ApplicantPersonalDetails? personalDetails;
  final ApplicantEmploymentDetails? employmentDetails;
  final ApplicantIncomeDetails? incomeDetails;
  final ApplicantBankDetails? bankDetails;
  final ApplicantCharges? charges;
  final ApplicantBalanceTransfer? balanceTransfer;
  final ApplicantPropertyDetails? propertyDetails;
  final ApplicantVehicleDetails? vehicleDetails;
  final ApplicantReferenceDetails? referenceDetails;
  final List<ApplicantObligation> obligations;
  final ApplicantDocsSummary? documentsSummary;
  final List<ApplicantDocumentItem> documents;

  ApplicantLoanApplication({
    this.id,
    this.loanApplicationNumber,
    this.loanType,
    this.loanAmount,
    this.status,
    this.statusLabel,
    this.isActive,
    this.leadSource,
    this.requirementSummary,
    this.loanProduct,
    this.projectId,
    this.assignedTo,
    this.createdAt,
    this.updatedAt,
    this.lastActivityAt,
    this.personalDetails,
    this.employmentDetails,
    this.incomeDetails,
    this.bankDetails,
    this.charges,
    this.balanceTransfer,
    this.propertyDetails,
    this.vehicleDetails,
    this.referenceDetails,
    this.obligations = const [],
    this.documentsSummary,
    this.documents = const [],
  });

  factory ApplicantLoanApplication.fromJson(Map<String, dynamic> json) {
    return ApplicantLoanApplication(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      loanApplicationNumber: json['loan_application_number']?.toString(),
      loanType: json['loan_type']?.toString(),
      loanAmount: json['loan_amount'] is num
          ? json['loan_amount']
          : num.tryParse(json['loan_amount']?.toString() ?? ''),
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      isActive: json['is_active'] is bool
          ? json['is_active']
          : json['is_active']?.toString() == 'true',
      leadSource: json['lead_source']?.toString(),
      requirementSummary: json['requirement_summary']?.toString(),
      loanProduct: json['loan_product']?.toString(),
      projectId: json['project_id'],
      assignedTo: json['assigned_to'] != null &&
              json['assigned_to'] is Map<String, dynamic>
          ? ApplicantAssignedTo.fromJson(
              json['assigned_to'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      lastActivityAt: json['last_activity_at']?.toString(),
      personalDetails: json['personal_details'] != null &&
              json['personal_details'] is Map<String, dynamic>
          ? ApplicantPersonalDetails.fromJson(
              json['personal_details'] as Map<String, dynamic>)
          : null,
      employmentDetails: json['employment_details'] != null &&
              json['employment_details'] is Map<String, dynamic>
          ? ApplicantEmploymentDetails.fromJson(
              json['employment_details'] as Map<String, dynamic>)
          : null,
      incomeDetails: json['income_details'] != null &&
              json['income_details'] is Map<String, dynamic>
          ? ApplicantIncomeDetails.fromJson(
              json['income_details'] as Map<String, dynamic>)
          : null,
      bankDetails: json['bank_details'] != null &&
              json['bank_details'] is Map<String, dynamic>
          ? ApplicantBankDetails.fromJson(
              json['bank_details'] as Map<String, dynamic>)
          : null,
      charges: json['charges'] != null && json['charges'] is Map<String, dynamic>
          ? ApplicantCharges.fromJson(json['charges'] as Map<String, dynamic>)
          : null,
      balanceTransfer: json['balance_transfer'] != null &&
              json['balance_transfer'] is Map<String, dynamic>
          ? ApplicantBalanceTransfer.fromJson(
              json['balance_transfer'] as Map<String, dynamic>)
          : null,
      propertyDetails: json['property_details'] != null &&
              json['property_details'] is Map<String, dynamic>
          ? ApplicantPropertyDetails.fromJson(
              json['property_details'] as Map<String, dynamic>)
          : null,
      vehicleDetails: json['vehicle_details'] != null &&
              json['vehicle_details'] is Map<String, dynamic>
          ? ApplicantVehicleDetails.fromJson(
              json['vehicle_details'] as Map<String, dynamic>)
          : null,
      referenceDetails: json['reference_details'] != null &&
              json['reference_details'] is Map<String, dynamic>
          ? ApplicantReferenceDetails.fromJson(
              json['reference_details'] as Map<String, dynamic>)
          : null,
      obligations: json['obligations'] != null && json['obligations'] is List
          ? (json['obligations'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ApplicantObligation.fromJson(e))
              .toList()
          : const [],
      documentsSummary: json['documents_summary'] != null &&
              json['documents_summary'] is Map<String, dynamic>
          ? ApplicantDocsSummary.fromJson(
              json['documents_summary'] as Map<String, dynamic>)
          : null,
      documents: json['documents'] != null && json['documents'] is List
          ? (json['documents'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ApplicantDocumentItem.fromJson(e))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (loanApplicationNumber != null)
        'loan_application_number': loanApplicationNumber,
      if (loanType != null) 'loan_type': loanType,
      if (loanAmount != null) 'loan_amount': loanAmount,
      if (status != null) 'status': status,
      if (statusLabel != null) 'status_label': statusLabel,
      if (isActive != null) 'is_active': isActive,
      if (leadSource != null) 'lead_source': leadSource,
      if (requirementSummary != null)
        'requirement_summary': requirementSummary,
      if (loanProduct != null) 'loan_product': loanProduct,
      if (projectId != null) 'project_id': projectId,
      if (assignedTo != null) 'assigned_to': assignedTo!.toJson(),
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastActivityAt != null) 'last_activity_at': lastActivityAt,
      if (personalDetails != null)
        'personal_details': personalDetails!.toJson(),
      if (employmentDetails != null)
        'employment_details': employmentDetails!.toJson(),
      if (incomeDetails != null) 'income_details': incomeDetails!.toJson(),
      if (bankDetails != null) 'bank_details': bankDetails!.toJson(),
      if (charges != null) 'charges': charges!.toJson(),
      if (balanceTransfer != null)
        'balance_transfer': balanceTransfer!.toJson(),
      if (propertyDetails != null)
        'property_details': propertyDetails!.toJson(),
      if (vehicleDetails != null) 'vehicle_details': vehicleDetails!.toJson(),
      if (referenceDetails != null)
        'reference_details': referenceDetails!.toJson(),
      'obligations': obligations.map((e) => e.toJson()).toList(),
      if (documentsSummary != null)
        'documents_summary': documentsSummary!.toJson(),
      'documents': documents.map((e) => e.toJson()).toList(),
    };
  }
}

class ApplicantAssignedTo {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;

  ApplicantAssignedTo({this.id, this.name, this.phone, this.email});

  factory ApplicantAssignedTo.fromJson(Map<String, dynamic> json) {
    return ApplicantAssignedTo(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
    };
  }
}

class ApplicantPersonalDetails {
  final String? altPhone;
  final String? fatherName;
  final String? motherName;
  final String? religion;
  final String? currentResidenceType;
  final String? communicationAddress;
  final String? permanentAddress;
  final String? city;
  final String? cibilIssue;

  ApplicantPersonalDetails({
    this.altPhone,
    this.fatherName,
    this.motherName,
    this.religion,
    this.currentResidenceType,
    this.communicationAddress,
    this.permanentAddress,
    this.city,
    this.cibilIssue,
  });

  factory ApplicantPersonalDetails.fromJson(Map<String, dynamic> json) {
    return ApplicantPersonalDetails(
      altPhone: json['alt_phone']?.toString(),
      fatherName: json['father_name']?.toString(),
      motherName: json['mother_name']?.toString(),
      religion: json['religion']?.toString(),
      currentResidenceType: json['current_residence_type']?.toString(),
      communicationAddress: json['communication_address']?.toString(),
      permanentAddress: json['permanent_address']?.toString(),
      city: json['city']?.toString(),
      cibilIssue: json['cibil_issue']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (altPhone != null) 'alt_phone': altPhone,
      if (fatherName != null) 'father_name': fatherName,
      if (motherName != null) 'mother_name': motherName,
      if (religion != null) 'religion': religion,
      if (currentResidenceType != null)
        'current_residence_type': currentResidenceType,
      if (communicationAddress != null)
        'communication_address': communicationAddress,
      if (permanentAddress != null) 'permanent_address': permanentAddress,
      if (city != null) 'city': city,
      if (cibilIssue != null) 'cibil_issue': cibilIssue,
    };
  }
}

class ApplicantEmploymentDetails {
  final String? employmentType;
  final String? occupation;
  final String? companyType;
  final String? incomeType;
  final String? companyName;
  final String? sector;
  final String? designation;
  final num? monthlySalary;
  final String? workExperience;
  final String? currentExperience;
  final num? bankSalaryAmount;
  final num? cashSalaryAmount;
  final String? companyAddress;
  final String? businessName;
  final String? businessEntity;
  final String? businessVintage;
  final String? natureOfBusiness;
  final num? businessTurnover;
  final String? businessAddress;
  final String? officeType;
  final dynamic businessEstablishedYear;
  final dynamic yearsInCurrentBusiness;
  final dynamic itr;

  ApplicantEmploymentDetails({
    this.employmentType,
    this.occupation,
    this.companyType,
    this.incomeType,
    this.companyName,
    this.sector,
    this.designation,
    this.monthlySalary,
    this.workExperience,
    this.currentExperience,
    this.bankSalaryAmount,
    this.cashSalaryAmount,
    this.companyAddress,
    this.businessName,
    this.businessEntity,
    this.businessVintage,
    this.natureOfBusiness,
    this.businessTurnover,
    this.businessAddress,
    this.officeType,
    this.businessEstablishedYear,
    this.yearsInCurrentBusiness,
    this.itr,
  });

  factory ApplicantEmploymentDetails.fromJson(Map<String, dynamic> json) {
    return ApplicantEmploymentDetails(
      employmentType: json['employment_type']?.toString(),
      occupation: json['occupation']?.toString(),
      companyType: json['company_type']?.toString(),
      incomeType: json['income_type']?.toString(),
      companyName: json['company_name']?.toString(),
      sector: json['sector']?.toString(),
      designation: json['designation']?.toString(),
      monthlySalary: json['monthly_salary'] is num
          ? json['monthly_salary']
          : num.tryParse(json['monthly_salary']?.toString() ?? ''),
      workExperience: json['work_experience']?.toString(),
      currentExperience: json['current_experience']?.toString(),
      bankSalaryAmount: json['bank_salary_amount'] is num
          ? json['bank_salary_amount']
          : num.tryParse(json['bank_salary_amount']?.toString() ?? ''),
      cashSalaryAmount: json['cash_salary_amount'] is num
          ? json['cash_salary_amount']
          : num.tryParse(json['cash_salary_amount']?.toString() ?? ''),
      companyAddress: json['company_address']?.toString(),
      businessName: json['business_name']?.toString(),
      businessEntity: json['business_entity']?.toString(),
      businessVintage: json['business_vintage']?.toString(),
      natureOfBusiness: json['nature_of_business']?.toString(),
      businessTurnover: json['business_turnover'] is num
          ? json['business_turnover']
          : num.tryParse(json['business_turnover']?.toString() ?? ''),
      businessAddress: json['business_address']?.toString(),
      officeType: json['office_type']?.toString(),
      businessEstablishedYear: json['business_established_year'],
      yearsInCurrentBusiness: json['years_in_current_business'],
      itr: json['itr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (employmentType != null) 'employment_type': employmentType,
      if (occupation != null) 'occupation': occupation,
      if (companyType != null) 'company_type': companyType,
      if (incomeType != null) 'income_type': incomeType,
      if (companyName != null) 'company_name': companyName,
      if (sector != null) 'sector': sector,
      if (designation != null) 'designation': designation,
      if (monthlySalary != null) 'monthly_salary': monthlySalary,
      if (workExperience != null) 'work_experience': workExperience,
      if (currentExperience != null) 'current_experience': currentExperience,
      if (bankSalaryAmount != null) 'bank_salary_amount': bankSalaryAmount,
      if (cashSalaryAmount != null) 'cash_salary_amount': cashSalaryAmount,
      if (companyAddress != null) 'company_address': companyAddress,
      if (businessName != null) 'business_name': businessName,
      if (businessEntity != null) 'business_entity': businessEntity,
      if (businessVintage != null) 'business_vintage': businessVintage,
      if (natureOfBusiness != null) 'nature_of_business': natureOfBusiness,
      if (businessTurnover != null) 'business_turnover': businessTurnover,
      if (businessAddress != null) 'business_address': businessAddress,
      if (officeType != null) 'office_type': officeType,
      if (businessEstablishedYear != null)
        'business_established_year': businessEstablishedYear,
      if (yearsInCurrentBusiness != null)
        'years_in_current_business': yearsInCurrentBusiness,
      if (itr != null) 'itr': itr,
    };
  }
}

class ApplicantIncomeDetails {
  final num? netMonthlyIncome;
  final num? grossMonthlyIncome;
  final num? annualIncome;
  final num? otherIncome;
  final num? rentalIncome;
  final dynamic itrFiledYrs;
  final String? bankAccountType;
  final String? salaryMode;
  final num? avgBankBalance;

  ApplicantIncomeDetails({
    this.netMonthlyIncome,
    this.grossMonthlyIncome,
    this.annualIncome,
    this.otherIncome,
    this.rentalIncome,
    this.itrFiledYrs,
    this.bankAccountType,
    this.salaryMode,
    this.avgBankBalance,
  });

  factory ApplicantIncomeDetails.fromJson(Map<String, dynamic> json) {
    return ApplicantIncomeDetails(
      netMonthlyIncome: json['net_monthly_income'] is num
          ? json['net_monthly_income']
          : num.tryParse(json['net_monthly_income']?.toString() ?? ''),
      grossMonthlyIncome: json['gross_monthly_income'] is num
          ? json['gross_monthly_income']
          : num.tryParse(json['gross_monthly_income']?.toString() ?? ''),
      annualIncome: json['annual_income'] is num
          ? json['annual_income']
          : num.tryParse(json['annual_income']?.toString() ?? ''),
      otherIncome: json['other_income'] is num
          ? json['other_income']
          : num.tryParse(json['other_income']?.toString() ?? ''),
      rentalIncome: json['rental_income'] is num
          ? json['rental_income']
          : num.tryParse(json['rental_income']?.toString() ?? ''),
      itrFiledYrs: json['itr_filed_yrs'],
      bankAccountType: json['bank_account_type']?.toString(),
      salaryMode: json['salary_mode']?.toString(),
      avgBankBalance: json['avg_bank_balance'] is num
          ? json['avg_bank_balance']
          : num.tryParse(json['avg_bank_balance']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (netMonthlyIncome != null) 'net_monthly_income': netMonthlyIncome,
      if (grossMonthlyIncome != null)
        'gross_monthly_income': grossMonthlyIncome,
      if (annualIncome != null) 'annual_income': annualIncome,
      if (otherIncome != null) 'other_income': otherIncome,
      if (rentalIncome != null) 'rental_income': rentalIncome,
      if (itrFiledYrs != null) 'itr_filed_yrs': itrFiledYrs,
      if (bankAccountType != null) 'bank_account_type': bankAccountType,
      if (salaryMode != null) 'salary_mode': salaryMode,
      if (avgBankBalance != null) 'avg_bank_balance': avgBankBalance,
    };
  }
}

class ApplicantBankDetails {
  final String? bankName;
  final String? bankEmployeeName;
  final String? loginDate;
  final String? loanApplicationNumber;
  final num? sanctionedAmount;
  final String? sanctionDate;
  final num? disbursedAmount;
  final String? disbursementDate;
  final num? netDisbursableAmount;
  final num? emi;
  final int? tenureMonths;
  final num? interestRate;
  final num? rtoCharges;

  ApplicantBankDetails({
    this.bankName,
    this.bankEmployeeName,
    this.loginDate,
    this.loanApplicationNumber,
    this.sanctionedAmount,
    this.sanctionDate,
    this.disbursedAmount,
    this.disbursementDate,
    this.netDisbursableAmount,
    this.emi,
    this.tenureMonths,
    this.interestRate,
    this.rtoCharges,
  });

  factory ApplicantBankDetails.fromJson(Map<String, dynamic> json) {
    return ApplicantBankDetails(
      bankName: json['bank_name']?.toString(),
      bankEmployeeName: json['bank_employee_name']?.toString(),
      loginDate: json['login_date']?.toString(),
      loanApplicationNumber: json['loan_application_number']?.toString(),
      sanctionedAmount: json['sanctioned_amount'] is num
          ? json['sanctioned_amount']
          : num.tryParse(json['sanctioned_amount']?.toString() ?? ''),
      sanctionDate: json['sanction_date']?.toString(),
      disbursedAmount: json['disbursed_amount'] is num
          ? json['disbursed_amount']
          : num.tryParse(json['disbursed_amount']?.toString() ?? ''),
      disbursementDate: json['disbursement_date']?.toString(),
      netDisbursableAmount: json['net_disbursable_amount'] is num
          ? json['net_disbursable_amount']
          : num.tryParse(json['net_disbursable_amount']?.toString() ?? ''),
      emi: json['emi'] is num
          ? json['emi']
          : num.tryParse(json['emi']?.toString() ?? ''),
      tenureMonths: json['tenure_months'] is int
          ? json['tenure_months']
          : int.tryParse(json['tenure_months']?.toString() ?? ''),
      interestRate: json['interest_rate'] is num
          ? json['interest_rate']
          : num.tryParse(json['interest_rate']?.toString() ?? ''),
      rtoCharges: json['rto_charges'] is num
          ? json['rto_charges']
          : num.tryParse(json['rto_charges']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bankName != null) 'bank_name': bankName,
      if (bankEmployeeName != null) 'bank_employee_name': bankEmployeeName,
      if (loginDate != null) 'login_date': loginDate,
      if (loanApplicationNumber != null)
        'loan_application_number': loanApplicationNumber,
      if (sanctionedAmount != null) 'sanctioned_amount': sanctionedAmount,
      if (sanctionDate != null) 'sanction_date': sanctionDate,
      if (disbursedAmount != null) 'disbursed_amount': disbursedAmount,
      if (disbursementDate != null) 'disbursement_date': disbursementDate,
      if (netDisbursableAmount != null)
        'net_disbursable_amount': netDisbursableAmount,
      if (emi != null) 'emi': emi,
      if (tenureMonths != null) 'tenure_months': tenureMonths,
      if (interestRate != null) 'interest_rate': interestRate,
      if (rtoCharges != null) 'rto_charges': rtoCharges,
    };
  }
}

class ApplicantCharges {
  final num? insuranceAmount;
  final String? insurancePaymentType;
  final num? processingFees;
  final String? processingFeesPaymentType;
  final num? documentCharges;
  final String? documentChargesPaymentType;
  final num? otherCharges;
  final String? otherChargesPaymentType;
  final num? totalDeductionsFromLoan;
  final num? totalUpfrontCharges;

  ApplicantCharges({
    this.insuranceAmount,
    this.insurancePaymentType,
    this.processingFees,
    this.processingFeesPaymentType,
    this.documentCharges,
    this.documentChargesPaymentType,
    this.otherCharges,
    this.otherChargesPaymentType,
    this.totalDeductionsFromLoan,
    this.totalUpfrontCharges,
  });

  factory ApplicantCharges.fromJson(Map<String, dynamic> json) {
    return ApplicantCharges(
      insuranceAmount: json['insurance_amount'] is num
          ? json['insurance_amount']
          : num.tryParse(json['insurance_amount']?.toString() ?? ''),
      insurancePaymentType: json['insurance_payment_type']?.toString(),
      processingFees: json['processing_fees'] is num
          ? json['processing_fees']
          : num.tryParse(json['processing_fees']?.toString() ?? ''),
      processingFeesPaymentType: json['processing_fees_payment_type']?.toString(),
      documentCharges: json['document_charges'] is num
          ? json['document_charges']
          : num.tryParse(json['document_charges']?.toString() ?? ''),
      documentChargesPaymentType:
          json['document_charges_payment_type']?.toString(),
      otherCharges: json['other_charges'] is num
          ? json['other_charges']
          : num.tryParse(json['other_charges']?.toString() ?? ''),
      otherChargesPaymentType: json['other_charges_payment_type']?.toString(),
      totalDeductionsFromLoan: json['total_deductions_from_loan'] is num
          ? json['total_deductions_from_loan']
          : num.tryParse(
              json['total_deductions_from_loan']?.toString() ?? ''),
      totalUpfrontCharges: json['total_upfront_charges'] is num
          ? json['total_upfront_charges']
          : num.tryParse(json['total_upfront_charges']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (insuranceAmount != null) 'insurance_amount': insuranceAmount,
      if (insurancePaymentType != null)
        'insurance_payment_type': insurancePaymentType,
      if (processingFees != null) 'processing_fees': processingFees,
      if (processingFeesPaymentType != null)
        'processing_fees_payment_type': processingFeesPaymentType,
      if (documentCharges != null) 'document_charges': documentCharges,
      if (documentChargesPaymentType != null)
        'document_charges_payment_type': documentChargesPaymentType,
      if (otherCharges != null) 'other_charges': otherCharges,
      if (otherChargesPaymentType != null)
        'other_charges_payment_type': otherChargesPaymentType,
      if (totalDeductionsFromLoan != null)
        'total_deductions_from_loan': totalDeductionsFromLoan,
      if (totalUpfrontCharges != null)
        'total_upfront_charges': totalUpfrontCharges,
    };
  }
}

class ApplicantBalanceTransfer {
  final int? isBalanceTransfer;
  final num? btAmount;
  final num? topupAmount;
  final String? btBankName;
  final num? btRoi;

  ApplicantBalanceTransfer({
    this.isBalanceTransfer,
    this.btAmount,
    this.topupAmount,
    this.btBankName,
    this.btRoi,
  });

  factory ApplicantBalanceTransfer.fromJson(Map<String, dynamic> json) {
    return ApplicantBalanceTransfer(
      isBalanceTransfer: json['is_balance_transfer'] is int
          ? json['is_balance_transfer']
          : int.tryParse(json['is_balance_transfer']?.toString() ?? ''),
      btAmount: json['bt_amount'] is num
          ? json['bt_amount']
          : num.tryParse(json['bt_amount']?.toString() ?? ''),
      topupAmount: json['topup_amount'] is num
          ? json['topup_amount']
          : num.tryParse(json['topup_amount']?.toString() ?? ''),
      btBankName: json['bt_bank_name']?.toString(),
      btRoi: json['bt_roi'] is num
          ? json['bt_roi']
          : num.tryParse(json['bt_roi']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (isBalanceTransfer != null) 'is_balance_transfer': isBalanceTransfer,
      if (btAmount != null) 'bt_amount': btAmount,
      if (topupAmount != null) 'topup_amount': topupAmount,
      if (btBankName != null) 'bt_bank_name': btBankName,
      if (btRoi != null) 'bt_roi': btRoi,
    };
  }
}

class ApplicantPropertyDetails {
  final String? propertyType;
  final String? constructionStage;
  final num? propertyValue;
  final num? areaSqft;
  final String? areaUnit;
  final num? agreementValue;
  final String? propertyLocation;

  ApplicantPropertyDetails({
    this.propertyType,
    this.constructionStage,
    this.propertyValue,
    this.areaSqft,
    this.areaUnit,
    this.agreementValue,
    this.propertyLocation,
  });

  factory ApplicantPropertyDetails.fromJson(Map<String, dynamic> json) {
    return ApplicantPropertyDetails(
      propertyType: json['property_type']?.toString(),
      constructionStage: json['construction_stage']?.toString(),
      propertyValue: json['property_value'] is num
          ? json['property_value']
          : num.tryParse(json['property_value']?.toString() ?? ''),
      areaSqft: json['area_sqft'] is num
          ? json['area_sqft']
          : num.tryParse(json['area_sqft']?.toString() ?? ''),
      areaUnit: json['area_unit']?.toString(),
      agreementValue: json['agreement_value'] is num
          ? json['agreement_value']
          : num.tryParse(json['agreement_value']?.toString() ?? ''),
      propertyLocation: json['property_location']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (propertyType != null) 'property_type': propertyType,
      if (constructionStage != null)
        'construction_stage': constructionStage,
      if (propertyValue != null) 'property_value': propertyValue,
      if (areaSqft != null) 'area_sqft': areaSqft,
      if (areaUnit != null) 'area_unit': areaUnit,
      if (agreementValue != null) 'agreement_value': agreementValue,
      if (propertyLocation != null) 'property_location': propertyLocation,
    };
  }
}

class ApplicantVehicleDetails {
  final String? vehicleCompanyName;
  final String? vehicleModel;
  final String? vehicleRegDate;
  final dynamic vehicleOwnerSerial;
  final String? vehicleClass;

  ApplicantVehicleDetails({
    this.vehicleCompanyName,
    this.vehicleModel,
    this.vehicleRegDate,
    this.vehicleOwnerSerial,
    this.vehicleClass,
  });

  factory ApplicantVehicleDetails.fromJson(Map<String, dynamic> json) {
    return ApplicantVehicleDetails(
      vehicleCompanyName: json['vehicle_company_name']?.toString(),
      vehicleModel: json['vehicle_model']?.toString(),
      vehicleRegDate: json['vehicle_reg_date']?.toString(),
      vehicleOwnerSerial: json['vehicle_owner_serial'],
      vehicleClass: json['vehicle_class']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (vehicleCompanyName != null)
        'vehicle_company_name': vehicleCompanyName,
      if (vehicleModel != null) 'vehicle_model': vehicleModel,
      if (vehicleRegDate != null) 'vehicle_reg_date': vehicleRegDate,
      if (vehicleOwnerSerial != null)
        'vehicle_owner_serial': vehicleOwnerSerial,
      if (vehicleClass != null) 'vehicle_class': vehicleClass,
    };
  }
}

class ApplicantReferenceDetails {
  final String? ref1Name;
  final String? ref1Phone;
  final String? ref1Relation;
  final String? ref1Address;
  final String? ref2Name;
  final String? ref2Phone;
  final String? ref2Relation;
  final String? ref2Address;

  ApplicantReferenceDetails({
    this.ref1Name,
    this.ref1Phone,
    this.ref1Relation,
    this.ref1Address,
    this.ref2Name,
    this.ref2Phone,
    this.ref2Relation,
    this.ref2Address,
  });

  factory ApplicantReferenceDetails.fromJson(Map<String, dynamic> json) {
    return ApplicantReferenceDetails(
      ref1Name: json['ref1_name']?.toString(),
      ref1Phone: json['ref1_phone']?.toString(),
      ref1Relation: json['ref1_relation']?.toString(),
      ref1Address: json['ref1_address']?.toString(),
      ref2Name: json['ref2_name']?.toString(),
      ref2Phone: json['ref2_phone']?.toString(),
      ref2Relation: json['ref2_relation']?.toString(),
      ref2Address: json['ref2_address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ref1Name != null) 'ref1_name': ref1Name,
      if (ref1Phone != null) 'ref1_phone': ref1Phone,
      if (ref1Relation != null) 'ref1_relation': ref1Relation,
      if (ref1Address != null) 'ref1_address': ref1Address,
      if (ref2Name != null) 'ref2_name': ref2Name,
      if (ref2Phone != null) 'ref2_phone': ref2Phone,
      if (ref2Relation != null) 'ref2_relation': ref2Relation,
      if (ref2Address != null) 'ref2_address': ref2Address,
    };
  }
}

class ApplicantObligation {
  final String? bankName;
  final String? loanType;
  final String? emiAmount;
  final String? outstandingAmount;
  final String? remainingTenure;
  final String? overdueAmount;

  ApplicantObligation({
    this.bankName,
    this.loanType,
    this.emiAmount,
    this.outstandingAmount,
    this.remainingTenure,
    this.overdueAmount,
  });

  factory ApplicantObligation.fromJson(Map<String, dynamic> json) {
    return ApplicantObligation(
      bankName: json['bank_name']?.toString(),
      loanType: json['loan_type']?.toString(),
      emiAmount: json['emi_amount']?.toString(),
      outstandingAmount: json['outstanding_amount']?.toString(),
      remainingTenure: json['remaining_tenure']?.toString(),
      overdueAmount: json['overdue_amount']?.toString(),
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

class ApplicantDocsSummary {
  final int? total;
  final int? uploaded;
  final int? rejected;

  ApplicantDocsSummary({this.total, this.uploaded, this.rejected});

  factory ApplicantDocsSummary.fromJson(Map<String, dynamic> json) {
    return ApplicantDocsSummary(
      total: json['total'] is int
          ? json['total']
          : int.tryParse(json['total']?.toString() ?? ''),
      uploaded: json['uploaded'] is int
          ? json['uploaded']
          : int.tryParse(json['uploaded']?.toString() ?? ''),
      rejected: json['rejected'] is int
          ? json['rejected']
          : int.tryParse(json['rejected']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (total != null) 'total': total,
      if (uploaded != null) 'uploaded': uploaded,
      if (rejected != null) 'rejected': rejected,
    };
  }
}

class ApplicantDocumentItem {
  final String? key;
  final String? label;
  final String? category;
  final bool? allowMultiple;
  final List<String> acceptedFormats;
  final num? maxSizeMb;
  final bool? ocrAutofill;
  final bool? uploaded;
  final String? status;
  final List<ApplicantDocFile> files;

  ApplicantDocumentItem({
    this.key,
    this.label,
    this.category,
    this.allowMultiple,
    this.acceptedFormats = const [],
    this.maxSizeMb,
    this.ocrAutofill,
    this.uploaded,
    this.status,
    this.files = const [],
  });

  factory ApplicantDocumentItem.fromJson(Map<String, dynamic> json) {
    return ApplicantDocumentItem(
      key: json['key']?.toString(),
      label: json['label']?.toString(),
      category: json['category']?.toString(),
      allowMultiple: json['allow_multiple'] is bool
          ? json['allow_multiple']
          : json['allow_multiple']?.toString() == 'true',
      acceptedFormats: json['accepted_formats'] != null && json['accepted_formats'] is List
          ? (json['accepted_formats'] as List).map((e) => e.toString()).toList()
          : const [],
      maxSizeMb: json['max_size_mb'] is num
          ? json['max_size_mb']
          : num.tryParse(json['max_size_mb']?.toString() ?? ''),
      ocrAutofill: json['ocr_autofill'] is bool
          ? json['ocr_autofill']
          : json['ocr_autofill']?.toString() == 'true',
      uploaded: json['uploaded'] is bool
          ? json['uploaded']
          : json['uploaded']?.toString() == 'true',
      status: json['status']?.toString(),
      files: json['files'] != null && json['files'] is List
          ? (json['files'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ApplicantDocFile.fromJson(e))
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (key != null) 'key': key,
      if (label != null) 'label': label,
      if (category != null) 'category': category,
      if (allowMultiple != null) 'allow_multiple': allowMultiple,
      if (acceptedFormats.isNotEmpty) 'accepted_formats': acceptedFormats,
      if (maxSizeMb != null) 'max_size_mb': maxSizeMb,
      if (ocrAutofill != null) 'ocr_autofill': ocrAutofill,
      if (uploaded != null) 'uploaded': uploaded,
      if (status != null) 'status': status,
      'files': files.map((e) => e.toJson()).toList(),
    };
  }
}

class ApplicantDocFile {
  final int? index;
  final String? name;
  final String? status;
  final String? docKey;
  final String? viewEndpoint;
  final String? url;
  final String? extension;
  final bool? isImage;
  final String? side;

  ApplicantDocFile({
    this.index,
    this.name,
    this.status,
    this.docKey,
    this.viewEndpoint,
    this.url,
    this.extension,
    this.isImage,
    this.side,
  });

  factory ApplicantDocFile.fromJson(Map<String, dynamic> json) {
    return ApplicantDocFile(
      index: json['index'] is int
          ? json['index']
          : int.tryParse(json['index']?.toString() ?? ''),
      name: json['name']?.toString(),
      status: json['status']?.toString(),
      docKey: json['doc_key']?.toString(),
      viewEndpoint: json['view_endpoint']?.toString(),
      url: json['url']?.toString(),
      extension: json['extension']?.toString(),
      isImage: json['is_image'] is bool
          ? json['is_image']
          : json['is_image']?.toString() == 'true',
      side: json['side']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (index != null) 'index': index,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (docKey != null) 'doc_key': docKey,
      if (viewEndpoint != null) 'view_endpoint': viewEndpoint,
      if (url != null) 'url': url,
      if (extension != null) 'extension': extension,
      if (isImage != null) 'is_image': isImage,
      if (side != null) 'side': side,
    };
  }
}

class ApplicantCoApplicantItem {
  final int? coApplicantId;
  final ApplicantCoAppDetails? details;
  final List<ApplicantDocumentItem> documents;
  final ApplicantDocsSummary? documentsSummary;

  ApplicantCoApplicantItem({
    this.coApplicantId,
    this.details,
    this.documents = const [],
    this.documentsSummary,
  });

  factory ApplicantCoApplicantItem.fromJson(Map<String, dynamic> json) {
    return ApplicantCoApplicantItem(
      coApplicantId: json['co_applicant_id'] is int
          ? json['co_applicant_id']
          : int.tryParse(json['co_applicant_id']?.toString() ?? ''),
      details: json['details'] != null && json['details'] is Map<String, dynamic>
          ? ApplicantCoAppDetails.fromJson(
              json['details'] as Map<String, dynamic>)
          : null,
      documents: json['documents'] != null && json['documents'] is List
          ? (json['documents'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ApplicantDocumentItem.fromJson(e))
              .toList()
          : const [],
      documentsSummary: json['documents_summary'] != null &&
              json['documents_summary'] is Map<String, dynamic>
          ? ApplicantDocsSummary.fromJson(
              json['documents_summary'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (coApplicantId != null) 'co_applicant_id': coApplicantId,
      if (details != null) 'details': details!.toJson(),
      'documents': documents.map((e) => e.toJson()).toList(),
      if (documentsSummary != null)
        'documents_summary': documentsSummary!.toJson(),
    };
  }
}

class ApplicantCoAppDetails {
  final int? id;
  final int? userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? panCardNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? relationship;
  final String? employmentType;
  final String? applicantType;
  final String? companyName;
  final num? monthlySalary;
  final String? createdAt;
  final String? updatedAt;

  ApplicantCoAppDetails({
    this.id,
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.panCardNumber,
    this.dateOfBirth,
    this.gender,
    this.relationship,
    this.employmentType,
    this.applicantType,
    this.companyName,
    this.monthlySalary,
    this.createdAt,
    this.updatedAt,
  });

  factory ApplicantCoAppDetails.fromJson(Map<String, dynamic> json) {
    return ApplicantCoAppDetails(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      panCardNumber: json['pan_card_number']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      gender: json['gender']?.toString(),
      relationship: json['relationship']?.toString(),
      employmentType: json['employment_type']?.toString(),
      applicantType: json['applicant_type']?.toString(),
      companyName: json['company_name']?.toString(),
      monthlySalary: json['monthly_salary'] is num
          ? json['monthly_salary']
          : num.tryParse(json['monthly_salary']?.toString() ?? ''),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
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
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (relationship != null) 'relationship': relationship,
      if (employmentType != null) 'employment_type': employmentType,
      if (applicantType != null) 'applicant_type': applicantType,
      if (companyName != null) 'company_name': companyName,
      if (monthlySalary != null) 'monthly_salary': monthlySalary,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }
}

class ApplicantSummary {
  final int? totalLoanApplications;
  final int? activeLoanApplications;
  final int? totalCoApplicants;
  final bool? kycCompleted;
  final int? documentsUploaded;

  ApplicantSummary({
    this.totalLoanApplications,
    this.activeLoanApplications,
    this.totalCoApplicants,
    this.kycCompleted,
    this.documentsUploaded,
  });

  factory ApplicantSummary.fromJson(Map<String, dynamic> json) {
    return ApplicantSummary(
      totalLoanApplications: json['total_loan_applications'] is int
          ? json['total_loan_applications']
          : int.tryParse(json['total_loan_applications']?.toString() ?? ''),
      activeLoanApplications: json['active_loan_applications'] is int
          ? json['active_loan_applications']
          : int.tryParse(json['active_loan_applications']?.toString() ?? ''),
      totalCoApplicants: json['total_co_applicants'] is int
          ? json['total_co_applicants']
          : int.tryParse(json['total_co_applicants']?.toString() ?? ''),
      kycCompleted: json['kyc_completed'] is bool
          ? json['kyc_completed']
          : json['kyc_completed']?.toString() == 'true',
      documentsUploaded: json['documents_uploaded'] is int
          ? json['documents_uploaded']
          : int.tryParse(json['documents_uploaded']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (totalLoanApplications != null)
        'total_loan_applications': totalLoanApplications,
      if (activeLoanApplications != null)
        'active_loan_applications': activeLoanApplications,
      if (totalCoApplicants != null)
        'total_co_applicants': totalCoApplicants,
      if (kycCompleted != null) 'kyc_completed': kycCompleted,
      if (documentsUploaded != null)
        'documents_uploaded': documentsUploaded,
    };
  }
}
