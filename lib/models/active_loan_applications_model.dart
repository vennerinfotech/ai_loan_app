import 'applicant_detail_model.dart';

/// Model representing the response data for GET {{base_url}}/loan-applications/active.
/// Designed cleanly for application consumption without storing success, status_code, message, or errors.
class ActiveLoanApplicationsResponseData {
  final List<ApplicantLoanApplication> loanApplications;
  final List<ActiveStatusItem> activeStatuses;
  final ActiveApplicationsPagination? pagination;

  ActiveLoanApplicationsResponseData({
    this.loanApplications = const [],
    this.activeStatuses = const [],
    this.pagination,
  });

  factory ActiveLoanApplicationsResponseData.fromJson(Map<String, dynamic> json) {
    // Unwrap 'data' if response wrapper is passed
    final Map<String, dynamic> data =
        (json['data'] != null && json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;

    return ActiveLoanApplicationsResponseData(
      loanApplications: data['loan_applications'] != null &&
              data['loan_applications'] is List
          ? (data['loan_applications'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ApplicantLoanApplication.fromJson(e))
              .toList()
          : const [],
      activeStatuses: data['active_statuses'] != null &&
              data['active_statuses'] is List
          ? (data['active_statuses'] as List)
              .whereType<Map<String, dynamic>>()
              .map((e) => ActiveStatusItem.fromJson(e))
              .toList()
          : const [],
      pagination: data['pagination'] != null &&
              data['pagination'] is Map<String, dynamic>
          ? ActiveApplicationsPagination.fromJson(
              data['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loan_applications': loanApplications.map((e) => e.toJson()).toList(),
      'active_statuses': activeStatuses.map((e) => e.toJson()).toList(),
      if (pagination != null) 'pagination': pagination!.toJson(),
    };
  }
}

class ActiveStatusItem {
  final String? key;
  final String? label;

  ActiveStatusItem({this.key, this.label});

  factory ActiveStatusItem.fromJson(Map<String, dynamic> json) {
    return ActiveStatusItem(
      key: json['key']?.toString(),
      label: json['label']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (key != null) 'key': key,
        if (label != null) 'label': label,
      };
}

class ActiveApplicationsPagination {
  final int? currentPage;
  final int? perPage;
  final int? total;
  final int? lastPage;
  final bool? hasMorePages;

  ActiveApplicationsPagination({
    this.currentPage,
    this.perPage,
    this.total,
    this.lastPage,
    this.hasMorePages,
  });

  factory ActiveApplicationsPagination.fromJson(Map<String, dynamic> json) {
    return ActiveApplicationsPagination(
      currentPage: json['current_page'] is int
          ? json['current_page']
          : int.tryParse(json['current_page']?.toString() ?? ''),
      perPage: json['per_page'] is int
          ? json['per_page']
          : int.tryParse(json['per_page']?.toString() ?? ''),
      total: json['total'] is int
          ? json['total']
          : int.tryParse(json['total']?.toString() ?? ''),
      lastPage: json['last_page'] is int
          ? json['last_page']
          : int.tryParse(json['last_page']?.toString() ?? ''),
      hasMorePages: json['has_more_pages'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (currentPage != null) 'current_page': currentPage,
        if (perPage != null) 'per_page': perPage,
        if (total != null) 'total': total,
        if (lastPage != null) 'last_page': lastPage,
        if (hasMorePages != null) 'has_more_pages': hasMorePages,
      };
}
