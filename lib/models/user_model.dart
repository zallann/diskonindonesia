class UserModel {
  final String userId;
  final String email;
  final String? nama;
  final String? telepon;
  final String? kodeReferral;
  final int saldoPoin;
  final double saldoDompet;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.email,
    this.nama,
    this.telepon,
    this.kodeReferral,
    required this.saldoPoin,
    required this.saldoDompet,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      email: json['email'],
      nama: json['nama'],
      telepon: json['telepon'],
      kodeReferral: json['kode_referral'],
      saldoPoin: json['saldo_poin'] ?? 0,
      saldoDompet: (json['saldo_dompet'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'nama': nama,
      'telepon': telepon,
      'kode_referral': kodeReferral,
      'saldo_poin': saldoPoin,
      'saldo_dompet': saldoDompet,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? userId,
    String? email,
    String? nama,
    String? telepon,
    String? kodeReferral,
    int? saldoPoin,
    double? saldoDompet,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      telepon: telepon ?? this.telepon,
      kodeReferral: kodeReferral ?? this.kodeReferral,
      saldoPoin: saldoPoin ?? this.saldoPoin,
      saldoDompet: saldoDompet ?? this.saldoDompet,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getter untuk kompatibilitas dengan kode yang sudah ada
  String get id => userId;
  String? get fullName => nama;
  String? get phoneNumber => telepon;
  String? get profileImageUrl => null; // Tidak ada di database
  UserRole get role => UserRole.user; // Default role
  int get pointsBalance => saldoPoin;
  double get walletBalance => saldoDompet;
  DateTime? get lastCheckIn => null; // Tidak ada di database
  int get checkInStreak => 0; // Tidak ada di database
  DateTime? get lastSpinWheel => null; // Tidak ada di database
  String? get referralCode => kodeReferral;
  String? get referredBy => null; // Tidak ada di database
  bool get isEmailVerified => true; // Default true
  bool get isPhoneVerified => false; // Default false
}

enum UserRole { user, merchant, superadmin }