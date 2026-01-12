// في ملف user_model.dart - تأكد من وجود هذا
class UserModel {
  int? id;
  String? firstName;
  String? lastName;
  String? phone;
  String? role;
  String? avatarUrl;
  String? idDocumentUrl;
  bool? isApproved;
  DateTime? phoneVerifiedAt;
  DateTime? dateOfBirth;
  String? mode;
  String? dir;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.role,
    this.avatarUrl,
    this.idDocumentUrl,
    this.isApproved,
    this.phoneVerifiedAt,
    this.dateOfBirth,
    this.mode,
    this.dir,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      role: json['role'],
      avatarUrl: json['avatar_url'],
      idDocumentUrl: json['id_document_url'],
      isApproved: json['is_approved'],
      phoneVerifiedAt: json['phone_verified_at'] != null
          ? DateTime.tryParse(json['phone_verified_at'])
          : null,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      mode: json['mode'],
      dir: json['dir'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'role': role,
      'avatar_url': avatarUrl,
      'id_document_url': idDocumentUrl,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
    };
  }
}
