/// Data payload for POST /loan/cibil-score containing pan_number and cibil_data
class CibilScoreData {
  final String? panNumber;
  final CibilData? cibilData;

  CibilScoreData({
    this.panNumber,
    this.cibilData,
  });

  factory CibilScoreData.fromJson(Map<String, dynamic> json) {
    return CibilScoreData(
      panNumber: json['pan_number']?.toString(),
      cibilData: json['cibil_data'] != null && json['cibil_data'] is Map
          ? CibilData.fromJson(Map<String, dynamic>.from(json['cibil_data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (panNumber != null) 'pan_number': panNumber,
      if (cibilData != null) 'cibil_data': cibilData?.toJson(),
    };
  }

  // Convenience getters
  int? get score => cibilData?.cibilScore;
  String? get reportDate => cibilData?.reportDate;
  String? get provider => cibilData?.provider;
}

/// Separate model for CIBIL Data: cibil_data field
class CibilData {
  final String? pan;
  final int? cibilScore;
  final String? reportDate;
  final String? provider;

  CibilData({
    this.pan,
    this.cibilScore,
    this.reportDate,
    this.provider,
  });

  factory CibilData.fromJson(Map<String, dynamic> json) {
    return CibilData(
      pan: json['pan']?.toString(),
      cibilScore: json['cibil_score'] is int
          ? json['cibil_score']
          : int.tryParse(json['cibil_score']?.toString() ?? ''),
      reportDate: json['report_date']?.toString(),
      provider: json['provider']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (pan != null) 'pan': pan,
      if (cibilScore != null) 'cibil_score': cibilScore,
      if (reportDate != null) 'report_date': reportDate,
      if (provider != null) 'provider': provider,
    };
  }
}
