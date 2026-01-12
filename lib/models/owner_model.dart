class Owner {
  final int id;
  final String role;
  final String firstName;
  final String lastName;
  final String phone;
  final String avatarUrl;
  final bool isApproved;

  Owner({
    required this.id,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.avatarUrl,
    required this.isApproved,
  });

  String get name => '$firstName $lastName';

  factory Owner.fromJson(Map<String, dynamic> json) {
    print('👤 تحويل JSON إلى Owner:');
    print('   - ID: ${json['id']}');
    print('   - الاسم: ${json['first_name']} ${json['last_name']}');

    return Owner(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      role: json['role']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      isApproved: json['is_approved'] == 1 || json['is_approved'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'is_approved': isApproved,
    };
  }
}
