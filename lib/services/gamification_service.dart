import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../config/app_config.dart';

class GamificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Random _random = Random();

  Future<Map<String, dynamic>?> performDailyCheckIn(String userId) async {
    try {
      // For now, just give points directly since we don't have check-in tracking in the database
      final pointsEarned = AppConfig.dailyCheckInPoints;

      // Update user points
      final user = await _supabase
          .from('users')
          .select('saldo_poin')
          .eq('user_id', userId)
          .single();

      final currentPoints = user['saldo_poin'] ?? 0;

      await _supabase
          .from('users')
          .update({
            'saldo_poin': currentPoints + pointsEarned,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      return {
        'success': true,
        'points_earned': pointsEarned,
        'new_streak': 1, // Default streak
        'streak_bonus': false,
        'message': 'Daily check-in complete!',
      };
    } catch (e) {
      throw Exception('Daily check-in failed: $e');
    }
  }

  Future<Map<String, dynamic>?> spinWheel(String userId) async {
    try {
      // Generate reward based on probability
      final reward = _generateSpinReward();

      // Update user data
      if (reward['type'] == 'points') {
        final user = await _supabase
            .from('users')
            .select('saldo_poin')
            .eq('user_id', userId)
            .single();

        final currentPoints = user['saldo_poin'] ?? 0;

        await _supabase
            .from('users')
            .update({
              'saldo_poin': currentPoints + reward['value'],
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId);
      }

      return {
        'success': true,
        'reward_type': reward['type'],
        'reward_value': reward['value'],
        'reward_message': reward['message'],
        'coupon_id': reward['coupon_id'],
      };
    } catch (e) {
      throw Exception('Spin wheel failed: $e');
    }
  }

  Map<String, dynamic> _generateSpinReward() {
    final randomValue = _random.nextDouble();
    final rewards = AppConfig.spinRewards;

    // Low tier (5-10 points) - 50%
    if (randomValue < rewards['low']['probability']) {
      final points = _random.nextInt(
        rewards['low']['max'] - rewards['low']['min'] + 1
      ) + rewards['low']['min'];
      
      return {
        'type': 'points',
        'value': points,
        'message': 'You won $points points!',
        'coupon_id': null,
      };
    }

    // Medium tier (11-20 points) - 30%
    if (randomValue < rewards['low']['probability'] + rewards['medium']['probability']) {
      final points = _random.nextInt(
        rewards['medium']['max'] - rewards['medium']['min'] + 1
      ) + rewards['medium']['min'];
      
      return {
        'type': 'points',
        'value': points,
        'message': 'You won $points points!',
        'coupon_id': null,
      };
    }

    // High tier (21-30 points) - 15%
    if (randomValue < rewards['low']['probability'] + 
        rewards['medium']['probability'] + rewards['high']['probability']) {
      final points = _random.nextInt(
        rewards['high']['max'] - rewards['high']['min'] + 1
      ) + rewards['high']['min'];
      
      return {
        'type': 'points',
        'value': points,
        'message': 'You won $points points!',
        'coupon_id': null,
      };
    }

    // Coupon tier - 5%
    return {
      'type': 'coupon',
      'value': 0,
      'message': 'You won a special coupon!',
      'coupon_id': 'SPIN_WHEEL_COUPON',
    };
  }

  Future<List<Map<String, dynamic>>> getUserMissions(String userId) async {
    try {
      final response = await _supabase
          .from('user_missions')
          .select('*, missions(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Get user missions failed: $e');
    }
  }

  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    try {
      // Get user stats
      final user = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();

      final transactions = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId);

      final redemptions = await _supabase
          .from('redemptions')
          .select()
          .eq('user_id', userId);

      return {
        'total_points': user['saldo_poin'] ?? 0,
        'total_transactions': transactions.length,
        'total_redemptions': redemptions.length,
        'wallet_balance': user['saldo_dompet'] ?? 0.0,
      };
    } catch (e) {
      throw Exception('Get user progress failed: $e');
    }
  }

  Future<bool> completeMission(String userId, String missionId) async {
    try {
      // Update mission status
      await _supabase
          .from('user_missions')
          .update({'status': 'selesai'})
          .eq('user_id', userId)
          .eq('mission_id', missionId);

      // Get mission reward
      final mission = await _supabase
          .from('missions')
          .select('poin_hadiah')
          .eq('mission_id', missionId)
          .single();

      final pointsReward = mission['poin_hadiah'] ?? 0;

      // Update user points
      if (pointsReward > 0) {
        final user = await _supabase
            .from('users')
            .select('saldo_poin')
            .eq('user_id', userId)
            .single();

        final currentPoints = user['saldo_poin'] ?? 0;

        await _supabase
            .from('users')
            .update({
              'saldo_poin': currentPoints + pointsReward,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId);
      }

      return true;
    } catch (e) {
      throw Exception('Complete mission failed: $e');
    }
  }

  Future<void> updateMissionProgress(String userId, String missionType, int progress) async {
    try {
      // This would update mission progress based on user actions
      // For now, we'll just log it since the implementation depends on specific mission criteria
      print('Mission progress updated: $userId, $missionType, $progress');
    } catch (e) {
      throw Exception('Update mission progress failed: $e');
    }
  }
}