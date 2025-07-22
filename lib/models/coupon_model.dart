class CouponModel {
  final String couponId;
  final String? tenantId;
  final String kode;
  final CouponType tipeDiskon;
  final double nilaiDiskon;
  final double minBelanja;
  final DateTime tanggalKadaluwarsa;
  final DateTime createdAt;

  CouponModel({
    required this.couponId,
    this.tenantId,
    required this.kode,
    required this.tipeDiskon,
    required this.nilaiDiskon,
    required this.minBelanja,
    required this.tanggalKadaluwarsa,
    required this.createdAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      couponId: json['coupon_id'],
      tenantId: json['tenant_id'],
      kode: json['kode'],
      tipeDiskon: CouponType.values.firstWhere(
        (e) => e.toString().split('.').last == json['tipe_diskon'],
        orElse: () => CouponType.persentase,
      ),
      nilaiDiskon: (json['nilai_diskon'] ?? 0.0).toDouble(),
      minBelanja: (json['min_belanja'] ?? 0.0).toDouble(),
      tanggalKadaluwarsa: DateTime.parse(json['tanggal_kadaluwarsa']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coupon_id': couponId,
      'tenant_id': tenantId,
      'kode': kode,
      'tipe_diskon': tipeDiskon.toString().split('.').last,
      'nilai_diskon': nilaiDiskon,
      'min_belanja': minBelanja,
      'tanggal_kadaluwarsa': tanggalKadaluwarsa.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Getter untuk kompatibilitas dengan kode yang sudah ada
  String get id => couponId;
  String get merchantId => tenantId ?? '';
  String get code => kode;
  String get title => 'Kupon Diskon';
  String get description => 'Diskon ${tipeDiskon == CouponType.persentase ? '${nilaiDiskon.toInt()}%' : 'Rp ${nilaiDiskon.toInt()}'}';
  String get imageUrl => '';
  CouponTypeOld get type => tipeDiskon == CouponType.persentase ? CouponTypeOld.percentage : CouponTypeOld.fixed;
  double get discountValue => nilaiDiskon;
  double? get minimumPurchase => minBelanja;
  double? get maximumDiscount => null;
  int get usageLimit => 1;
  int get usedCount => 0;
  DateTime get validFrom => createdAt;
  DateTime get validUntil => tanggalKadaluwarsa;
  bool get isActive => DateTime.now().isBefore(tanggalKadaluwarsa);
  List<String>? get applicableCategories => null;
  Map<String, dynamic>? get metadata => null;

  bool get isValid => isActive && 
    usedCount < usageLimit && 
    DateTime.now().isAfter(validFrom) && 
    DateTime.now().isBefore(validUntil);

  double calculateDiscount(double purchaseAmount) {
    if (!isValid || purchaseAmount < minBelanja) {
      return 0.0;
    }

    double discount;
    if (tipeDiskon == CouponType.persentase) {
      discount = purchaseAmount * (nilaiDiskon / 100);
    } else {
      discount = nilaiDiskon;
    }

    return discount;
  }
}

enum CouponType { persentase, tetap }
enum CouponTypeOld { percentage, fixed }