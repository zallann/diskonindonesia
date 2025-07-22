class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final UserRole role;
  final int pointsBalance;
  final double walletBalance;
  final DateTime createdAt;
  final DateTime? lastCheckIn;
  final int checkInStreak;
  final DateTime? lastSpinWheel;
  final String? referralCode;
  final String? referredBy;
  final bool isEmailVerified;
  final bool isPhoneVerified;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.profileImageUrl,
    required this.role,
    required this.pointsBalance,
    required this.walletBalance,
    required this.createdAt,
    this.lastCheckIn,
    required this.checkInStreak,
    this.lastSpinWheel,
    this.referralCode,
    this.referredBy,
    required this.isEmailVerified,
    required this.isPhoneVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      profileImageUrl: json['profile_image_url'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.user,
      ),
      pointsBalance: json['points_balance'] ?? 0,
      walletBalance: (json['wallet_balance'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      lastCheckIn: json['last_check_in'] != null 
        ? DateTime.parse(json['last_check_in']) 
        : null,
      checkInStreak: json['check_in_streak'] ?? 0,
      lastSpinWheel: json['last_spin_wheel'] != null 
        ? DateTime.parse(json['last_spin_wheel']) 
        : null,
      referralCode: json['referral_code'],
      referredBy: json['referred_by'],
      isEmailVerified: json['is_email_verified'] ?? false,
      isPhoneVerified: json['is_phone_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'role': role.toString().split('.').last,
      'points_balance': pointsBalance,
      'wallet_balance': walletBalance,
      'created_at': createdAt.toIso8601String(),
      'last_check_in': lastCheckIn?.toIso8601String(),
      'check_in_streak': checkInStreak,
      'last_spin_wheel': lastSpinWheel?.toIso8601String(),
      'referral_code': referralCode,
      'referred_by': referredBy,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
    UserRole? role,
    int? pointsBalance,
    double? walletBalance,
    DateTime? createdAt,
    DateTime? lastCheckIn,
    int? checkInStreak,
    DateTime? lastSpinWheel,
    String? referralCode,
    String? referredBy,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      pointsBalance: pointsBalance ?? this.pointsBalance,
      walletBalance: walletBalance ?? this.walletBalance,
      createdAt: createdAt ?? this.createdAt,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      checkInStreak: checkInStreak ?? this.checkInStreak,
      lastSpinWheel: lastSpinWheel ?? this.lastSpinWheel,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
    );
  }
}

enum UserRole { user, merchant, superadmin }