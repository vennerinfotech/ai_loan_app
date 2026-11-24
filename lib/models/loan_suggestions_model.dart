// Model for GET {{baseUrl}}/loan-suggestions response

class LoanSuggestionsResponseModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final LoanSuggestionsData? data;
  final dynamic errors;

  LoanSuggestionsResponseModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
    this.errors,
  });

  factory LoanSuggestionsResponseModel.fromJson(Map<String, dynamic> json) {
    return LoanSuggestionsResponseModel(
      success: json['success'] as bool?,
      statusCode: json['status_code'] is int
          ? json['status_code']
          : int.tryParse(json['status_code']?.toString() ?? ''),
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? LoanSuggestionsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'message': message,
      'data': data?.toJson(),
      'errors': errors,
    };
  }
}

class LoanSuggestionsData {
  final LoanSuggestionUser? user;
  final List<LoanSuggestionItem> suggestions;

  LoanSuggestionsData({
    this.user,
    this.suggestions = const [],
  });

  factory LoanSuggestionsData.fromJson(Map<String, dynamic> json) {
    return LoanSuggestionsData(
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? LoanSuggestionUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      suggestions: (json['suggestions'] as List?)
              ?.map((item) =>
                  LoanSuggestionItem.fromJson(Map<String, dynamic>.from(item)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'suggestions': suggestions.map((e) => e.toJson()).toList(),
    };
  }
}

class LoanSuggestionUser {
  final int? id;
  final String? name;
  final String? phone;

  LoanSuggestionUser({
    this.id,
    this.name,
    this.phone,
  });

  factory LoanSuggestionUser.fromJson(Map<String, dynamic> json) {
    return LoanSuggestionUser(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }
}

class LoanSuggestionItem {
  final int? id;
  final String? bankName;
  final String? interestRate;
  final String? maxLoanAmount;
  final String? tenure;
  final String? processingFee;
  final int? matchScore;
  final String? reason;
  final List<String> pros;
  final List<String> cons;

  LoanSuggestionItem({
    this.id,
    this.bankName,
    this.interestRate,
    this.maxLoanAmount,
    this.tenure,
    this.processingFee,
    this.matchScore,
    this.reason,
    this.pros = const [],
    this.cons = const [],
  });

  factory LoanSuggestionItem.fromJson(Map<String, dynamic> json) {
    return LoanSuggestionItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      bankName: json['bank_name']?.toString(),
      interestRate: json['interest_rate']?.toString(),
      maxLoanAmount: json['max_loan_amount']?.toString(),
      tenure: json['tenure']?.toString(),
      processingFee: json['processing_fee']?.toString(),
      matchScore: json['match_score'] is int
          ? json['match_score']
          : int.tryParse(json['match_score']?.toString() ?? ''),
      reason: json['reason']?.toString(),
      pros: (json['pros'] as List?)?.map((e) => e.toString()).toList() ?? [],
      cons: (json['cons'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_name': bankName,
      'interest_rate': interestRate,
      'max_loan_amount': maxLoanAmount,
      'tenure': tenure,
      'processing_fee': processingFee,
      'match_score': matchScore,
      'reason': reason,
      'pros': pros,
      'cons': cons,
    };
  }

  /// Numeric interest rate for sorting
  double get interestRateValue {
    if (interestRate == null) return 0.0;
    final clean = interestRate!.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  /// Numeric processing fee for sorting
  double get processingFeeValue {
    if (processingFee == null) return 0.0;
    if (processingFee!.toLowerCase() == 'nil' ||
        processingFee!.toLowerCase() == 'zero') {
      return 0.0;
    }
    final clean = processingFee!.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  /// Clean 2-letter or acronym bank initials for avatar
  String get initials {
    final name = (bankName ?? '').trim();
    if (name.isEmpty) return 'BK';
    if (name.contains('(') && name.contains(')')) {
      final insideParen = RegExp(r'\((.*?)\)').firstMatch(name)?.group(1);
      if (insideParen != null && insideParen.isNotEmpty) {
        return insideParen.toUpperCase();
      }
    }
    final words = name.split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
