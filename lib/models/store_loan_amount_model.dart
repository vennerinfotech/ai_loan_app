// Model for POST /loan/store-amount
import 'employment_type_model.dart';

class StoreLoanAmountResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final StoreLoanAmountData? data;
  final dynamic errors;

  StoreLoanAmountResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
    this.errors,
  });

  factory StoreLoanAmountResponseModel.fromJson(Map<String, dynamic> json) {
    return StoreLoanAmountResponseModel(
      success: json['success'] as bool?,
      statusCode: json['status_code'] is int
          ? json['status_code']
          : int.tryParse(json['status_code']?.toString() ?? ''),
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map
          ? StoreLoanAmountData.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (success != null) 'success': success,
      if (statusCode != null) 'status_code': statusCode,
      if (message != null) 'message': message,
      if (data != null) 'data': data!.toJson(),
      if (errors != null) 'errors': errors,
    };
  }
}

class StoreLoanAmountData {
  final num? loanAmount;
  final int? tenureMonths;
  final dynamic userId;
  final String? loanType;
  final String? employmentType;
  final String? businessEntity;
  final int? currentStep;
  final bool? isVehicleLoan;
  final bool? hasPropertyDocuments;
  final List<FormSectionItem> formSections;
  final List<DetailFieldItem> employmentDetailFields;
  final List<SalaryModeItem> salaryModes;
  final List<LoanDocumentItem> documents;
  final Map<String, dynamic>? summary;
  final Map<String, dynamic>? next;

  StoreLoanAmountData({
    this.loanAmount,
    this.tenureMonths,
    this.userId,
    this.loanType,
    this.employmentType,
    this.businessEntity,
    this.currentStep,
    this.isVehicleLoan,
    this.hasPropertyDocuments,
    this.formSections = const [],
    this.employmentDetailFields = const [],
    this.salaryModes = const [],
    this.documents = const [],
    this.summary,
    this.next,
  });

  factory StoreLoanAmountData.fromJson(Map<String, dynamic> json) {
    return StoreLoanAmountData(
      loanAmount: json['loan_amount'] is num
          ? json['loan_amount']
          : num.tryParse(json['loan_amount']?.toString() ?? ''),
      tenureMonths: json['tenure_months'] is int
          ? json['tenure_months']
          : int.tryParse(json['tenure_months']?.toString() ?? ''),
      userId: json['user_id'],
      loanType: json['loan_type']?.toString(),
      employmentType: json['employment_type']?.toString(),
      businessEntity: json['business_entity']?.toString(),
      currentStep: json['current_step'] is int
          ? json['current_step']
          : int.tryParse(json['current_step']?.toString() ?? ''),
      isVehicleLoan: json['is_vehicle_loan'] is bool
          ? json['is_vehicle_loan']
          : (json['is_vehicle_loan']?.toString() == 'true' || json['is_vehicle_loan'] == 1),
      hasPropertyDocuments: json['has_property_documents'] is bool
          ? json['has_property_documents']
          : (json['has_property_documents']?.toString() == 'true' || json['has_property_documents'] == 1),
      formSections: (json['form_sections'] as List?)
              ?.map((item) => FormSectionItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      employmentDetailFields: (json['employment_detail_fields'] as List?)
              ?.map((item) => DetailFieldItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      salaryModes: (json['salary_modes'] as List?)
              ?.map((item) => SalaryModeItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      documents: (json['documents'] as List?)
              ?.map((item) => LoanDocumentItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      summary: json['summary'] != null && json['summary'] is Map
          ? Map<String, dynamic>.from(json['summary'])
          : null,
      next: json['next'] != null && json['next'] is Map
          ? Map<String, dynamic>.from(json['next'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (loanAmount != null) 'loan_amount': loanAmount,
      if (tenureMonths != null) 'tenure_months': tenureMonths,
      if (userId != null) 'user_id': userId,
      if (loanType != null) 'loan_type': loanType,
      if (employmentType != null) 'employment_type': employmentType,
      if (businessEntity != null) 'business_entity': businessEntity,
      if (currentStep != null) 'current_step': currentStep,
      if (isVehicleLoan != null) 'is_vehicle_loan': isVehicleLoan,
      if (hasPropertyDocuments != null) 'has_property_documents': hasPropertyDocuments,
      'form_sections': formSections.map((e) => e.toJson()).toList(),
      'employment_detail_fields': employmentDetailFields.map((e) => e.toJson()).toList(),
      'salary_modes': salaryModes.map((e) => e.toJson()).toList(),
      'documents': documents.map((e) => e.toJson()).toList(),
      if (summary != null) 'summary': summary,
      if (next != null) 'next': next,
    };
  }
}

class FormSectionItem {
  final String? key;
  final String? title;
  final List<FormFieldItem> fields;

  FormSectionItem({
    this.key,
    this.title,
    this.fields = const [],
  });

  factory FormSectionItem.fromJson(Map<String, dynamic> json) {
    return FormSectionItem(
      key: json['key']?.toString(),
      title: json['title']?.toString(),
      fields: (json['fields'] as List?)
              ?.map((item) => FormFieldItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      'fields': fields.map((e) => e.toJson()).toList(),
    };
  }
}

class FormFieldItem {
  final String? name;
  final String? label;
  final String? type;
  final bool? required;
  final String? pattern;
  final List<String> options;

  FormFieldItem({
    this.name,
    this.label,
    this.type,
    this.required,
    this.pattern,
    this.options = const [],
  });

  factory FormFieldItem.fromJson(Map<String, dynamic> json) {
    return FormFieldItem(
      name: json['name']?.toString(),
      label: json['label']?.toString(),
      type: json['type']?.toString(),
      required: json['required'] as bool?,
      pattern: json['pattern']?.toString(),
      options: (json['options'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (label != null) 'label': label,
      if (type != null) 'type': type,
      if (required != null) 'required': required,
      if (pattern != null) 'pattern': pattern,
      if (options.isNotEmpty) 'options': options,
    };
  }
}
