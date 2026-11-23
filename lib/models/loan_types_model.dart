/// Model representing the `data` payload of GET {{base_url}}/loan/types.
/// Stores only the data object (not top-level status_code, success, or message).
class LoanTypesData {
  final String? title;
  final String? subtitle;
  final bool? kycComplete;
  final dynamic kycPending;
  final List<int> amountPresets;
  final AmountLimits? amountLimits;
  final TenureLimits? tenureLimits;
  final String? selectedLoanType;
  final List<LoanTypeItem> loanTypes;

  LoanTypesData({
    this.title,
    this.subtitle,
    this.kycComplete,
    this.kycPending,
    this.amountPresets = const [],
    this.amountLimits,
    this.tenureLimits,
    this.selectedLoanType,
    this.loanTypes = const [],
  });

  factory LoanTypesData.fromJson(Map<String, dynamic> json) {
    return LoanTypesData(
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      kycComplete: json['kyc_complete'] is bool
          ? json['kyc_complete']
          : (json['kyc_complete']?.toString() == 'true' ||
              json['kyc_complete'] == 1),
      kycPending: json['kyc_pending'],
      amountPresets: (json['amount_presets'] as List?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .where((e) => e > 0)
              .toList() ??
          const [],
      amountLimits: json['amount_limits'] != null && json['amount_limits'] is Map
          ? AmountLimits.fromJson(
              Map<String, dynamic>.from(json['amount_limits']))
          : null,
      tenureLimits: json['tenure_limits'] != null && json['tenure_limits'] is Map
          ? TenureLimits.fromJson(
              Map<String, dynamic>.from(json['tenure_limits']))
          : null,
      selectedLoanType: json['selected_loan_type']?.toString(),
      loanTypes: (json['loan_types'] as List?)
              ?.map((e) => LoanTypeItem.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (kycComplete != null) 'kyc_complete': kycComplete,
      if (kycPending != null) 'kyc_pending': kycPending,
      'amount_presets': amountPresets,
      if (amountLimits != null) 'amount_limits': amountLimits!.toJson(),
      if (tenureLimits != null) 'tenure_limits': tenureLimits!.toJson(),
      if (selectedLoanType != null) 'selected_loan_type': selectedLoanType,
      'loan_types': loanTypes.map((e) => e.toJson()).toList(),
    };
  }
}

/// Dynamic min & max limits for loan amount
class AmountLimits {
  final num? min;
  final num? max;

  AmountLimits({this.min, this.max});

  factory AmountLimits.fromJson(Map<String, dynamic> json) {
    return AmountLimits(
      min: json['min'] is num
          ? json['min']
          : num.tryParse(json['min']?.toString() ?? ''),
      max: json['max'] is num
          ? json['max']
          : num.tryParse(json['max']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (min != null) 'min': min,
      if (max != null) 'max': max,
    };
  }
}

/// Dynamic tenure limits in months
class TenureLimits {
  final int? min;
  final int? max;
  final int? defaultTenure;

  TenureLimits({this.min, this.max, this.defaultTenure});

  factory TenureLimits.fromJson(Map<String, dynamic> json) {
    return TenureLimits(
      min: json['min'] is int
          ? json['min']
          : int.tryParse(json['min']?.toString() ?? ''),
      max: json['max'] is int
          ? json['max']
          : int.tryParse(json['max']?.toString() ?? ''),
      defaultTenure: json['default'] is int
          ? json['default']
          : int.tryParse(json['default']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (min != null) 'min': min,
      if (max != null) 'max': max,
      if (defaultTenure != null) 'default': defaultTenure,
    };
  }
}

/// Item representing a single loan type option in the list
class LoanTypeItem {
  final String? value;
  final String? icon;
  final String? description;
  final List<String> features;
  final String? label;
  final bool? isVehicleLoan;
  final bool? hasPropertyDocuments;

  LoanTypeItem({
    this.value,
    this.icon,
    this.description,
    this.features = const [],
    this.label,
    this.isVehicleLoan,
    this.hasPropertyDocuments,
  });

  factory LoanTypeItem.fromJson(Map<String, dynamic> json) {
    return LoanTypeItem(
      value: json['value']?.toString(),
      icon: json['icon']?.toString(),
      description: json['description']?.toString(),
      features: (json['features'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      label: json['label']?.toString(),
      isVehicleLoan: json['is_vehicle_loan'] is bool
          ? json['is_vehicle_loan']
          : (json['is_vehicle_loan']?.toString() == 'true' ||
              json['is_vehicle_loan'] == 1),
      hasPropertyDocuments: json['has_property_documents'] is bool
          ? json['has_property_documents']
          : (json['has_property_documents']?.toString() == 'true' ||
              json['has_property_documents'] == 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (value != null) 'value': value,
      if (icon != null) 'icon': icon,
      if (description != null) 'description': description,
      'features': features,
      if (label != null) 'label': label,
      if (isVehicleLoan != null) 'is_vehicle_loan': isVehicleLoan,
      if (hasPropertyDocuments != null)
        'has_property_documents': hasPropertyDocuments,
    };
  }
}
