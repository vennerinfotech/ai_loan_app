// Model for POST /leads/store
import 'employment_type_model.dart';

class LeadStoreResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final LeadStoreData? data;
  final dynamic errors;

  LeadStoreResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
    this.errors,
  });

  factory LeadStoreResponseModel.fromJson(Map<String, dynamic> json) {
    return LeadStoreResponseModel(
      success: json['success'] as bool?,
      statusCode: json['status_code'] is int
          ? json['status_code']
          : int.tryParse(json['status_code']?.toString() ?? ''),
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map
          ? LeadStoreData.fromJson(Map<String, dynamic>.from(json['data']))
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

class LeadStoreData {
  final dynamic leadId;
  final String? status;
  final int? currentStep;
  final String? employmentType;
  final List<LoanDocumentItem> documents;

  LeadStoreData({
    this.leadId,
    this.status,
    this.currentStep,
    this.employmentType,
    this.documents = const [],
  });

  factory LeadStoreData.fromJson(Map<String, dynamic> json) {
    return LeadStoreData(
      leadId: json['lead_id'],
      status: json['status']?.toString(),
      currentStep: json['current_step'] is int
          ? json['current_step']
          : int.tryParse(json['current_step']?.toString() ?? ''),
      employmentType: json['employment_type']?.toString(),
      documents: (json['documents'] as List?)
              ?.map((item) => LoanDocumentItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (leadId != null) 'lead_id': leadId,
      if (status != null) 'status': status,
      if (currentStep != null) 'current_step': currentStep,
      if (employmentType != null) 'employment_type': employmentType,
      'documents': documents.map((e) => e.toJson()).toList(),
    };
  }
}
