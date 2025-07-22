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
      double discountAmount = 0.0;
      
      // Apply coupon if provided
      if (couponId != null) {
        discountAmount = await _applyCoupon(couponId, amount);
      }

      final transactionId = _uuid.v4();
      
      await _supabase.from('transactions').insert({
        'id': transactionId,
        'user_id': userId,
        'merchant_id': merchantId,
        'amount': amount,
        'discount_amount': discountAmount,
        'coupon_id': couponId,
        'status': 'pending',
        'type': 'purchase',
        'description': description,
        'metadata': metadata,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('Create transaction failed: $e');
    }
  }

  Future<bool> verifyTransaction(String transactionId) async {
    try {
      await _supabase
          .from('transactions')
          .update({
            'status': 'verified',
            'verified_at': DateTime.now().toIso8601String(),
          })
          .eq('id', transactionId);

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
          .eq('id', transactionId)
          .single();

      final amount = transaction['amount'];
      final userId = transaction['user_id'];
      final cashbackAmount = amount * cashbackRate;

      // Update transaction with cashback
      await _supabase
          .from('transactions')
          .update({'cashback_amount': cashbackAmount})
          .eq('id', transactionId);

      // Add cashback to user wallet
      await _supabase.rpc('update_user_wallet', params: {
        'user_id': userId,
        'amount_to_add': cashbackAmount,
      });

      return true;
    } catch (e) {
      throw Exception('Process cashback failed: $e');
    }
  }

  Future<double> _applyCoupon(String couponId, double amount) async {
    try {
      final coupon = await _supabase
          .from('coupons')
          .select()
          .eq('id', couponId)
          .single();

      // Validate coupon
      final now = DateTime.now();
      final validFrom = DateTime.parse(coupon['valid_from']);
      final validUntil = DateTime.parse(coupon['valid_until']);
      final isActive = coupon['is_active'];
      final usageLimit = coupon['usage_limit'];
      final usedCount = coupon['used_count'];
      final minimumPurchase = coupon['minimum_purchase']?.toDouble();

      if (!isActive || 
          now.isBefore(validFrom) || 
          now.isAfter(validUntil) ||
          usedCount >= usageLimit ||
          (minimumPurchase != null && amount < minimumPurchase)) {
        return 0.0;
      }

      // Calculate discount
      final type = coupon['type'];
      final discountValue = coupon['discount_value'].toDouble();
      final maximumDiscount = coupon['maximum_discount']?.toDouble();

      double discount;
      if (type == 'percentage') {
        discount = amount * (discountValue / 100);
      } else {
        discount = discountValue;
      }

      if (maximumDiscount != null && discount > maximumDiscount) {
        discount = maximumDiscount;
      }

      // Update coupon usage
      await _supabase
          .from('coupons')
          .update({'used_count': usedCount + 1})
          .eq('id', couponId);

      return discount;
    } catch (e) {
      throw Exception('Apply coupon failed: $e');
    }
  }

  Future<Map<String, dynamic>> getTransactionStats({
    String? userId,
    String? merchantId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _supabase.rpc('get_transaction_stats', params: {
        'user_id_param': userId,
        'merchant_id_param': merchantId,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      });

      return response;
    } catch (e) {
      throw Exception('Get transaction stats failed: $e');
    }
  }
}