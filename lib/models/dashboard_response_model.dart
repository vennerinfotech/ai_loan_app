/// Model for GET /dashboard response
class DashboardResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final DashboardData? data;
  final dynamic errors;

  DashboardResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
    this.errors,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return DashboardResponseModel(
      success: json['success'] as bool?,
      statusCode: json['status_code'] is int
          ? json['status_code']
          : int.tryParse(json['status_code']?.toString() ?? ''),
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map
          ? DashboardData.fromJson(Map<String, dynamic>.from(json['data']))
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

class DashboardData {
  final DashboardUser? user;
  final String? greeting;
  final String? trustedBadge;
  final DashboardEmiCalculator? emiCalculator;
  final DashboardCreditScore? creditScore;
  final List<DashboardQuickAction> quickActions;
  final DashboardApplicationStatus? applicationStatus;
  final List<DashboardMainAction> mainActions;
  final DashboardAiInsights? aiInsights;

  DashboardData({
    this.user,
    this.greeting,
    this.trustedBadge,
    this.emiCalculator,
    this.creditScore,
    this.quickActions = const [],
    this.applicationStatus,
    this.mainActions = const [],
    this.aiInsights,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: json['user'] != null && json['user'] is Map
          ? DashboardUser.fromJson(Map<String, dynamic>.from(json['user']))
          : null,
      greeting: json['greeting']?.toString(),
      trustedBadge: json['trusted_badge']?.toString(),
      emiCalculator: json['emi_calculator'] != null && json['emi_calculator'] is Map
          ? DashboardEmiCalculator.fromJson(Map<String, dynamic>.from(json['emi_calculator']))
          : null,
      creditScore: json['credit_score'] != null && json['credit_score'] is Map
          ? DashboardCreditScore.fromJson(Map<String, dynamic>.from(json['credit_score']))
          : null,
      quickActions: (json['quick_actions'] as List?)
              ?.map((item) => DashboardQuickAction.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      applicationStatus: json['application_status'] != null && json['application_status'] is Map
          ? DashboardApplicationStatus.fromJson(Map<String, dynamic>.from(json['application_status']))
          : null,
      mainActions: (json['main_actions'] as List?)
              ?.map((item) => DashboardMainAction.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      aiInsights: json['ai_insights'] != null && json['ai_insights'] is Map
          ? DashboardAiInsights.fromJson(Map<String, dynamic>.from(json['ai_insights']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (user != null) 'user': user!.toJson(),
      if (greeting != null) 'greeting': greeting,
      if (trustedBadge != null) 'trusted_badge': trustedBadge,
      if (emiCalculator != null) 'emi_calculator': emiCalculator!.toJson(),
      if (creditScore != null) 'credit_score': creditScore!.toJson(),
      'quick_actions': quickActions.map((e) => e.toJson()).toList(),
      if (applicationStatus != null) 'application_status': applicationStatus!.toJson(),
      'main_actions': mainActions.map((e) => e.toJson()).toList(),
      if (aiInsights != null) 'ai_insights': aiInsights!.toJson(),
    };
  }
}

class DashboardUser {
  final int? id;
  final String? name;
  final String? firstName;
  final String? phone;
  final String? email;
  final String? profilePhotoUrl;
  final int? currentStep;

  DashboardUser({
    this.id,
    this.name,
    this.firstName,
    this.phone,
    this.email,
    this.profilePhotoUrl,
    this.currentStep,
  });

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      firstName: json['first_name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      profilePhotoUrl: json['profile_photo_url']?.toString(),
      currentStep: json['current_step'] is int
          ? json['current_step']
          : int.tryParse(json['current_step']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (firstName != null) 'first_name': firstName,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (profilePhotoUrl != null) 'profile_photo_url': profilePhotoUrl,
      if (currentStep != null) 'current_step': currentStep,
    };
  }
}

class DashboardEmiCalculator {
  final String? title;
  final String? subtitle;
  final EmiSliders? sliders;
  final EmiResult? result;
  final String? calculateEndpoint;

  DashboardEmiCalculator({
    this.title,
    this.subtitle,
    this.sliders,
    this.result,
    this.calculateEndpoint,
  });

  factory DashboardEmiCalculator.fromJson(Map<String, dynamic> json) {
    return DashboardEmiCalculator(
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      sliders: json['sliders'] != null && json['sliders'] is Map
          ? EmiSliders.fromJson(Map<String, dynamic>.from(json['sliders']))
          : null,
      result: json['result'] != null && json['result'] is Map
          ? EmiResult.fromJson(Map<String, dynamic>.from(json['result']))
          : null,
      calculateEndpoint: json['calculate_endpoint']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (sliders != null) 'sliders': sliders!.toJson(),
      if (result != null) 'result': result!.toJson(),
      if (calculateEndpoint != null) 'calculate_endpoint': calculateEndpoint,
    };
  }
}

class EmiSliders {
  final EmiSliderConfig? loanAmount;
  final EmiSliderConfig? interestRate;
  final EmiSliderConfig? tenureMonths;

  EmiSliders({
    this.loanAmount,
    this.interestRate,
    this.tenureMonths,
  });

  factory EmiSliders.fromJson(Map<String, dynamic> json) {
    return EmiSliders(
      loanAmount: json['loan_amount'] != null && json['loan_amount'] is Map
          ? EmiSliderConfig.fromJson(Map<String, dynamic>.from(json['loan_amount']))
          : null,
      interestRate: json['interest_rate'] != null && json['interest_rate'] is Map
          ? EmiSliderConfig.fromJson(Map<String, dynamic>.from(json['interest_rate']))
          : null,
      tenureMonths: json['tenure_months'] != null && json['tenure_months'] is Map
          ? EmiSliderConfig.fromJson(Map<String, dynamic>.from(json['tenure_months']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (loanAmount != null) 'loan_amount': loanAmount!.toJson(),
      if (interestRate != null) 'interest_rate': interestRate!.toJson(),
      if (tenureMonths != null) 'tenure_months': tenureMonths!.toJson(),
    };
  }
}

class EmiSliderConfig {
  final num? min;
  final num? max;
  final num? step;
  final num? defaultValue;

  EmiSliderConfig({
    this.min,
    this.max,
    this.step,
    this.defaultValue,
  });

  factory EmiSliderConfig.fromJson(Map<String, dynamic> json) {
    return EmiSliderConfig(
      min: json['min'] is num ? json['min'] : num.tryParse(json['min']?.toString() ?? ''),
      max: json['max'] is num ? json['max'] : num.tryParse(json['max']?.toString() ?? ''),
      step: json['step'] is num ? json['step'] : num.tryParse(json['step']?.toString() ?? ''),
      defaultValue: json['default'] is num
          ? json['default']
          : num.tryParse(json['default']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (min != null) 'min': min,
      if (max != null) 'max': max,
      if (step != null) 'step': step,
      if (defaultValue != null) 'default': defaultValue,
    };
  }
}

class EmiResult {
  final num? loanAmount;
  final num? interestRate;
  final int? tenureMonths;
  final num? monthlyEmi;
  final num? totalInterest;
  final num? totalPayable;
  final num? principalPercent;
  final num? interestPercent;

  EmiResult({
    this.loanAmount,
    this.interestRate,
    this.tenureMonths,
    this.monthlyEmi,
    this.totalInterest,
    this.totalPayable,
    this.principalPercent,
    this.interestPercent,
  });

  factory EmiResult.fromJson(Map<String, dynamic> json) {
    return EmiResult(
      loanAmount: json['loan_amount'] is num
          ? json['loan_amount']
          : num.tryParse(json['loan_amount']?.toString() ?? ''),
      interestRate: json['interest_rate'] is num
          ? json['interest_rate']
          : num.tryParse(json['interest_rate']?.toString() ?? ''),
      tenureMonths: json['tenure_months'] is int
          ? json['tenure_months']
          : int.tryParse(json['tenure_months']?.toString() ?? ''),
      monthlyEmi: json['monthly_emi'] is num
          ? json['monthly_emi']
          : num.tryParse(json['monthly_emi']?.toString() ?? ''),
      totalInterest: json['total_interest'] is num
          ? json['total_interest']
          : num.tryParse(json['total_interest']?.toString() ?? ''),
      totalPayable: json['total_payable'] is num
          ? json['total_payable']
          : num.tryParse(json['total_payable']?.toString() ?? ''),
      principalPercent: json['principal_percent'] is num
          ? json['principal_percent']
          : num.tryParse(json['principal_percent']?.toString() ?? ''),
      interestPercent: json['interest_percent'] is num
          ? json['interest_percent']
          : num.tryParse(json['interest_percent']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (loanAmount != null) 'loan_amount': loanAmount,
      if (interestRate != null) 'interest_rate': interestRate,
      if (tenureMonths != null) 'tenure_months': tenureMonths,
      if (monthlyEmi != null) 'monthly_emi': monthlyEmi,
      if (totalInterest != null) 'total_interest': totalInterest,
      if (totalPayable != null) 'total_payable': totalPayable,
      if (principalPercent != null) 'principal_percent': principalPercent,
      if (interestPercent != null) 'interest_percent': interestPercent,
    };
  }
}

class DashboardCreditScore {
  final bool? locked;
  final int? score;
  final int? maxScore;
  final String? band;
  final String? bandColor;
  final num? gaugePercent;
  final bool? isEstimated;
  final List<CreditScoreBand> bands;

  DashboardCreditScore({
    this.locked,
    this.score,
    this.maxScore,
    this.band,
    this.bandColor,
    this.gaugePercent,
    this.isEstimated,
    this.bands = const [],
  });

  factory DashboardCreditScore.fromJson(Map<String, dynamic> json) {
    return DashboardCreditScore(
      locked: json['locked'] as bool?,
      score: json['score'] is int
          ? json['score']
          : int.tryParse(json['score']?.toString() ?? ''),
      maxScore: json['max_score'] is int
          ? json['max_score']
          : int.tryParse(json['max_score']?.toString() ?? ''),
      band: json['band']?.toString(),
      bandColor: json['band_color']?.toString(),
      gaugePercent: json['gauge_percent'] is num
          ? json['gauge_percent']
          : num.tryParse(json['gauge_percent']?.toString() ?? ''),
      isEstimated: json['is_estimated'] as bool?,
      bands: (json['bands'] as List?)
              ?.map((item) => CreditScoreBand.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (locked != null) 'locked': locked,
      if (score != null) 'score': score,
      if (maxScore != null) 'max_score': maxScore,
      if (band != null) 'band': band,
      if (bandColor != null) 'band_color': bandColor,
      if (gaugePercent != null) 'gauge_percent': gaugePercent,
      if (isEstimated != null) 'is_estimated': isEstimated,
      'bands': bands.map((e) => e.toJson()).toList(),
    };
  }
}

class CreditScoreBand {
  final String? label;
  final int? min;
  final int? max;
  final String? color;

  CreditScoreBand({
    this.label,
    this.min,
    this.max,
    this.color,
  });

  factory CreditScoreBand.fromJson(Map<String, dynamic> json) {
    return CreditScoreBand(
      label: json['label']?.toString(),
      min: json['min'] is int ? json['min'] : int.tryParse(json['min']?.toString() ?? ''),
      max: json['max'] is int ? json['max'] : int.tryParse(json['max']?.toString() ?? ''),
      color: json['color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (label != null) 'label': label,
      if (min != null) 'min': min,
      if (max != null) 'max': max,
      if (color != null) 'color': color,
    };
  }
}

class DashboardQuickAction {
  final String? key;
  final String? title;
  final String? icon;
  final String? screen;
  final String? endpoint;

  DashboardQuickAction({
    this.key,
    this.title,
    this.icon,
    this.screen,
    this.endpoint,
  });

  factory DashboardQuickAction.fromJson(Map<String, dynamic> json) {
    return DashboardQuickAction(
      key: json['key']?.toString(),
      title: json['title']?.toString(),
      icon: json['icon']?.toString(),
      screen: json['screen']?.toString(),
      endpoint: json['endpoint']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (icon != null) 'icon': icon,
      if (screen != null) 'screen': screen,
      if (endpoint != null) 'endpoint': endpoint,
    };
  }
}

class DashboardApplicationStatus {
  final int? currentStep;
  final num? progressPercent;
  final bool? isSubmitted;
  final bool? hasCoApplicant;
  final String? coApplicantStatus;
  final String? activeStep;
  final List<ApplicationStep> steps;
  final ApplicationNextAction? nextAction;
  final dynamic latestLead;

  DashboardApplicationStatus({
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

  factory DashboardApplicationStatus.fromJson(Map<String, dynamic> json) {
    return DashboardApplicationStatus(
      currentStep: json['current_step'] is int
          ? json['current_step']
          : int.tryParse(json['current_step']?.toString() ?? ''),
      progressPercent: json['progress_percent'] is num
          ? json['progress_percent']
          : num.tryParse(json['progress_percent']?.toString() ?? ''),
      isSubmitted: json['is_submitted'] as bool?,
      hasCoApplicant: json['has_co_applicant'] as bool?,
      coApplicantStatus: json['co_applicant_status']?.toString(),
      activeStep: json['active_step']?.toString(),
      steps: (json['steps'] as List?)
              ?.map((item) => ApplicationStep.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
      nextAction: json['next_action'] != null && json['next_action'] is Map
          ? ApplicationNextAction.fromJson(Map<String, dynamic>.from(json['next_action']))
          : null,
      latestLead: json['latest_lead'],
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
      if (latestLead != null) 'latest_lead': latestLead,
    };
  }
}

class ApplicationStep {
  final String? key;
  final String? title;
  final String? icon;
  final String? status;
  final bool? isCompleted;
  final int? stepNumber;
  final String? stepLabel;

  ApplicationStep({
    this.key,
    this.title,
    this.icon,
    this.status,
    this.isCompleted,
    this.stepNumber,
    this.stepLabel,
  });

  factory ApplicationStep.fromJson(Map<String, dynamic> json) {
    return ApplicationStep(
      key: json['key']?.toString(),
      title: json['title']?.toString(),
      icon: json['icon']?.toString(),
      status: json['status']?.toString(),
      isCompleted: json['is_completed'] as bool?,
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

class ApplicationNextAction {
  final String? screen;
  final String? label;
  final String? endpoint;

  ApplicationNextAction({
    this.screen,
    this.label,
    this.endpoint,
  });

  factory ApplicationNextAction.fromJson(Map<String, dynamic> json) {
    return ApplicationNextAction(
      screen: json['screen']?.toString(),
      label: json['label']?.toString(),
      endpoint: json['endpoint']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (screen != null) 'screen': screen,
      if (label != null) 'label': label,
      if (endpoint != null) 'endpoint': endpoint,
    };
  }
}

class DashboardMainAction {
  final String? key;
  final String? title;
  final String? description;
  final String? color;
  final String? screen;
  final String? endpoint;

  DashboardMainAction({
    this.key,
    this.title,
    this.description,
    this.color,
    this.screen,
    this.endpoint,
  });

  factory DashboardMainAction.fromJson(Map<String, dynamic> json) {
    return DashboardMainAction(
      key: json['key']?.toString(),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      color: json['color']?.toString(),
      screen: json['screen']?.toString(),
      endpoint: json['endpoint']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (screen != null) 'screen': screen,
      if (endpoint != null) 'endpoint': endpoint,
    };
  }
}

class DashboardAiInsights {
  final RecommendationItem? recommendation;
  final List<DocumentVerificationItem> documentVerification;
  final Map<String, dynamic>? rawDocumentVerification;

  DashboardAiInsights({
    this.recommendation,
    this.documentVerification = const [],
    this.rawDocumentVerification,
  });

  factory DashboardAiInsights.fromJson(Map<String, dynamic> json) {
    List<DocumentVerificationItem> verifList = [];
    Map<String, dynamic>? rawMap;

    if (json['document_verification'] is List) {
      verifList = (json['document_verification'] as List)
          .map((item) => DocumentVerificationItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else if (json['document_verification'] is Map) {
      rawMap = Map<String, dynamic>.from(json['document_verification']);
      rawMap.forEach((key, val) {
        if (val is String) {
          verifList.add(DocumentVerificationItem(key: key, status: val));
        } else if (val is Map) {
          verifList.add(DocumentVerificationItem.fromJson(Map<String, dynamic>.from(val)));
        }
      });
    }

    return DashboardAiInsights(
      recommendation: json['recommendation'] != null && json['recommendation'] is Map
          ? RecommendationItem.fromJson(Map<String, dynamic>.from(json['recommendation']))
          : null,
      documentVerification: verifList,
      rawDocumentVerification: rawMap,
    );
  }

  /// Gets verification status for key (e.g. 'aadhaar', 'pan')
  String? getVerificationStatus(String docKey) {
    for (final item in documentVerification) {
      if (item.key?.toLowerCase() == docKey.toLowerCase()) {
        return item.status;
      }
    }
    if (rawDocumentVerification != null) {
      final val = rawDocumentVerification![docKey];
      if (val is String) return val;
      if (val is Map && val['status'] != null) return val['status'].toString();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (recommendation != null) 'recommendation': recommendation!.toJson(),
      'document_verification': documentVerification.map((e) => e.toJson()).toList(),
    };
  }
}

class RecommendationItem {
  final String? title;
  final String? subtitle;
  final String? message;

  RecommendationItem({
    this.title,
    this.subtitle,
    this.message,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (message != null) 'message': message,
    };
  }
}

class DocumentVerificationItem {
  final String? key;
  final String? title;
  final String? status;

  DocumentVerificationItem({
    this.key,
    this.title,
    this.status,
  });

  factory DocumentVerificationItem.fromJson(Map<String, dynamic> json) {
    return DocumentVerificationItem(
      key: json['key']?.toString(),
      title: json['title']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
    };
  }
}
