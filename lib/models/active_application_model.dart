import 'applicant_detail_model.dart';

/// Status of an active loan application
enum ApplicationStatusType {
  inReview,
  approved,
  rejected,
  pending;

  String get label {
    switch (this) {
      case ApplicationStatusType.inReview:
        return 'In review';
      case ApplicationStatusType.approved:
        return 'Approved';
      case ApplicationStatusType.rejected:
        return 'Rejected';
      case ApplicationStatusType.pending:
        return 'Pending';
    }
  }

  static ApplicationStatusType fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'approved':
        return ApplicationStatusType.approved;
      case 'rejected':
        return ApplicationStatusType.rejected;
      case 'pending':
        return ApplicationStatusType.pending;
      case 'in review':
      case 'in_review':
      case 'inreview':
      default:
        return ApplicationStatusType.inReview;
    }
  }

  String toJson() => name;
}

/// Data model representing an active loan application with JSON serialization.
class ActiveApplicationModel {
  final String id;
  final String title;
  final String loanType;
  final String amount;
  final String tenure;
  final String emi;
  final double progress;
  final String progressPercent;
  final String currentStep;
  final ApplicationStatusType statusType;
  final String appliedDate;
  final ApplicantLoanApplication? raw;

  const ActiveApplicationModel({
    required this.id,
    required this.title,
    required this.loanType,
    required this.amount,
    required this.tenure,
    required this.emi,
    required this.progress,
    required this.progressPercent,
    required this.currentStep,
    required this.statusType,
    required this.appliedDate,
    this.raw,
  });

  /// Factory constructor to create an [ActiveApplicationModel] from API JSON.
  factory ActiveApplicationModel.fromJson(Map<String, dynamic> json) {
    final double rawProgress = (json['progress'] is num)
        ? (json['progress'] as num).toDouble()
        : double.tryParse(json['progress']?.toString() ?? '0.0') ?? 0.0;

    return ActiveApplicationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      loanType: json['loan_type']?.toString() ?? json['loanType']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      tenure: json['tenure']?.toString() ?? '',
      emi: json['emi']?.toString() ?? '',
      progress: rawProgress,
      progressPercent: json['progress_percent']?.toString() ??
          json['progressPercent']?.toString() ??
          '${(rawProgress * 100).toInt()}%',
      currentStep: json['current_step']?.toString() ??
          json['currentStep']?.toString() ??
          '',
      statusType: ApplicationStatusType.fromString(
        json['status']?.toString() ?? json['status_type']?.toString(),
      ),
      appliedDate: json['applied_date']?.toString() ??
          json['appliedDate']?.toString() ??
          '',
    );
  }

  /// Converts this [ActiveApplicationModel] instance to JSON map for API payloads.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'loan_type': loanType,
      'amount': amount,
      'tenure': tenure,
      'emi': emi,
      'progress': progress,
      'progress_percent': progressPercent,
      'current_step': currentStep,
      'status': statusType.toJson(),
      'applied_date': appliedDate,
    };
  }

  /// Creates a copy of this model with optional updated values.
  ActiveApplicationModel copyWith({
    String? id,
    String? title,
    String? loanType,
    String? amount,
    String? tenure,
    String? emi,
    double? progress,
    String? progressPercent,
    String? currentStep,
    ApplicationStatusType? statusType,
    String? appliedDate,
  }) {
    return ActiveApplicationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      loanType: loanType ?? this.loanType,
      amount: amount ?? this.amount,
      tenure: tenure ?? this.tenure,
      emi: emi ?? this.emi,
      progress: progress ?? this.progress,
      progressPercent: progressPercent ?? this.progressPercent,
      currentStep: currentStep ?? this.currentStep,
      statusType: statusType ?? this.statusType,
      appliedDate: appliedDate ?? this.appliedDate,
    );
  }
}
