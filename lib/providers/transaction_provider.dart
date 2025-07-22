import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  
  bool _isLoading = false;
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _userTransactions = [];

  bool get isLoading => _isLoading;
  List<TransactionModel> get transactions => _transactions;
  List<TransactionModel> get userTransactions => _userTransactions;

  Future<void> loadTransactions() async {
    try {
      _isLoading = true;
      notifyListeners();

      _transactions = await _transactionService.getAllTransactions();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserTransactions(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _userTransactions = await _transactionService.getUserTransactions(userId);
    } catch (e) {
      debugPrint('Error loading user transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
      final result = await _transactionService.createTransaction(
        userId: userId,
        merchantId: merchantId,
        amount: amount,
        description: description,
        couponId: couponId,
        metadata: metadata,
      );

      if (result) {
        // Reload transactions
        await loadUserTransactions(userId);
      }

      return result;
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      return false;
    }
  }

  Future<bool> verifyTransaction(String transactionId) async {
    try {
      final result = await _transactionService.verifyTransaction(transactionId);
      if (result) {
        // Reload transactions
        await loadTransactions();
      }
      return result;
    } catch (e) {
      debugPrint('Error verifying transaction: $e');
      return false;
    }
  }

  Future<bool> processCashback(String transactionId, double cashbackRate) async {
    try {
      final result = await _transactionService.processCashback(transactionId, cashbackRate);
      if (result) {
        // Reload transactions
        await loadTransactions();
      }
      return result;
    } catch (e) {
      debugPrint('Error processing cashback: $e');
      return false;
    }
  }
}