import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentSupabaseUser;
  UserModel? _currentUser;
  bool _isLoading = true;

  User? get currentSupabaseUser => _currentSupabaseUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentSupabaseUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  // Di dalam class AuthProvider
Future<void> loadUserProfile() async {
  return _loadUserProfile();
}

  Future<void> _initializeAuth() async {
    try {
      _currentSupabaseUser = Supabase.instance.client.auth.currentUser;
      
      if (_currentSupabaseUser != null) {
        await _loadUserProfile();
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Listen to auth changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  _currentSupabaseUser = data.session?.user; // ✅ Pakai session?.user
  if (_currentSupabaseUser != null) {
    _loadUserProfile();
  } else {
    _currentUser = null;
  }
  notifyListeners();
});
  }

  Future<void> _loadUserProfile() async {
    try {
      if (_currentSupabaseUser != null) {
        _currentUser = await _authService.getUserProfile(_currentSupabaseUser!.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? referralCode,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        referralCode: referralCode,
      );

      return result;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      return result;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentSupabaseUser = null;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      return await _authService.resetPassword(email);
    } catch (e) {
      debugPrint('Reset password error: $e');
      return false;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      if (_currentUser == null) return false;

      final updatedUser = await _authService.updateUserProfile(
        userId: _currentUser!.id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return false;
    }
  }
}