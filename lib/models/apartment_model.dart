// lib/models/apartment.dart
import 'package:marsa_app/controllers/config.dart';
import 'package:marsa_app/controllers/services/test_connection.dart';

class Apartment {
  final int id;
  final String title;
  final String description;
  final String city;
  final String province;
  final String address;
  final double price;
  final int rooms;
  final int guests;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // العلاقات
  final List<ApartmentImage> images;
  final Owner owner;
  final List<Review> reviews;
  final List<dynamic> bookings;

  Apartment({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.province,
    required this.address,
    required this.price,
    required this.rooms,
    required this.guests,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    required this.images,
    required this.owner,
    required this.reviews,
    this.bookings = const [], // قيمة افتراضية
  });

  // تحويل من JSON مع معالجة أنواع البيانات
  factory Apartment.fromJson(Map<String, dynamic> json) {
    // معالجة حقل is_active (قد يأتي كـ int أو bool أو string)
    bool isActive;
    if (json['is_active'] != null) {
      if (json['is_active'] is bool) {
        isActive = json['is_active'];
      } else if (json['is_active'] is int) {
        isActive = json['is_active'] == 1;
      } else if (json['is_active'] is String) {
        isActive =
            json['is_active'].toLowerCase() == 'true' ||
            json['is_active'] == '1';
      } else {
        isActive = true; // القيمة الافتراضية
      }
    } else {
      isActive = true; // القيمة الافتراضية
    }

    // معالجة التواريخ بشكل آمن
    DateTime? parseDate(String? dateString) {
      try {
        return dateString != null ? DateTime.parse(dateString) : null;
      } catch (e) {
        print('خطأ في تحويل التاريخ: $dateString - $e');
        return null;
      }
    }

    return Apartment(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      title: json['title']?.toString() ?? 'بدون عنوان',
      description: json['description']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      price: json['price'] != null
          ? double.parse(json['price'].toString())
          : 0.0,
      rooms: json['rooms'] != null ? int.parse(json['rooms'].toString()) : 0,
      guests: json['guests'] != null ? int.parse(json['guests'].toString()) : 0,
      isActive: isActive,
      createdAt: parseDate(json['created_at']?.toString()),
      updatedAt: parseDate(json['updated_at']?.toString()),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((img) => ApartmentImage.fromJson(img))
              .toList() ??
          [],
      owner: json['owner'] != null
          ? Owner.fromJson(
              json['owner'] is Map ? json['owner'] as Map<String, dynamic> : {},
            )
          : Owner.empty(),
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((review) => Review.fromJson(review))
              .toList() ??
          [],
    );
  }

  // الحصول على الصورة الرئيسية
  String? get mainImage {
    if (images.isEmpty) return null;

    final main = images.firstWhere(
      (img) => img.isMain,
      orElse: () => images.first,
    );
    return main.url;
  }

  // الحصول على جميع الصور
  List<String> get allImages => images.map((img) => img.url).toList();

  // نسخ مع تحديث الحقول
  Apartment copyWith({
    int? id,
    String? title,
    String? description,
    String? city,
    String? province,
    String? address,
    double? price,
    int? rooms,
    int? guests,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ApartmentImage>? images,
    Owner? owner,
    List<Review>? reviews,
  }) {
    return Apartment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      city: city ?? this.city,
      province: province ?? this.province,
      address: address ?? this.address,
      price: price ?? this.price,
      rooms: rooms ?? this.rooms,
      guests: guests ?? this.guests,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      owner: owner ?? this.owner,
      reviews: reviews ?? this.reviews,
    );
  }

  @override
  String toString() {
    return 'Apartment(id: $id, title: $title, city: $city, price: $price, isActive: $isActive)';
  }
}

// نموذج صورة الشقة
class ApartmentImage {
  final int id;
  final String url;
   bool isMain;

  ApartmentImage({required this.id, required this.url, required this.isMain});

  factory ApartmentImage.fromJson(Map<String, dynamic> json) {
    bool isMainValue;
    if (json['is_main'] != null) {
      if (json['is_main'] is bool) {
        isMainValue = json['is_main'];
      } else if (json['is_main'] is int) {
        isMainValue = json['is_main'] == 1;
      } else if (json['is_main'] is String) {
        isMainValue =
            json['is_main'].toLowerCase() == 'true' || json['is_main'] == '1';
      } else {
        isMainValue = false;
      }
    } else {
      isMainValue = false;
    }

    return ApartmentImage(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      url: json['url']?.toString() ?? '',
      isMain: isMainValue,
    );
  }
}

// نموذج المالك
class Owner {
    TestConnection testConnection = new TestConnection();
  final int id;
  final String name; // سنجمع first_name و last_name
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final String role;
  final bool isApproved;
  final String? avatarUrl;
  final String? idDocumentUrl;
  final DateTime? dateOfBirth;

