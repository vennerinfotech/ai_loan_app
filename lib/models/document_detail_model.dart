import 'my_documents_response_model.dart';

/// Model representing an individual file/image item in document detail API
class DocumentDetailImageItem {
  final String? side;
  final String? name;
  final String? url;
  final String? extension;
  final bool isImage;

  DocumentDetailImageItem({
    this.side,
    this.name,
    this.url,
    this.extension,
    this.isImage = true,
  });

  factory DocumentDetailImageItem.fromJson(Map<String, dynamic> json) {
    final rawIsImage = json['is_image'];
    final bool parsedIsImage = rawIsImage is bool
        ? rawIsImage
        : (rawIsImage?.toString().toLowerCase() == 'true' || rawIsImage == 1);

    return DocumentDetailImageItem(
      side: json['side']?.toString(),
      name: json['name']?.toString(),
      url: json['url']?.toString(),
      extension: json['extension']?.toString(),
      isImage: parsedIsImage,
    );
  }

  factory DocumentDetailImageItem.fromMyDocumentFileItem(MyDocumentFileItem item) {
    return DocumentDetailImageItem(
      side: item.side,
      name: item.name,
      url: item.url,
      extension: item.extension,
      isImage: item.isImage,
    );
  }

  Map<String, dynamic> toJson() => {
        if (side != null) 'side': side,
        if (name != null) 'name': name,
        if (url != null) 'url': url,
        if (extension != null) 'extension': extension,
        'is_image': isImage,
      };
}

/// Model representing document detail (e.g. GET {{baseUrl}}/my-documents/{document_type})
class DocumentDetailModel {
  final String? type;
  final String? title;
  final String? number;
  final String? image;
  final List<DocumentDetailImageItem> imageUrls;
  final String? status;
  final String? updatedAt;
  final String? createdAt;

  DocumentDetailModel({
    this.type,
    this.title,
    this.number,
    this.image,
    this.imageUrls = const [],
    this.status,
    this.updatedAt,
    this.createdAt,
  });

  factory DocumentDetailModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        (json['data'] != null && json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;

    final rawImages = data['image_urls'];
    List<DocumentDetailImageItem> parsedUrls = [];
    if (rawImages is List) {
      parsedUrls = rawImages
          .whereType<Map<String, dynamic>>()
          .map((item) => DocumentDetailImageItem.fromJson(item))
          .toList();
    }

    return DocumentDetailModel(
      type: data['type']?.toString(),
      title: data['title']?.toString(),
      number: data['number']?.toString(),
      image: data['image']?.toString(),
      imageUrls: parsedUrls,
      status: data['status']?.toString(),
      updatedAt: data['updated_at']?.toString(),
      createdAt: data['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (type != null) 'type': type,
        if (title != null) 'title': title,
        if (number != null) 'number': number,
        if (image != null) 'image': image,
        'image_urls': imageUrls.map((e) => e.toJson()).toList(),
        if (status != null) 'status': status,
        if (updatedAt != null) 'updated_at': updatedAt,
        if (createdAt != null) 'created_at': createdAt,
      };
}
