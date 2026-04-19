class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // "USER" or "PROVIDER"
  final bool isRoleSet;
  final String? businessName;
  final String? phone;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.isRoleSet = true,
    this.businessName,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'USER',
      isRoleSet: json['isRoleSet'] == true, // Strict boolean check, defaults to false if missing
      businessName: json['businessName'] ?? json['providerProfile']?['businessName'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'isRoleSet': isRoleSet,
      'businessName': businessName,
      'phone': phone,
    };
  }
}
