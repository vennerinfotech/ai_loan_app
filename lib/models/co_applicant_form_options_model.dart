// Co-Applicant Form Options API Response Model
// Endpoint: GET {{baseUrl}}/co-applicants/form-options

import 'add_co_applicant_model.dart';

class CoApplicantFormOptionsResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final CoApplicantFormOptionsData? data;
  final dynamic errors;

  CoApplicantFormOptionsResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
    this.errors,
  });

  factory CoApplicantFormOptionsResponseModel.fromJson(Map<String, dynamic> json) {
    return CoApplicantFormOptionsResponseModel(
      success: json['success'] as bool?,
      statusCode: json['status_code'] as int?,
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? CoApplicantFormOptionsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'],
    );
  }
}

class CoApplicantFormOptionsData {
  final List<CoApplicantFormField> addForm;
  final List<CoApplicantDetailSection> detailSections;
  final CoApplicantDocumentsConfig? documents;

  CoApplicantFormOptionsData({
    this.addForm = const [],
    this.detailSections = const [],
    this.documents,
  });

  factory CoApplicantFormOptionsData.fromJson(Map<String, dynamic> json) {
    return CoApplicantFormOptionsData(
      addForm: (json['add_form'] as List<dynamic>?)
              ?.map((e) => CoApplicantFormField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      detailSections: (json['detail_sections'] as List<dynamic>?)
              ?.map((e) => CoApplicantDetailSection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      documents: json['documents'] != null && json['documents'] is Map<String, dynamic>
          ? CoApplicantDocumentsConfig.fromJson(json['documents'] as Map<String, dynamic>)
          : null,
    );
  }
}

class CoApplicantFormField {
  final String? name;
  final String? label;
  final String? type;
  final bool? required;
  final String? alias;
  final int? max;
  final String? pattern;
  final List<String> options;
  final String? defaultValue;
  final String? dependsOn;
  final Map<String, List<String>> optionsByApplicantType;

  CoApplicantFormField({
    this.name,
    this.label,
    this.type,
    this.required,
    this.alias,
    this.max,
    this.pattern,
    this.options = const [],
    this.defaultValue,
    this.dependsOn,
    this.optionsByApplicantType = const {},
  });

  factory CoApplicantFormField.fromJson(Map<String, dynamic> json) {
    final Map<String, List<String>> optionsByType = {};
    if (json['options_by_applicant_type'] != null &&
        json['options_by_applicant_type'] is Map<String, dynamic>) {
      (json['options_by_applicant_type'] as Map<String, dynamic>).forEach((key, val) {
        if (val is List) {
          optionsByType[key] = val.map((e) => e.toString()).toList();
        }
      });
    }

    return CoApplicantFormField(
      name: json['name']?.toString(),
      label: json['label']?.toString(),
      type: json['type']?.toString(),
      required: json['required'] as bool?,
      alias: json['alias']?.toString(),
      max: json['max'] is int ? json['max'] as int : int.tryParse(json['max']?.toString() ?? ''),
      pattern: json['pattern']?.toString(),
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      defaultValue: json['default']?.toString(),
      dependsOn: json['depends_on']?.toString(),
      optionsByApplicantType: optionsByType,
    );
  }
}

class CoApplicantDetailSection {
  final String? key;
  final String? title;
  final List<String> showFor;
  final List<CoApplicantDetailField> fields;

  CoApplicantDetailSection({
    this.key,
    this.title,
    this.showFor = const [],
    this.fields = const [],
  });

  factory CoApplicantDetailSection.fromJson(Map<String, dynamic> json) {
    return CoApplicantDetailSection(
      key: json['key']?.toString(),
      title: json['title']?.toString(),
      showFor: (json['show_for'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      fields: (json['fields'] as List<dynamic>?)
              ?.map((e) => CoApplicantDetailField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CoApplicantDetailField {
  final String? name;
  final String? label;
  final String? type;
  final bool? required;
  final String? alias;
  final String? pattern;
  final String? format;
  final List<String> options;
  final num? min;
  final num? max;
  final Map<String, dynamic>? showWhen;
  final List<CoApplicantDetailField> itemFields;

  CoApplicantDetailField({
    this.name,
    this.label,
    this.type,
    this.required,
    this.alias,
    this.pattern,
    this.format,
    this.options = const [],
    this.min,
    this.max,
    this.showWhen,
    this.itemFields = const [],
  });

  factory CoApplicantDetailField.fromJson(Map<String, dynamic> json) {
    return CoApplicantDetailField(
      name: json['name']?.toString(),
      label: json['label']?.toString(),
      type: json['type']?.toString(),
      required: json['required'] as bool?,
      alias: json['alias']?.toString(),
      pattern: json['pattern']?.toString(),
      format: json['format']?.toString(),
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      min: json['min'] as num?,
      max: json['max'] as num?,
      showWhen: json['show_when'] as Map<String, dynamic>?,
      itemFields: (json['item_fields'] as List<dynamic>?)
              ?.map((e) => CoApplicantDetailField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CoApplicantDocumentsConfig {
  final List<String> acceptedFormats;
  final List<String> profileImageFormats;
  final List<String> aadhaarCombinedFormats;
  final int? maxSizeMb;
  final List<String> multiFileKeys;
  final String? note;
  final String? employmentType;
  final List<CoAppDocumentItem> list;
  final Map<String, List<CoAppDocumentItem>> byEmploymentType;

  CoApplicantDocumentsConfig({
    this.acceptedFormats = const [],
    this.profileImageFormats = const [],
    this.aadhaarCombinedFormats = const [],
    this.maxSizeMb,
    this.multiFileKeys = const [],
    this.note,
    this.employmentType,
    this.list = const [],
    this.byEmploymentType = const {},
  });

  factory CoApplicantDocumentsConfig.fromJson(Map<String, dynamic> json) {
    // Parse list of documents for default / requested employment type
    final List<CoAppDocumentItem> docList = (json['list'] as List<dynamic>?)
            ?.map((e) => CoAppDocumentItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    // Parse by_employment_type mapping (Salaried, Self-Employed, Freelancer, Pensioner, Housewife, Retired, Others, etc.)
    final Map<String, List<CoAppDocumentItem>> byEmp = {};
    if (json['by_employment_type'] != null && json['by_employment_type'] is Map) {
      (json['by_employment_type'] as Map).forEach((key, val) {
        if (val is List) {
          byEmp[key.toString()] = val
              .map((e) => CoAppDocumentItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      });
    }

    return CoApplicantDocumentsConfig(
      acceptedFormats: (json['accepted_formats'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      profileImageFormats: (json['profile_image_formats'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      aadhaarCombinedFormats: (json['aadhaar_combined_formats'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      maxSizeMb: json['max_size_mb'] is int ? json['max_size_mb'] as int : int.tryParse(json['max_size_mb']?.toString() ?? ''),
      multiFileKeys: (json['multi_file_keys'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      note: json['note']?.toString(),
      employmentType: json['employment_type']?.toString(),
      list: docList,
      byEmploymentType: byEmp,
    );
  }
}
