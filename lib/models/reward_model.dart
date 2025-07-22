class RewardModel {
  final String id;
  final String merchantId;
  final String name;
  final String description;
  final String imageUrl;
  final int pointsRequired;
  final int stock;
  final RewardCategory category;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  RewardModel({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.pointsRequired,
    required this.stock,
    required this.category,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    this.metadata,
    required this.createdAt,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'],
      merchantId: json['merchant_id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      pointsRequired: json['points_required'] ?? 0,
      stock: json['stock'] ?? 0,
      category: RewardCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => RewardCategory.voucher,
      ),
      validFrom: DateTime.parse(json['valid_from']),
      validUntil: DateTime.parse(json['valid_until']),
      isActive: json['is_active'] ?? true,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'points_required': pointsRequired,
      'stock': stock,
      'category': category.toString().split('.').last,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'is_active': isActive,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isAvailable => isActive && stock > 0 && 
    DateTime.now().isAfter(validFrom) && 
    DateTime.now().isBefore(validUntil);
}

enum RewardCategory { 
  voucher, 
  cashback, 
  product, 
  experience, 
  gift 
}