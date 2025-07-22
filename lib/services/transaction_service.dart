import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .order('created_at', ascending: false);

      return response.map<TransactionModel>((data) => TransactionModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Get all transactions failed: $e');
    }
  }

  Future<List<TransactionModel>> getUserTransactions(String userId) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<TransactionModel>((data) => TransactionModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Get user transactions failed: $e');
    }
  }

  Future<bool> createTransaction({
    required String userId,
    required String merchantId,
    required double amount,
    required String description,
    String? couponId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final transactionId = _uuid.v4();
      
      // Calculate points (1 point per 1000 rupiah)
      final points = (amount / 1000).floor();
      
      // Calculate cashback (5% of amount)
      final cashback = amount * 0.05;
      
      await _supabase.from('transactions').insert({
        'transaction_id': transactionId,
        'user_id': userId,
        'tenant_id': merchantId,
        'jumlah': amount,
        'poin_diperoleh': points,
        'jumlah_cashback': cashback,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('Create transaction failed: $e');
    }
  }

  Future<bool> verifyTransaction(String transactionId) async {
    try {
      // Get transaction details
      final transaction = await _supabase
          .from('transactions')
          .select()
          .eq('transaction_id', transactionId)
          .single();

      // Update transaction status
      await _supabase
          .from('transactions')
          .update({'status': 'terverifikasi'})
          .eq('transaction_id', transactionId);

      // Update user points and wallet
      final userId = transaction['user_id'];
      final points = transaction['poin_diperoleh'] ?? 0;
      final cashback = transaction['jumlah_cashback'] ?? 0.0;

      await _updateUserBalance(userId, points, cashback);

      return true;
    } catch (e) {
      throw Exception('Verify transaction failed: $e');
    }
  }

  Future<bool> processCashback(String transactionId, double cashbackRate) async {
    try {
      // Get transaction details
      final transaction = await _supabase
          .from('transactions')
          .select()
          .eq('transaction_id', transactionId)
          .single();

      final amount = transaction['jumlah'];
      final userId = transaction['user_id'];
      final cashbackAmount = amount * cashbackRate;

      // Update transaction with cashback
      await _supabase
          .from('transactions')
          .update({'jumlah_cashback': cashbackAmount})
          .eq('transaction_id', transactionId);

      // Add cashback to user wallet
      await _updateUserWallet(userId, cashbackAmount);

      return true;
    } catch (e) {
      throw Exception('Process cashback failed: $e');
    }
  }

  Future<void> _updateUserBalance(String userId, int points, double cashback) async {
    try {
      final user = await _supabase
          .from('users')
          .select('saldo_poin, saldo_dompet')
          .eq('user_id', userId)
          .single();

      final currentPoints = user['saldo_poin'] ?? 0;
      final currentWallet = (user['saldo_dompet'] ?? 0.0).toDouble();

      await _supabase
          .from('users')
          .update({
            'saldo_poin': currentPoints + points,
            'saldo_dompet': currentWallet + cashback,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Update user balance failed: $e');
    }
  }

  Future<void> _updateUserWallet(String userId, double amount) async {
    try {
      final user = await _supabase
          .from('users')
          .select('saldo_dompet')
          .eq('user_id', userId)
          .single();

      final currentWallet = (user['saldo_dompet'] ?? 0.0).toDouble();

      await _supabase
          .from('users')
          .update({
            'saldo_dompet': currentWallet + amount,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Update user wallet failed: $e');
    }
  }

  Future<Map<String, dynamic>> getTransactionStats({
    String? userId,
    String? merchantId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('transactions').select();

      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      if (merchantId != null) {
        query = query.eq('tenant_id', merchantId);
      }
      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;

      double totalAmount = 0;
      double totalCashback = 0;
      int totalPoints = 0;
      int totalTransactions = response.length;

      for (final transaction in response) {
        totalAmount += (transaction['jumlah'] ?? 0.0).toDouble();
        totalCashback += (transaction['jumlah_cashback'] ?? 0.0).toDouble();
        totalPoints += transaction['poin_diperoleh'] ?? 0;
      }

      return {
        'total_transactions': totalTransactions,
        'total_amount': totalAmount,
        'total_cashback': totalCashback,
        'total_points': totalPoints,
      };
    } catch (e) {
      throw Exception('Get transaction stats failed: $e');
    }
  }
}