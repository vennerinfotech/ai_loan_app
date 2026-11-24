/// Model representing single document detail (e.g. GET {{baseUrl}}/my-documents/aadhaar)
/// Entity without status_code, success, message, or errors.
class DocumentDetailModel {
  final String? type;
  final String? title;
  final String? number;
  final String? image;
  final String? status;
  final String? updatedAt;
  final String? createdAt;

  DocumentDetailModel({
    this.type,
    this.title,
    this.number,
    this.image,
    this.status,
    this.updatedAt,
    this.createdAt,
  });

  factory DocumentDetailModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        (json['data'] != null && json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;

    return DocumentDetailModel(
      type: data['type']?.toString(),
      title: data['title']?.toString(),
      number: data['number']?.toString(),
      image: data['image']?.toString(),
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
        if (status != null) 'status': status,
        if (updatedAt != null) 'updated_at': updatedAt,
        if (createdAt != null) 'created_at': createdAt,
      };
}
