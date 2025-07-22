import 'package:flutter/material.dart';
import '../services/gamification_service.dart';
import '../config/app_config.dart';

class GamificationProvider extends ChangeNotifier {
  final GamificationService _gamificationService = GamificationService();
  
  bool _isLoading = false;
  Map<String, dynamic>? _spinWheelResult;
  Map<String, dynamic>? _checkInResult;
  List<Map<String, dynamic>> _missions = [];
  Map<String, dynamic> _userProgress = {};

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get spinWheelResult => _spinWheelResult;
  Map<String, dynamic>? get checkInResult => _checkInResult;
  List<Map<String, dynamic>> get missions => _missions;
  Map<String, dynamic> get userProgress => _userProgress;

  Future<bool> performDailyCheckIn(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _checkInResult = await _gamificationService.performDailyCheckIn(userId);
      
      return _checkInResult != null;
    } catch (e) {
      debugPrint('Error performing daily check-in: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> spinWheel(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _spinWheelResult = await _gamificationService.spinWheel(userId);
      
      return _spinWheelResult != null;
    } catch (e) {
      debugPrint('Error spinning wheel: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMissions(String userId) async {
    try {
      _missions = await _gamificationService.getUserMissions(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading missions: $e');
    }
  }

  Future<void> loadUserProgress(String userId) async {
    try {
      _userProgress = await _gamificationService.getUserProgress(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user progress: $e');
    }
  }

  Future<bool> completeMission(String userId, String missionId) async {
    try {
      final result = await _gamificationService.completeMission(userId, missionId);
      if (result) {
        // Reload missions and progress
        await loadMissions(userId);
        await loadUserProgress(userId);
      }
      return result;
    } catch (e) {
      debugPrint('Error completing mission: $e');
      return false;
    }
  }

  bool canCheckIn(DateTime? lastCheckIn) {
    if (lastCheckIn == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastCheckIn);
    
    return difference.inHours >= 24;
  }

  bool canSpinWheel(DateTime? lastSpin) {
    if (lastSpin == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastSpin);
    
    return difference.inHours >= 24;
  }

  void clearResults() {
    _spinWheelResult = null;
    _checkInResult = null;
    notifyListeners();
  }
}