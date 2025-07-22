import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  
  bool _isLoading = false;
  List<UserModel> _users = [];
  UserModel? _selectedUser;

  bool get isLoading => _isLoading;
  List<UserModel> get users => _users;
  UserModel? get selectedUser => _selectedUser;

  Future<void> loadUsers() async {
    try {
      _isLoading = true;
      notifyListeners();

      _users = await _userService.getAllUsers();
    } catch (e) {
      debugPrint('Error loading users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectUser(String userId) async {
    try {
      _selectedUser = await _userService.getUserById(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error selecting user: $e');
    }
  }

  Future<bool> updateUserPoints(String userId, int points) async {
    try {
      final result = await _userService.updateUserPoints(userId, points);
      if (result) {
        // Reload user data
        await selectUser(userId);
      }
      return result;
    } catch (e) {
      debugPrint('Error updating user points: $e');
      return false;
    }
  }

  Future<bool> updateUserWallet(String userId, double amount) async {
    try {
      final result = await _userService.updateUserWallet(userId, amount);
      if (result) {
        // Reload user data
        await selectUser(userId);
      }
      return result;
    } catch (e) {
      debugPrint('Error updating user wallet: $e');
      return false;
    }
  }

  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }
}