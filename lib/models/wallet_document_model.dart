import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';

/// Data model representing a verified or uploaded document in the wallet,
/// supporting direct image URLs (from API), in-memory bytes, and JSON serialization.
class WalletDocumentModel {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 'KYC', 'Income', 'Loan'
  final String badgeText;
  final IconData icon;
  final bool isFeatured; // true for Aadhaar (dark blue card in list)

  // Direct document image support (from backend API or local device/camera)
  final String? frontImageUrl;
  final String? backImageUrl;
  final Uint8List? frontImageBytes;
  final Uint8List? backImageBytes;

  // Metadata
  final String status;
  final String uploadedDate;
  final String usedIn;

  WalletDocumentModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.badgeText,
    required this.icon,
    this.isFeatured = false,
    this.frontImageUrl,
    this.backImageUrl,
    this.frontImageBytes,
    this.backImageBytes,
    this.status = 'Verified via UIDAI',
    this.uploadedDate = '12 Nov 2026',
    this.usedIn = 'Home loan • #FS-2611-0042',
  });

  /// True if a direct image is available for the front side
  bool get hasFrontImage =>
      frontImageBytes != null ||
      (frontImageUrl != null && frontImageUrl!.isNotEmpty);

  /// True if a direct image is available for the back side
  bool get hasBackImage =>
      backImageBytes != null ||
      (backImageUrl != null && backImageUrl!.isNotEmpty);

  /// Factory constructor to parse document from direct API response
  factory WalletDocumentModel.fromJson(Map<String, dynamic> json) {
    return WalletDocumentModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      category: json['category']?.toString() ?? 'KYC',
      badgeText: json['badge_text']?.toString() ??
          json['badgeText']?.toString() ??
          'Verified',
      icon: _getIconForCategory(
        json['category']?.toString(),
        json['id']?.toString(),
      ),
      isFeatured: json['is_featured'] == true || json['isFeatured'] == true,
      frontImageUrl: json['front_image_url']?.toString() ??
          json['frontImageUrl']?.toString() ??
          json['image_url']?.toString() ??
          json['imageUrl']?.toString(),
      backImageUrl: json['back_image_url']?.toString() ??
          json['backImageUrl']?.toString(),
      status: json['status']?.toString() ?? 'Verified via UIDAI',
      uploadedDate: json['uploaded_date']?.toString() ??
          json['uploadedDate']?.toString() ??
          '12 Nov 2026',
      usedIn: json['used_in']?.toString() ??
          json['usedIn']?.toString() ??
          'Home loan • #FS-2611-0042',
    );
  }

  /// Converts this model to a JSON map for outgoing API payloads
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'badge_text': badgeText,
      'is_featured': isFeatured,
      'front_image_url': frontImageUrl,
      'back_image_url': backImageUrl,
      'status': status,
      'uploaded_date': uploadedDate,
      'used_in': usedIn,
    };
  }

  /// Creates a copy with updated images or fields
  WalletDocumentModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    String? badgeText,
    IconData? icon,
    bool? isFeatured,
    String? frontImageUrl,
    String? backImageUrl,
    Uint8List? frontImageBytes,
    Uint8List? backImageBytes,
    String? status,
    String? uploadedDate,
    String? usedIn,
  }) {
    return WalletDocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      badgeText: badgeText ?? this.badgeText,
      icon: icon ?? this.icon,
      isFeatured: isFeatured ?? this.isFeatured,
      frontImageUrl: frontImageUrl ?? this.frontImageUrl,
      backImageUrl: backImageUrl ?? this.backImageUrl,
      frontImageBytes: frontImageBytes ?? this.frontImageBytes,
      backImageBytes: backImageBytes ?? this.backImageBytes,
      status: status ?? this.status,
      uploadedDate: uploadedDate ?? this.uploadedDate,
      usedIn: usedIn ?? this.usedIn,
    );
  }

  static IconData _getIconForCategory(String? category, String? id) {
    final lowerId = id?.toLowerCase() ?? '';
    if (lowerId.contains('aadhaar')) {
      return Icons.badge_outlined;
    }
    if (lowerId.contains('pan')) {
      return Icons.credit_card_rounded;
    }
    if (category?.toLowerCase() == 'income') {
      return Icons.description_outlined;
    }
    return Icons.folder_outlined;
  }
}
