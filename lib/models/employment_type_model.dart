// Models for GET /loan/employment-types and POST /loan/employment-type

class EmploymentTypesResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final EmploymentTypesData? data;
  final dynamic errors;

  EmploymentTypesResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
    this.errors,
  });

  factory EmploymentTypesResponseModel.fromJson(Map<String, dynamic> json) {
    return EmploymentTypesResponseModel(
      success: json['success'] as bool?,
      statusCode: json['status_code'] is int
          ? json['status_code']
          : int.tryParse(json['status_code']?.toString() ?? ''),
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map
          ? EmploymentTypesData.fromJson(Map<String, dynamic>.from(json['data']))
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

class EmploymentTypesData {
  final String? title;
  final List<EmploymentTypeItem> employmentTypes;

  EmploymentTypesData({
    this.title,
    this.employmentTypes = const [],
  });

  factory EmploymentTypesData.fromJson(Map<String, dynamic> json) {
    return EmploymentTypesData(
      title: json['title']?.toString(),
      employmentTypes: (json['employment_types'] as List?)
              ?.map((item) => EmploymentTypeItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      'employment_types': employmentTypes.map((e) => e.toJson()).toList(),
    };
  }
}

class EmploymentTypeItem {
  final String? key;
  final String? label;
  final String? icon;
  final String? description;
  final List<DetailFieldItem> detailFields;
  final List<SalaryModeItem> salaryModes;

  EmploymentTypeItem({
    this.key,
    this.label,
    this.icon,
    this.description,
    this.detailFields = const [],
    this.salaryModes = const [],
  });

  factory EmploymentTypeItem.fromJson(Map<String, dynamic> json) {
    return EmploymentTypeItem(
      key: json['key']?.toString(),
      label: json['label']?.toString(),
      icon: json['icon']?.toString(),
      description: json['description']?.toString(),
      detailFields: (json['detail_fields'] as List?)
              ?.map((item) => DetailFieldItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      salaryModes: (json['salary_modes'] as List?)
              ?.map((item) => SalaryModeItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (key != null) 'key': key,
      if (label != null) 'label': label,
      if (icon != null) 'icon': icon,
      if (description != null) 'description': description,
      'detail_fields': detailFields.map((e) => e.toJson()).toList(),
      'salary_modes': salaryModes.map((e) => e.toJson()).toList(),
    };
  }
}

class DetailFieldItem {
  final String? name;
  final String? label;
  final String? type;
  final bool? required;
  final List<String> options;

  DetailFieldItem({
    this.name,
    this.label,
    this.type,
    this.required,
    this.options = const [],
  });

  factory DetailFieldItem.fromJson(Map<String, dynamic> json) {
    return DetailFieldItem(
      name: json['name']?.toString(),
      label: json['label']?.toString(),
      type: json['type']?.toString(),
      required: json['required'] as bool?,
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
      if (options.isNotEmpty) 'options': options,
    };
  }
}

class SalaryModeItem {
  final String? key;
  final String? label;
  final List<String> requires;

  SalaryModeItem({
    this.key,
    this.label,
    this.requires = const [],
  });

  factory SalaryModeItem.fromJson(Map<String, dynamic> json) {
    return SalaryModeItem(
      key: json['key']?.toString(),
      label: json['label']?.toString(),
      requires: (json['requires'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (key != null) 'key': key,
      if (label != null) 'label': label,
      if (requires.isNotEmpty) 'requires': requires,
    };
  }
}

/// Model for POST /loan/employment-type response
class EmploymentTypeSelectionResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final EmploymentTypeSelectionData? data;
  final dynamic errors;

  EmploymentTypeSelectionResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
    this.errors,
  });

  factory EmploymentTypeSelectionResponseModel.fromJson(Map<String, dynamic> json) {
    return EmploymentTypeSelectionResponseModel(
      success: json['success'] as bool?,
      statusCode: json['status_code'] is int
          ? json['status_code']
          : int.tryParse(json['status_code']?.toString() ?? ''),
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map
          ? EmploymentTypeSelectionData.fromJson(Map<String, dynamic>.from(json['data']))
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

class EmploymentTypeSelectionData {
  final String? employmentType;
  final String? loanType;
  final num? loanAmount;
  final dynamic leadId;
  final String? title;
  final List<LoanDocumentItem> documents;
  final Map<String, dynamic>? summary;
  final Map<String, dynamic>? submit;

  EmploymentTypeSelectionData({
    this.employmentType,
    this.loanType,
    this.loanAmount,
    this.leadId,
    this.title,
    this.documents = const [],
    this.summary,
    this.submit,
  });

  factory EmploymentTypeSelectionData.fromJson(Map<String, dynamic> json) {
    return EmploymentTypeSelectionData(
      employmentType: json['employment_type']?.toString(),
      loanType: json['loan_type']?.toString(),
      loanAmount: json['loan_amount'] is num
          ? json['loan_amount']
          : num.tryParse(json['loan_amount']?.toString() ?? ''),
      leadId: json['lead_id'],
      title: json['title']?.toString(),
      documents: (json['documents'] as List?)
              ?.map((item) => LoanDocumentItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      summary: json['summary'] != null && json['summary'] is Map
          ? Map<String, dynamic>.from(json['summary'])
          : null,
      submit: json['submit'] != null && json['submit'] is Map
          ? Map<String, dynamic>.from(json['submit'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (employmentType != null) 'employment_type': employmentType,
      if (loanType != null) 'loan_type': loanType,
      if (loanAmount != null) 'loan_amount': loanAmount,
      if (leadId != null) 'lead_id': leadId,
      if (title != null) 'title': title,
      'documents': documents.map((e) => e.toJson()).toList(),
      if (summary != null) 'summary': summary,
      if (submit != null) 'submit': submit,
    };
  }
}

class LoanDocumentItem {
  final String? key;
  final String? label;
  final String? category;
  final bool? allowMultiple;
  final bool? ocrAutofill;
  final List<String> acceptedFormats;
  final int? maxSizeMb;
  final DocumentUploadConfig? upload;
  final bool? uploaded;
  final String? status;
  final List<dynamic> files;
  final List<UploadModeItem> uploadModes;

  LoanDocumentItem({
    this.key,
    this.label,
    this.category,
    this.allowMultiple,
    this.ocrAutofill,
    this.acceptedFormats = const [],
    this.maxSizeMb,
    this.upload,
    this.uploaded,
    this.status,
    this.files = const [],
    this.uploadModes = const [],
  });

  factory LoanDocumentItem.fromJson(Map<String, dynamic> json) {
    return LoanDocumentItem(
      key: json['key']?.toString(),
      label: json['label']?.toString(),
      category: json['category']?.toString(),
      allowMultiple: json['allow_multiple'] as bool?,
      ocrAutofill: json['ocr_autofill'] as bool?,
      acceptedFormats: (json['accepted_formats'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      maxSizeMb: json['max_size_mb'] is int
          ? json['max_size_mb']
          : int.tryParse(json['max_size_mb']?.toString() ?? ''),
      upload: json['upload'] != null && json['upload'] is Map
          ? DocumentUploadConfig.fromJson(Map<String, dynamic>.from(json['upload']))
          : null,
      uploaded: json['uploaded'] as bool?,
      status: json['status']?.toString(),
      files: (json['files'] as List?) ?? [],
      uploadModes: (json['upload_modes'] as List?)
              ?.map((item) => UploadModeItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (key != null) 'key': key,
      if (label != null) 'label': label,
      if (category != null) 'category': category,
      if (allowMultiple != null) 'allow_multiple': allowMultiple,
      if (ocrAutofill != null) 'ocr_autofill': ocrAutofill,
      if (acceptedFormats.isNotEmpty) 'accepted_formats': acceptedFormats,
      if (maxSizeMb != null) 'max_size_mb': maxSizeMb,
      if (upload != null) 'upload': upload!.toJson(),
      if (uploaded != null) 'uploaded': uploaded,
      if (status != null) 'status': status,
      'files': files,
      if (uploadModes.isNotEmpty)
        'upload_modes': uploadModes.map((e) => e.toJson()).toList(),
    };
  }
}

class DocumentUploadConfig {
  final String? method;
  final String? endpoint;
  final String? field;
  final String? docKey;
  final String? leadStoreField;

  DocumentUploadConfig({
    this.method,
    this.endpoint,
    this.field,
    this.docKey,
    this.leadStoreField,
  });

  factory DocumentUploadConfig.fromJson(Map<String, dynamic> json) {
    return DocumentUploadConfig(
      method: json['method']?.toString(),
      endpoint: json['endpoint']?.toString(),
      field: json['field']?.toString(),
      docKey: json['doc_key']?.toString(),
      leadStoreField: json['lead_store_field']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (method != null) 'method': method,
      if (endpoint != null) 'endpoint': endpoint,
      if (field != null) 'field': field,
      if (docKey != null) 'doc_key': docKey,
      if (leadStoreField != null) 'lead_store_field': leadStoreField,
    };
  }
}

class UploadModeItem {
  final String? key;
  final String? label;
  final List<String> fields;

  UploadModeItem({
    this.key,
    this.label,
    this.fields = const [],
  });

  factory UploadModeItem.fromJson(Map<String, dynamic> json) {
    return UploadModeItem(
      key: json['key']?.toString(),
      label: json['label']?.toString(),
      fields: (json['fields'] as List?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (key != null) 'key': key,
      if (label != null) 'label': label,
      if (fields.isNotEmpty) 'fields': fields,
    };
  }
}
