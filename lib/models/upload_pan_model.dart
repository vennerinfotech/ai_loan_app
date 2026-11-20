/// Data payload model for POST /upload-pan
class UploadPanData {
  final String? uploadMode;
  final String? filename;
  final String? panStatus;
  final PanExtractedData? extractedData;
  final int? userId;

  UploadPanData({
    this.uploadMode,
    this.filename,
    this.panStatus,
    this.extractedData,
    this.userId,
  });

  factory UploadPanData.fromJson(Map<String, dynamic> json) {
    return UploadPanData(
      uploadMode: json['upload_mode']?.toString(),
      filename: json['filename']?.toString(),
      panStatus: json['pan_status']?.toString(),
      extractedData: json['extracted_data'] != null && json['extracted_data'] is Map
          ? PanExtractedData.fromJson(Map<String, dynamic>.from(json['extracted_data']))
          : null,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (uploadMode != null) 'upload_mode': uploadMode,
      if (filename != null) 'filename': filename,
      if (panStatus != null) 'pan_status': panStatus,
      if (extractedData != null) 'extracted_data': extractedData?.toJson(),
      if (userId != null) 'user_id': userId,
    };
  }
}

/// Extracted OCR / Bureau details from uploaded PAN card
class PanExtractedData {
  final String? panNumber;
  final String? name;
  final String? fatherName;
  final String? dateOfBirth;

  PanExtractedData({
    this.panNumber,
    this.name,
    this.fatherName,
    this.dateOfBirth,
  });

  factory PanExtractedData.fromJson(Map<String, dynamic> json) {
    return PanExtractedData(
      panNumber: json['pan_number']?.toString(),
      name: json['name']?.toString(),
      fatherName: json['father_name']?.toString() ?? json['fathers_name']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString() ?? json['dob']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (panNumber != null) 'pan_number': panNumber,
      if (name != null) 'name': name,
      if (fatherName != null) 'father_name': fatherName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
    };
  }
}
