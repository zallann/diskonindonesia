import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/reward_model.dart';

class RewardsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  Future<List<RewardModel>> getAllRewards() async {
    try {
      final response = await _supabase
          .from('rewards')
          .select()
          .eq('is_active', true)
          .order('points_required', ascending: true);

      return response.map<RewardModel>((data) => RewardModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Get all rewards failed: $e');
    }
  }

  Future<List<RewardModel>> getUserRedeemedRewards(String userId) async {
    try {
      final response = await _supabase
          .from('redemptions')
          .select('*, rewards(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<RewardModel>((data) => RewardModel.fromJson(data['rewards']))
          .toList();
    } catch (e) {
      throw Exception('Get user redeemed rewards failed: $e');
    }
  }

  Future<bool> redeemReward(String userId, String rewardId) async {
    try {
      // Get user and reward data
      final user = await _supabase
          .from('users')
          .select('points_balance')
          .eq('id', userId)
          .single();

      final reward = await _supabase
          .from('rewards')
          .select()
          .eq('id', rewardId)
          .single();

      final userPoints = user['points_balance'];
      final requiredPoints = reward['points_required'];
      final stock = reward['stock'];

      // Validation
      if (userPoints < requiredPoints) {
        throw Exception('Insufficient points');
      }

      if (stock <= 0) {
        throw Exception('Reward out of stock');
      }

      // Check if reward is still valid
      final now = DateTime.now();
      final validFrom = DateTime.parse(reward['valid_from']);
      final validUntil = DateTime.parse(reward['valid_until']);

      if (now.isBefore(validFrom) || now.isAfter(validUntil)) {
        throw Exception('Reward not valid');
      }

      // Process redemption atomically
      await _supabase.rpc('process_reward_redemption', params: {
        'user_id_param': userId,
        'reward_id_param': rewardId,
        'points_required_param': requiredPoints,
      });

      return true;
    } catch (e) {
      throw Exception('Redeem reward failed: $e');
    }
  }

  Future<List<RewardModel>> getRewardsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('rewards')
          .select()
          .eq('category', category)
          .eq('is_active', true)
          .order('points_required', ascending: true);

      return response.map<RewardModel>((data) => RewardModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Get rewards by category failed: $e');
    }
  }

  Future<RewardModel?> getRewardById(String rewardId) async {
    try {
      final response = await _supabase
          .from('rewards')
          .select()
          .eq('id', rewardId)
          .single();

      return RewardModel.fromJson(response);
    } catch (e) {
      throw Exception('Get reward by ID failed: $e');
    }
  }

  Future<Map<String, dynamic>> getRedemptionHistory(String userId) async {
    try {
      final response = await _supabase
          .from('redemptions')
          .select('*, rewards(name, points_required)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return {
        'redemptions': response,
        'total_points_spent': response.fold<int>(
          0, 
          (sum, redemption) => sum + (redemption['rewards']['points_required'] as int)
        ),
      };
    } catch (e) {
      throw Exception('Get redemption history failed: $e');
    }
  }
}