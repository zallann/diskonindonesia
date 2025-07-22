import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../config/app_config.dart';

class GamificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Random _random = Random();

  Future<Map<String, dynamic>?> performDailyCheckIn(String userId) async {
    try {
      // Get user data
      final user = await _supabase
          .from('users')
          .select('last_check_in, check_in_streak')
          .eq('id', userId)
          .single();

      final lastCheckIn = user['last_check_in'] != null 
          ? DateTime.parse(user['last_check_in'])
          : null;
      final currentStreak = user['check_in_streak'] ?? 0;

      // Check if user can check in
      if (lastCheckIn != null) {
        final timeDifference = DateTime.now().difference(lastCheckIn);
        if (timeDifference.inHours < 24) {
          throw Exception('Check-in already completed today');
        }
      }

      // Calculate new streak
      int newStreak = currentStreak + 1;
      bool streakBonus = false;
      int pointsEarned = AppConfig.dailyCheckInPoints;

      // Weekly streak bonus (7 days)
      if (newStreak % 7 == 0) {
        pointsEarned += AppConfig.weeklyStreakBonus;
        streakBonus = true;
      }

      // Update user data
      await _supabase.rpc('process_daily_checkin', params: {
        'user_id_param': userId,
        'points_to_add': pointsEarned,
        'new_streak': newStreak,
      });

      return {
        'success': true,
        'points_earned': pointsEarned,
        'new_streak': newStreak,
        'streak_bonus': streakBonus,
        'message': streakBonus 
            ? 'Daily check-in complete! Streak bonus earned!' 
            : 'Daily check-in complete!',
      };
    } catch (e) {
      throw Exception('Daily check-in failed: $e');
    }
  }

  Future<Map<String, dynamic>?> spinWheel(String userId) async {
    try {
      // Get user data
      final user = await _supabase
          .from('users')
          .select('last_spin_wheel')
          .eq('id', userId)
          .single();

      final lastSpin = user['last_spin_wheel'] != null 
          ? DateTime.parse(user['last_spin_wheel'])
          : null;

      // Check cooldown
      if (lastSpin != null) {
        final timeDifference = DateTime.now().difference(lastSpin);
        if (timeDifference.inHours < 24) {
          throw Exception('Spin wheel cooldown not finished');
        }
      }

      // Generate reward based on probability
      final reward = _generateSpinReward();

      // Update user data
      if (reward['type'] == 'points') {
        await _supabase.rpc('process_spin_wheel_points', params: {
          'user_id_param': userId,
          'points_to_add': reward['value'],
        });
      } else if (reward['type'] == 'coupon') {
        await _supabase.rpc('process_spin_wheel_coupon', params: {
          'user_id_param': userId,
          'coupon_id': reward['coupon_id'],
        });
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
      final response = await _supabase
          .rpc('get_user_gamification_progress', params: {
            'user_id_param': userId,
          });

      return response;
    } catch (e) {
      throw Exception('Get user progress failed: $e');
    }
  }

  Future<bool> completeMission(String userId, String missionId) async {
    try {
      await _supabase.rpc('complete_user_mission', params: {
        'user_id_param': userId,
        'mission_id_param': missionId,
      });

      return true;
    } catch (e) {
      throw Exception('Complete mission failed: $e');
    }
  }

  Future<void> updateMissionProgress(String userId, String missionType, int progress) async {
    try {
      await _supabase.rpc('update_mission_progress', params: {
        'user_id_param': userId,
        'mission_type_param': missionType,
        'progress_value': progress,
      });
    } catch (e) {
      throw Exception('Update mission progress failed: $e');
    }
  }
}