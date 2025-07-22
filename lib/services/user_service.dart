import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      return response.map<UserModel>((data) => UserModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Get all users failed: $e');
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Get user by ID failed: $e');
    }
  }

  Future<bool> updateUserPoints(String userId, int pointsToAdd) async {
    try {
      final user = await _supabase
          .from('users')
          .select('saldo_poin')
          .eq('user_id', userId)
          .single();

      final currentPoints = user['saldo_poin'] ?? 0;

      await _supabase
          .from('users')
          .update({
            'saldo_poin': currentPoints + pointsToAdd,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      return true;
    } catch (e) {
      throw Exception('Update user points failed: $e');
    }
  }

  Future<bool> updateUserWallet(String userId, double amountToAdd) async {
    try {
      final user = await _supabase
          .from('users')
          .select('saldo_dompet')
          .eq('user_id', userId)
          .single();

      final currentWallet = (user['saldo_dompet'] ?? 0.0).toDouble();

      await _supabase
          .from('users')
          .update({
            'saldo_dompet': currentWallet + amountToAdd,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      return true;
    } catch (e) {
      throw Exception('Update user wallet failed: $e');
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .or('nama.ilike.%$query%,email.ilike.%$query%')
          .order('created_at', ascending: false);

      return response.map<UserModel>((data) => UserModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Search users failed: $e');
    }
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      // Get user basic info
      final user = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();

      // Get transaction stats
      final transactions = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId);

      // Get redemption stats
      final redemptions = await _supabase
          .from('redemptions')
          .select('*, reward(poin_dibutuhkan)')
          .eq('user_id', userId);

      double totalSpent = 0;
      double totalCashback = 0;
      int totalPointsEarned = 0;

      for (final transaction in transactions) {
        totalSpent += (transaction['jumlah'] ?? 0.0).toDouble();
        totalCashback += (transaction['jumlah_cashback'] ?? 0.0).toDouble();
        totalPointsEarned += transaction['poin_diperoleh'] ?? 0;
      }

      int totalPointsRedeemed = 0;
      for (final redemption in redemptions) {
        totalPointsRedeemed += redemption['reward']['poin_dibutuhkan'] ?? 0;
      }

      return {
        'user': UserModel.fromJson(user),
        'total_transactions': transactions.length,
        'total_spent': totalSpent,
        'total_cashback': totalCashback,
        'total_points_earned': totalPointsEarned,
        'total_points_redeemed': totalPointsRedeemed,
        'total_redemptions': redemptions.length,
      };
    } catch (e) {
      throw Exception('Get user stats failed: $e');
    }
  }
}