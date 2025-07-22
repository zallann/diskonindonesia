class TransactionModel {
  final String transactionId;
  final String userId;
  final String tenantId;
  final double jumlah;
  final int poinDiperoleh;
  final double jumlahCashback;
  final TransactionStatus status;
  final DateTime createdAt;

  TransactionModel({
    required this.transactionId,
    required this.userId,
    required this.tenantId,
    required this.jumlah,
    required this.poinDiperoleh,
    required this.jumlahCashback,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'],
      userId: json['user_id'],
      tenantId: json['tenant_id'],
      jumlah: (json['jumlah'] ?? 0.0).toDouble(),
      poinDiperoleh: json['poin_diperoleh'] ?? 0,
      jumlahCashback: (json['jumlah_cashback'] ?? 0.0).toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'user_id': userId,
      'tenant_id': tenantId,
      'jumlah': jumlah,
      'poin_diperoleh': poinDiperoleh,
      'jumlah_cashback': jumlahCashback,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Getter untuk kompatibilitas dengan kode yang sudah ada
  String get id => transactionId;
  String get merchantId => tenantId;
  double get amount => jumlah;
  double? get discountAmount => null; // Tidak ada di database
  double? get cashbackAmount => jumlahCashback;
  String? get couponId => null; // Tidak ada di database
  TransactionType get type => TransactionType.purchase; // Default type
  String get description => 'Transaksi'; // Default description
  Map<String, dynamic>? get metadata => null; // Tidak ada di database
  DateTime? get verifiedAt => status == TransactionStatus.terverifikasi ? createdAt : null;
}

enum TransactionStatus { 
  pending, 
  terverifikasi, 
  dibatalkan 
}

enum TransactionType { 
  purchase, 
  cashback, 
  pointsRedemption, 
  referralBonus, 
  gamification 
}