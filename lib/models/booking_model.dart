// lib/models/booking_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:marsa_app/models/apartment_model.dart';

class Booking {
  final int id;
  final int apartmentId;
  final int tenantId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // العلاقات
  final Apartment apartment;
  final Tenant tenant;
  final Owner? owner;

  Booking({
    required this.id,
    required this.apartmentId,
    required this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.apartment,
    required this.tenant,
    this.owner,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    print('📦 تحويل JSON إلى Booking:');
    print('   - ID: ${json['id']}');
    print(
      '   - apartment.owner موجود؟: ${json['apartment']?['owner'] != null}',
    );

    return Booking(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      apartmentId: json['apartment_id'] != null
          ? int.parse(json['apartment_id'].toString())
          : 0,
      tenantId: json['tenant_id'] != null
          ? int.parse(json['tenant_id'].toString())
          : 0,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      apartment: Apartment.fromJson(json['apartment'] ?? {}),
      tenant: Tenant.fromJson(json['tenant'] ?? {}),
      // هنا نأخذ المالك من apartment.owner وليس من json['owner']
      owner: json['apartment']?['owner'] != null
          ? Owner.fromJson(json['apartment']!['owner'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartment_id': apartmentId,
      'tenant_id': tenantId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'apartment': apartment.toJson(),
      'tenant': tenant.toJson(),
    };
  }

  // الحصول على حالة الحجز كنص
  String get statusText {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'cancelled':
        return 'ملغى';
      case 'rejected':
        return 'مرفوض';
      case 'pending_update':
        return 'قيد التحديث';
      default:
        return status;
    }
  }

  // الحصول على لون الحالة
  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'rejected':
        return Colors.grey;
      case 'pending_update':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // التحقق إذا كان الحجز نشطاً
  bool get isActive {
    return status == 'confirmed' || status == 'pending';
  }

  // التحقق إذا كان الحجز قابلاً للإلغاء
  bool get canCancel {
    return status == 'pending' || status == 'confirmed';
  }

  // الحصول على مدة الحجز بالأيام
  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }

  // التحقق إذا كان الحجز قادماً
  bool get isUpcoming {
    final now = DateTime.now();
    return isActive && startDate.isAfter(now);
  }

  // التحقق إذا كان الحجز حالياً
  bool get isCurrent {
    final now = DateTime.now();
    return isActive && startDate.isBefore(now) && endDate.isAfter(now);
  }

  // التحقق إذا كان الحجز منتهياً
  bool get isPast {
    final now = DateTime.now();
    return endDate.isBefore(now);
  }

  // الحصول على النص المناسب للحالة
  String get statusDescription {
    if (isCurrent) return 'حالي';
    if (isUpcoming) return 'قادم';
    if (isPast) return 'منتهي';
    return statusText;
  }
}

// Tenant model
class Tenant {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;

  Tenant({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
  });

  // إضافة getter للحصول على الاسم الكامل
  String get fullName => '$firstName $lastName';

  factory Tenant.fromJson(Map<String, dynamic> json) {
    print('👤 تحويل JSON إلى Tenant:');
    print('   - JSON keys: ${json.keys.toList()}');
    print('   - first_name: ${json['first_name']}');
    print('   - last_name: ${json['last_name']}');
    print('   - email: ${json['email']}');
    print('   - phone: ${json['phone']}');

    return Tenant(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      firstName: json['first_name']?.toString() ?? 'مستخدم',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
    };
  }
}

// إضافة toJson لـ Apartment
extension ApartmentExtensions on Apartment {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'city': city,
      'province': province,
      'address': address,
      'price': price,
      'rooms': rooms,
      'guests': guests,
      'is_active': isActive,
      'images': images.map((img) => img.toJson()).toList(),
      'owner': owner.toJson(),
    };
  }
}

// إضافة toJson لـ ApartmentImage
extension ApartmentImageExtensions on ApartmentImage {
  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'is_main': isMain};
  }
}

// إضافة toJson لـ Owner
extension OwnerExtensions on Owner {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'is_approved': isApproved,
      'avatar_url': avatarUrl,
      'id_document_url': idDocumentUrl,
    };
  }
}
