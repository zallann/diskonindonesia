class TransactionModel {
  final String id;
  final String userId;
  final String merchantId;
  final double amount;
  final double? discountAmount;
  final double? cashbackAmount;
  final String? couponId;
  final TransactionStatus status;
  final TransactionType type;
  final String description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? verifiedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.merchantId,
    required this.amount,
    this.discountAmount,
    this.cashbackAmount,
    this.couponId,
    required this.status,
    required this.type,
    required this.description,
    this.metadata,
    required this.createdAt,
    this.verifiedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['user_id'],
      merchantId: json['merchant_id'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      discountAmount: json['discount_amount']?.toDouble(),
      cashbackAmount: json['cashback_amount']?.toDouble(),
      couponId: json['coupon_id'],
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TransactionType.purchase,
      ),
      description: json['description'] ?? '',
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      verifiedAt: json['verified_at'] != null 
        ? DateTime.parse(json['verified_at']) 
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'merchant_id': merchantId,
      'amount': amount,
      'discount_amount': discountAmount,
      'cashback_amount': cashbackAmount,
      'coupon_id': couponId,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'description': description,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }
}

enum TransactionStatus { 
  pending, 
  verified, 
  cancelled, 
  disputed, 
  refunded 
}

enum TransactionType { 
  purchase, 
  cashback, 
  pointsRedemption, 
  referralBonus, 
  gamification 
}