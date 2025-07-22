import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? referralCode,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
          referralCode: referralCode,
        );

        return true;
      }

      return false;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.user != null;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Get user profile failed: $e');
    }
  }

  Future<UserModel?> updateUserProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (fullName != null) updateData['nama'] = fullName;
      if (phoneNumber != null) updateData['telepon'] = phoneNumber;

      final response = await _supabase
          .from('users')
          .update(updateData)
          .eq('user_id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Update user profile failed: $e');
    }
  }

  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phoneNumber,
    String? referralCode,
  }) async {
    try {
      final userReferralCode = _generateReferralCode();
      
      await _supabase.from('users').insert({
        'user_id': userId,
        'email': email,
        'nama': fullName,
        'telepon': phoneNumber,
        'kode_referral': userReferralCode,
        'saldo_poin': 0,
        'saldo_dompet': 0.0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Process referral if provided
      if (referralCode != null) {
        await _processReferral(userId, referralCode);
      }
    } catch (e) {
      throw Exception('Create user profile failed: $e');
    }
  }

  Future<void> _processReferral(String newUserId, String referralCode) async {
    try {
      // Find referrer
      final referrerResponse = await _supabase
          .from('users')
          .select('user_id')
          .eq('kode_referral', referralCode)
          .maybeSingle();

      if (referrerResponse != null) {
        final referrerId = referrerResponse['user_id'];

        // Create referral record
        await _supabase.from('referral').insert({
          'referral_id': _uuid.v4(),
          'referrer_id': referrerId,
          'referee_id': newUserId,
          'poin_bonus': 100,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Give bonus points to both users
        await _updateUserPoints(referrerId, 100);
        await _updateUserPoints(newUserId, 100);
      }
    } catch (e) {
      // Don't throw here as it's not critical for signup
      print('Referral processing error: $e');
    }
  }

  Future<void> _updateUserPoints(String userId, int points) async {
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
            'saldo_poin': currentPoints + points,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Update user points failed: $e');
    }
  }

  String _generateReferralCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = _uuid.v4().substring(0, 8).toUpperCase();
    return 'REF$random';
  }
}