  Owner({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    required this.role,
    required this.isApproved,
    this.avatarUrl,
    this.idDocumentUrl,
    this.dateOfBirth,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    print('🔍 تحويل JSON للمالك:');
    print('   📊 البيانات: $json');

    // استخراج الاسم الأول والاسم الأخير
    final firstName = json['first_name']?.toString();
    final lastName = json['last_name']?.toString();

    // بناء الاسم الكامل
    String fullName;
    if (firstName != null && lastName != null) {
      fullName = '$firstName $lastName';
    } else if (firstName != null) {
      fullName = firstName;
    } else if (lastName != null) {
      fullName = lastName;
    } else if (json['name'] != null) {
      fullName = json['name'].toString();
    } else {
      fullName = 'غير معروف';
    }

    print('   👤 الاسم الأول: $firstName');
    print('   👤 الاسم الأخير: $lastName');
    print('   👤 الاسم الكامل: $fullName');

    // استخراج البريد الإلكتروني (قد يكون غير موجود في الـ API)
    final email = json['email']?.toString() ?? '';

    // استخراج الهاتف
    final phone = json['phone']?.toString();

    // استخراج الصورة
    String? avatarUrl;
    if (json['avatar_url'] != null) {
      avatarUrl = json['avatar_url'].toString();
      // تحويل المسار النسبي إلى URL كامل
      if (avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
        avatarUrl = 'http://${Configuration.baseUrl}:8000/storage/$avatarUrl';
      }
    }

    // استخراج وثيقة الهوية
    String? idDocumentUrl;
    if (json['id_document_url'] != null) {
      idDocumentUrl = json['id_document_url'].toString();
      if (idDocumentUrl.isNotEmpty && !idDocumentUrl.startsWith('http')) {
        idDocumentUrl = 'http://${Configuration.baseUrl}:8000/storage/$idDocumentUrl';
      }
    }

    // معالجة is_approved
    bool isApprovedValue;
    if (json['is_approved'] != null) {
      if (json['is_approved'] is bool) {
        isApprovedValue = json['is_approved'];
      } else if (json['is_approved'] is int) {
        isApprovedValue = json['is_approved'] == 1;
      } else if (json['is_approved'] is String) {
        isApprovedValue =
            json['is_approved'].toLowerCase() == 'true' ||
            json['is_approved'] == '1';
      } else {
        isApprovedValue = false;
      }
    } else {
      isApprovedValue = false;
    }

    // معالجة تاريخ الميلاد
    DateTime? dateOfBirth;
    if (json['date_of_birth'] != null) {
      try {
        dateOfBirth = DateTime.tryParse(json['date_of_birth'].toString());
      } catch (e) {
        print('⚠️ خطأ في تحويل تاريخ الميلاد: $e');
      }
    }

    return Owner(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      name: fullName,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      role: json['role']?.toString() ?? 'user',
      isApproved: isApprovedValue,
      avatarUrl: avatarUrl,
      idDocumentUrl: idDocumentUrl,
      dateOfBirth: dateOfBirth,
    );
  }

  factory Owner.empty() {
    return Owner(
      id: 0,
      name: 'غير معروف',
      firstName: null,
      lastName: null,
      email: '',
      phone: null,
      role: 'user',
      isApproved: false,
      avatarUrl: null,
      idDocumentUrl: null,
      dateOfBirth: null,
    );
  }

  // دالة للحصول على الأحرف الأولى
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    } else if (firstName != null && firstName!.isNotEmpty) {
      return firstName![0].toUpperCase();
    } else if (lastName != null && lastName!.isNotEmpty) {
      return lastName![0].toUpperCase();
    }
    return 'U';
  }

  // دالة للتحقق إذا كان البريد الإلكتروني متوفراً
  bool get hasEmail => email.isNotEmpty && email.contains('@');
}

// نموذج التقييمات
class Review {
  final int id;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final Tenant tenant;

  Review({
    required this.id,
    required this.rating,
    this.comment,
    this.createdAt,
    required this.tenant,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateString) {
      try {
        return dateString != null ? DateTime.parse(dateString) : null;
      } catch (e) {
        return null;
      }
    }

    return Review(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      rating: json['rating'] != null ? int.parse(json['rating'].toString()) : 0,
      comment: json['comment']?.toString(),
      createdAt: parseDate(json['created_at']?.toString()),
      tenant: json['tenant'] != null
          ? Tenant.fromJson(
              json['tenant'] is Map
                  ? json['tenant'] as Map<String, dynamic>
                  : {},
            )
          : Tenant.empty(),
    );
  }
}

// نموذج المستأجر
class Tenant {
  final int id;
  final String name;
  final String email;

  Tenant({required this.id, required this.name, required this.email});

  // إنشاء مستأجر فارغ
  factory Tenant.empty() {
    return Tenant(id: 0, name: 'مستخدم', email: '');
  }

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      name: json['name']?.toString() ?? 'مستخدم',
      email: json['email']?.toString() ?? '',
    );
  }
}
