/// Model class for Store / Upload PAN Card Data
class StorePanData {
  final String? panCardNumber;
  final int? userId;
  final int? documentId;
  final String? filename;

  StorePanData({
    this.panCardNumber,
    this.userId,
    this.documentId,
    this.filename,
  });

  factory StorePanData.fromJson(Map<String, dynamic> json) {
    return StorePanData(
      panCardNumber: json['pan_card_number']?.toString(),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
      documentId: json['document_id'] is int
          ? json['document_id']
          : int.tryParse(json['document_id']?.toString() ?? ''),
      filename: json['filename']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (panCardNumber != null) 'pan_card_number': panCardNumber,
      if (userId != null) 'user_id': userId,
      if (documentId != null) 'document_id': documentId,
      if (filename != null) 'filename': filename,
    };
  }
}
