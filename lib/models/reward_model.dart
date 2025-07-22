class RewardModel {
  final String rewardId;
  final String nama;
  final String? deskripsi;
  final int poinDibutuhkan;
  final RewardType tipe;
  final int stok;
  final DateTime createdAt;

  RewardModel({
    required this.rewardId,
    required this.nama,
    this.deskripsi,
    required this.poinDibutuhkan,
    required this.tipe,
    required this.stok,
    required this.createdAt,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      rewardId: json['reward_id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      poinDibutuhkan: json['poin_dibutuhkan'] ?? 0,
      tipe: RewardType.values.firstWhere(
        (e) => e.toString().split('.').last == json['tipe'],
        orElse: () => RewardType.voucher,
      ),
      stok: json['stok'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reward_id': rewardId,
      'nama': nama,
      'deskripsi': deskripsi,
      'poin_dibutuhkan': poinDibutuhkan,
      'tipe': tipe.toString().split('.').last,
      'stok': stok,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Getter untuk kompatibilitas dengan kode yang sudah ada
  String get id => rewardId;
  String get merchantId => ''; // Tidak ada di database
  String get name => nama;
  String get description => deskripsi ?? '';
  String get imageUrl => ''; // Tidak ada di database
  int get pointsRequired => poinDibutuhkan;
  int get stock => stok;
  RewardCategory get category => _mapTypeToCategory(tipe);
  DateTime get validFrom => createdAt;
  DateTime get validUntil => createdAt.add(const Duration(days: 365)); // Default 1 tahun
  bool get isActive => true; // Default true
  Map<String, dynamic>? get metadata => null; // Tidak ada di database

  bool get isAvailable => isActive && stock > 0 && 
    DateTime.now().isAfter(validFrom) && 
    DateTime.now().isBefore(validUntil);

  RewardCategory _mapTypeToCategory(RewardType type) {
    switch (type) {
      case RewardType.voucher:
        return RewardCategory.voucher;
      case RewardType.barang:
        return RewardCategory.product;
      case RewardType.kredit:
        return RewardCategory.cashback;
    }
  }
}

enum RewardType { 
  voucher, 
  barang, 
  kredit 
}

enum RewardCategory { 
  voucher, 
  cashback, 
  product, 
  experience, 
  gift 
}