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
          .eq('id', userId)
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
      final updateData = <String, dynamic>{};
      
      if (fullName != null) updateData['full_name'] = fullName;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (profileImageUrl != null) updateData['profile_image_url'] = profileImageUrl;

      final response = await _supabase
          .from('users')
          .update(updateData)
          .eq('id', userId)
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
        'id': userId,
        'email': email,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'role': 'user',
        'points_balance': 0,
        'wallet_balance': 0.0,
        'check_in_streak': 0,
        'referral_code': userReferralCode,
        'referred_by': referralCode,
        'is_email_verified': false,
        'is_phone_verified': false,
        'created_at': DateTime.now().toIso8601String(),
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
          .select('id')
          .eq('referral_code', referralCode)
          .maybeSingle();

      if (referrerResponse != null) {
        final referrerId = referrerResponse['id'];

        // Create referral record
        await _supabase.from('referrals').insert({
          'id': _uuid.v4(),
          'referrer_id': referrerId,
          'referee_id': newUserId,
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        });

        // Give bonus points to both users
        await _supabase.rpc('update_user_points', params: {
          'user_id': referrerId,
          'points_to_add': 100,
        });

        await _supabase.rpc('update_user_points', params: {
          'user_id': newUserId,
          'points_to_add': 100,
        });
      }
    } catch (e) {
      // Don't throw here as it's not critical for signup
      print('Referral processing error: $e');
    }
  }

  String _generateReferralCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = _uuid.v4().substring(0, 8).toUpperCase();
    return 'REF$random';
  }
}