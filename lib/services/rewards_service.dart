import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/reward_model.dart';

class RewardsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  Future<List<RewardModel>> getAllRewards() async {
    try {
      final response = await _supabase
          .from('reward')
          .select()
          .gt('stok', 0)
          .order('poin_dibutuhkan', ascending: true);

      return response.map<RewardModel>((data) => RewardModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Get all rewards failed: $e');
    }
  }

  Future<List<RewardModel>> getUserRedeemedRewards(String userId) async {
    try {
      final response = await _supabase
          .from('redemptions')
          .select('*, reward(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<RewardModel>((data) => RewardModel.fromJson(data['reward']))
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
          .select('saldo_poin')
          .eq('user_id', userId)
          .single();

      final reward = await _supabase
          .from('reward')
          .select()
          .eq('reward_id', rewardId)
          .single();

      final userPoints = user['saldo_poin'];
      final requiredPoints = reward['poin_dibutuhkan'];
      final stock = reward['stok'];

      // Validation
      if (userPoints < requiredPoints) {
        throw Exception('Insufficient points');
      }

      if (stock <= 0) {
        throw Exception('Reward out of stock');
      }

      // Create redemption record
      final redemptionId = _uuid.v4();
      final redemptionCode = _generateRedemptionCode();

      await _supabase.from('redemptions').insert({
        'redemption_id': redemptionId,
        'user_id': userId,
        'reward_id': rewardId,
        'kode_penukaran': redemptionCode,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update user points
      await _supabase
          .from('users')
          .update({
            'saldo_poin': userPoints - requiredPoints,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      // Update reward stock
      await _supabase
          .from('reward')
          .update({'stok': stock - 1})
          .eq('reward_id', rewardId);

      return true;
    } catch (e) {
      throw Exception('Redeem reward failed: $e');
    }
  }

  Future<List<RewardModel>> getRewardsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('reward')
          .select()
          .eq('tipe', category)
          .gt('stok', 0)
          .order('poin_dibutuhkan', ascending: true);

      return response.map<RewardModel>((data) => RewardModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Get rewards by category failed: $e');
    }
  }

  Future<RewardModel?> getRewardById(String rewardId) async {
    try {
      final response = await _supabase
          .from('reward')
          .select()
          .eq('reward_id', rewardId)
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
          .select('*, reward(nama, poin_dibutuhkan)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return {
        'redemptions': response,
        'total_points_spent': response.fold<int>(
          0, 
          (sum, redemption) => sum + (redemption['reward']['poin_dibutuhkan'] as int)
        ),
      };
    } catch (e) {
      throw Exception('Get redemption history failed: $e');
    }
  }

  String _generateRedemptionCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = _uuid.v4().substring(0, 8).toUpperCase();
    return 'RDM$random';
  }
}