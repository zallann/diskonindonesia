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
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Get user by ID failed: $e');
    }
  }

  Future<bool> updateUserPoints(String userId, int pointsToAdd) async {
    try {
      await _supabase.rpc('update_user_points', params: {
        'user_id': userId,
        'points_to_add': pointsToAdd,
      });

      return true;
    } catch (e) {
      throw Exception('Update user points failed: $e');
    }
  }

  Future<bool> updateUserWallet(String userId, double amountToAdd) async {
    try {
      await _supabase.rpc('update_user_wallet', params: {
        'user_id': userId,
        'amount_to_add': amountToAdd,
      });

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
          .or('full_name.ilike.%$query%,email.ilike.%$query%')
          .order('created_at', ascending: false);

      return response.map<UserModel>((data) => UserModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Search users failed: $e');
    }
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final response = await _supabase
          .rpc('get_user_stats', params: {'user_id': userId});

      return response;
    } catch (e) {
      throw Exception('Get user stats failed: $e');
    }
  }
}