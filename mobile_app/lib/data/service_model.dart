class ServiceModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final double price;
  final int durationMinutes;
  final String providerId;
  final String providerName;
  final String? businessName;
  final bool isActive;
  final String status;
  final double rating;
  final List<String> images;

  ServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.providerId,
    required this.providerName,
    this.businessName,
    this.isActive = true,
    this.status = 'AVAILABLE',
    this.rating = 4.5,
    this.images = const [],
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Nested provider handling
    final provider = json['provider'] as Map<String, dynamic>?;
    final profile = provider?['providerProfile'] as Map<String, dynamic>?;

    return ServiceModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['durationMinutes'] ?? 60,
      providerId: json['providerId']?.toString() ?? '',
      providerName: provider?['fullName'] ?? json['providerName'] ?? 'Expert Provider',
      businessName: profile?['businessName'],
      isActive: json['isActive'] ?? true,
      status: json['status'] ?? 'AVAILABLE',
      rating: (profile?['rating'] as num?)?.toDouble() ?? (json['rating'] as num?)?.toDouble() ?? 4.5,
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'isActive': isActive,
      'status': status,
      'images': images,
    };
  }

  String get durationString {
    if (durationMinutes >= 60) {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours} Hours';
    }
    return '$durationMinutes Mins';
  }
}
