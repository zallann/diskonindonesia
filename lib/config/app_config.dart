class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://kxzcxxbzlxfeqxkybrfx.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt4emN4eGJ6bHhmZXF4a3licmZ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMwNzg1NTQsImV4cCI6MjA2ODY1NDU1NH0.YMJCI8jXn6G7L3t-xuRs8KvSl1wjXFTR8uNLr84E5DU';
  
  // App Configuration
  static const String appName = 'Diskon Indonesia';
  static const String appVersion = '1.0.0';
  
  // Gamification Settings
  static const int dailyCheckInPoints = 10;
  static const int referralBonusPoints = 100;
  static const int weeklyStreakBonus = 50;
  
  // Cashback Settings
  static const double defaultCashbackRate = 0.05; // 5%
  static const int cashbackDelayDays = 7;
  
  // Spin Wheel Rewards
  static const Map<String, dynamic> spinRewards = {
    'low': {'min': 5, 'max': 10, 'probability': 0.5},
    'medium': {'min': 11, 'max': 20, 'probability': 0.3},
    'high': {'min': 21, 'max': 30, 'probability': 0.15},
    'coupon': {'probability': 0.05},
  };
  
  // Storage Buckets
  static const String appAssetsBucket = 'app-assets';
  static const String userContentBucket = 'user-content';
}