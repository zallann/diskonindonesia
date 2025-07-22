class CouponModel {
  final String id;
  final String merchantId;
  final String code;
  final String title;
  final String description;
  final String imageUrl;
  final CouponType type;
  final double discountValue;
  final double? minimumPurchase;
  final double? maximumDiscount;
  final int usageLimit;
  final int usedCount;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final List<String>? applicableCategories;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  CouponModel({
    required this.id,
    required this.merchantId,
    required this.code,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.discountValue,
    this.minimumPurchase,
    this.maximumDiscount,
    required this.usageLimit,
    required this.usedCount,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    this.applicableCategories,
    this.metadata,
    required this.createdAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'],
      merchantId: json['merchant_id'],
      code: json['code'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      type: CouponType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => CouponType.percentage,
      ),
      discountValue: (json['discount_value'] ?? 0.0).toDouble(),
      minimumPurchase: json['minimum_purchase']?.toDouble(),
      maximumDiscount: json['maximum_discount']?.toDouble(),
      usageLimit: json['usage_limit'] ?? 0,
      usedCount: json['used_count'] ?? 0,
      validFrom: DateTime.parse(json['valid_from']),
      validUntil: DateTime.parse(json['valid_until']),
      isActive: json['is_active'] ?? true,
      applicableCategories: json['applicable_categories']?.cast<String>(),
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'code': code,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'type': type.toString().split('.').last,
      'discount_value': discountValue,
      'minimum_purchase': minimumPurchase,
      'maximum_discount': maximumDiscount,
      'usage_limit': usageLimit,
      'used_count': usedCount,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'is_active': isActive,
      'applicable_categories': applicableCategories,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isValid => isActive && 
    usedCount < usageLimit && 
    DateTime.now().isAfter(validFrom) && 
    DateTime.now().isBefore(validUntil);

  double calculateDiscount(double purchaseAmount) {
    if (!isValid || (minimumPurchase != null && purchaseAmount < minimumPurchase!)) {
      return 0.0;
    }

    double discount;
    if (type == CouponType.percentage) {
      discount = purchaseAmount * (discountValue / 100);
    } else {
      discount = discountValue;
    }

    if (maximumDiscount != null && discount > maximumDiscount!) {
      discount = maximumDiscount!;
    }

    return discount;
  }
}

enum CouponType { percentage, fixed }