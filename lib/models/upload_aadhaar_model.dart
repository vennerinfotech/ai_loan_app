/// Data payload model for POST /upload-aadhaar
class UploadAadhaarData {
  final String? uploadMode;
  final String? front;
  final String? back;
  final String? aadhaarStatus;
  final AadhaarExtractedData? extractedData;
  final int? userId;

  UploadAadhaarData({
    this.uploadMode,
    this.front,
    this.back,
    this.aadhaarStatus,
    this.extractedData,
    this.userId,
  });

  factory UploadAadhaarData.fromJson(Map<String, dynamic> json) {
    return UploadAadhaarData(
      uploadMode: json['upload_mode']?.toString(),
      front: json['front']?.toString(),
      back: json['back']?.toString(),
      aadhaarStatus: json['aadhaar_status']?.toString(),
      extractedData: json['extracted_data'] != null && json['extracted_data'] is Map
          ? AadhaarExtractedData.fromJson(Map<String, dynamic>.from(json['extracted_data']))
          : null,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (uploadMode != null) 'upload_mode': uploadMode,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (aadhaarStatus != null) 'aadhaar_status': aadhaarStatus,
      if (extractedData != null) 'extracted_data': extractedData?.toJson(),
      if (userId != null) 'user_id': userId,
    };
  }
}

/// Extracted OCR / Bureau details from uploaded Aadhaar front and back documents
class AadhaarExtractedData {
  final String? aadhaarNumber;
  final String? name;
  final String? dateOfBirth;
  final String? gender;
  final String? address;

  AadhaarExtractedData({
    this.aadhaarNumber,
    this.name,
    this.dateOfBirth,
    this.gender,
    this.address,
  });

  factory AadhaarExtractedData.fromJson(Map<String, dynamic> json) {
    return AadhaarExtractedData(
      aadhaarNumber: json['aadhaar_number']?.toString(),
      name: json['name']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (aadhaarNumber != null) 'aadhaar_number': aadhaarNumber,
      if (name != null) 'name': name,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (address != null) 'address': address,
    };
  }
}
