import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_theme.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      await context.read<TransactionProvider>().loadUserTransactions(
        authProvider.currentUser!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryRed,
          unselectedLabelColor: AppTheme.neutralGray500,
          indicatorColor: AppTheme.primaryRed,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Berhasil'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsList(filter: null),
          _buildTransactionsList(filter: 'verified'),
          _buildTransactionsList(filter: 'pending'),
        ],
      ),
    );
  }

  Widget _buildTransactionsList({String? filter}) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, _) {
        if (transactionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        var transactions = transactionProvider.userTransactions;
        
        if (filter != null) {
          transactions = transactions.where((t) => t.status.name == filter).toList();
        }

        if (transactions.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _loadTransactions,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Card
              _buildSummaryCard(transactions),
              
              const SizedBox(height: 24),

              // Transaction List
              ...transactions.map((transaction) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTransactionCard(transaction),
                )
              ).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppTheme.neutralGray400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Transaksi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.neutralGray600,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai berbelanja dan dapatkan cashback menarik!',
            style: TextStyle(
              color: AppTheme.neutralGray500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to merchants or shopping
            },
            child: const Text('Mulai Belanja'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List transactions) {
    final totalAmount = transactions.fold<double>(
      0.0, 
      (sum, transaction) => sum + transaction.amount,
    );
    
    final totalCashback = transactions.fold<double>(
      0.0,
      (sum, transaction) => sum + (transaction.cashbackAmount ?? 0.0),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration.copyWith(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryRed, AppTheme.accentGold],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Ringkasan Transaksi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Belanja',
                  'Rp ${NumberFormat('#,###').format(totalAmount)}',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Total Cashback',
                  'Rp ${NumberFormat('#,###').format(totalCashback)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(transaction) {
    final statusColor = _getStatusColor(transaction.status.name);
    final statusIcon = _getStatusIcon(transaction.status.name);

    return Container(
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${transaction.id.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                          color: AppTheme.neutralGray500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(transaction.status.name),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Amount and Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah',
                        style: const TextStyle(
                          color: AppTheme.neutralGray600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${NumberFormat('#,###').format(transaction.amount)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                if (transaction.cashbackAmount != null && transaction.cashbackAmount > 0)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Cashback',
                          style: const TextStyle(
                            color: AppTheme.neutralGray600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${NumberFormat('#,###').format(transaction.cashbackAmount)}',
                          style: const TextStyle(
                            color: AppTheme.successGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            if (transaction.discountAmount != null && transaction.discountAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.local_offer,
                    color: AppTheme.accentGold,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Diskon: Rp ${NumberFormat('#,###').format(transaction.discountAmount)}',
                    style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Date
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  color: AppTheme.neutralGray500,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _dateFormat.format(transaction.createdAt),
                  style: const TextStyle(
                    color: AppTheme.neutralGray500,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showTransactionDetails(transaction),
                  child: const Text(
                    'Lihat Detail',
                    style: TextStyle(
                      color: AppTheme.primaryRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified':
        return AppTheme.successGreen;
      case 'pending':
        return AppTheme.warningOrange;
      case 'cancelled':
        return AppTheme.errorRed;
      case 'disputed':
        return AppTheme.errorRed;
      case 'refunded':
        return AppTheme.neutralGray600;
      default:
        return AppTheme.neutralGray500;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'verified':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      case 'disputed':
        return Icons.warning;
      case 'refunded':
        return Icons.undo;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'verified':
        return 'Berhasil';
      case 'pending':
        return 'Menunggu';
      case 'cancelled':
        return 'Dibatalkan';
      case 'disputed':
        return 'Sengketa';
      case 'refunded':
        return 'Dikembalikan';
      default:
        return 'Unknown';
    }
  }

  void _showTransactionDetails(transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.neutralGray300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Detail Transaksi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 24),

                _buildDetailRow('ID Transaksi', transaction.id),
                _buildDetailRow('Deskripsi', transaction.description),
                _buildDetailRow('Jumlah', 'Rp ${NumberFormat('#,###').format(transaction.amount)}'),
                
                if (transaction.discountAmount != null && transaction.discountAmount > 0)
                  _buildDetailRow('Diskon', 'Rp ${NumberFormat('#,###').format(transaction.discountAmount)}'),
                
                if (transaction.cashbackAmount != null && transaction.cashbackAmount > 0)
                  _buildDetailRow('Cashback', 'Rp ${NumberFormat('#,###').format(transaction.cashbackAmount)}'),
                
                _buildDetailRow('Status', _getStatusText(transaction.status.name)),
                _buildDetailRow('Tanggal', _dateFormat.format(transaction.createdAt)),
                
                if (transaction.verifiedAt != null)
                  _buildDetailRow('Diverifikasi', _dateFormat.format(transaction.verifiedAt)),

                const Spacer(),

                if (transaction.status.name == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Cancel transaction
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorRed,
                          ),
                          child: const Text('Batalkan'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Contact support
                          },
                          child: const Text('Hubungi CS'),
                        ),
                      ),
                    ],
                  ),

                if (transaction.status.name == 'verified')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Download receipt
                      },
                      child: const Text('Download Struk'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.neutralGray600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}