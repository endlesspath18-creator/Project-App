class ServiceModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final double price;
  final String duration;
  final String providerId;
  final String providerName;
  final bool isActive;
  final double rating;

  ServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.duration,
    required this.providerId,
    required this.providerName,
    this.isActive = true,
    this.rating = 4.5,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] ?? '',
      providerId: json['providerId']?.toString() ?? '',
      providerName: json['providerName'] ?? 'Expert Provider',
      isActive: json['isActive'] ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'price': price,
      'duration': duration,
      'isActive': isActive,
    };
  }
}
