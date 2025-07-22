import 'package:flutter/material.dart';
import '../models/reward_model.dart';
import '../services/rewards_service.dart';

class RewardsProvider extends ChangeNotifier {
  final RewardsService _rewardsService = RewardsService();
  
  bool _isLoading = false;
  List<RewardModel> _rewards = [];
  List<RewardModel> _userRedeemedRewards = [];

  bool get isLoading => _isLoading;
  List<RewardModel> get rewards => _rewards;
  List<RewardModel> get availableRewards => _rewards.where((r) => r.isAvailable).toList();
  List<RewardModel> get userRedeemedRewards => _userRedeemedRewards;

  Future<void> loadRewards() async {
    try {
      _isLoading = true;
      notifyListeners();

      _rewards = await _rewardsService.getAllRewards();
    } catch (e) {
      debugPrint('Error loading rewards: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserRedeemedRewards(String userId) async {
    try {
      _userRedeemedRewards = await _rewardsService.getUserRedeemedRewards(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user redeemed rewards: $e');
    }
  }

  Future<bool> redeemReward(String userId, String rewardId) async {
    try {
      final result = await _rewardsService.redeemReward(userId, rewardId);
      if (result) {
        // Reload rewards and user redemptions
        await loadRewards();
        await loadUserRedeemedRewards(userId);
      }
      return result;
    } catch (e) {
      debugPrint('Error redeeming reward: $e');
      return false;
    }
  }

  List<RewardModel> getRewardsByCategory(RewardCategory category) {
    return _rewards.where((reward) => reward.category == category && reward.isAvailable).toList();
  }

  RewardModel? getRewardById(String rewardId) {
    try {
      return _rewards.firstWhere((reward) => reward.id == rewardId);
    } catch (e) {
      return null;
    }
  }
}