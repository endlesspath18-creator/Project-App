class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // "USER" or "PROVIDER"
  final bool isRoleSet;
  final String? businessName;
  final String? phone;

  final bool hasPaidPublishingFee;
  final bool canPublishService;
  final bool isOnline;
  final Map<String, dynamic>? providerProfile;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.isRoleSet = true,
    this.businessName,
    this.phone,
    this.hasPaidPublishingFee = false,
    this.canPublishService = false,
    this.isOnline = true,
    this.providerProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'USER',
      isRoleSet: json['isRoleSet'] == true,
      businessName: json['businessName'] ?? json['providerProfile']?['businessName'],
      phone: json['phone'],
      hasPaidPublishingFee: json['hasPaidPublishingFee'] == true,
      canPublishService: json['canPublishService'] == true,
      isOnline: json['providerProfile']?['isOnline'] ?? true,
      providerProfile: json['providerProfile'],
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
      'hasPaidPublishingFee': hasPaidPublishingFee,
      'canPublishService': canPublishService,
      'isOnline': isOnline,
      'providerProfile': providerProfile,
    };
  }
}
