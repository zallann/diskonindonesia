import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rewards_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/reward_model.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRewards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRewards() async {
    final authProvider = context.read<AuthProvider>();
    final rewardsProvider = context.read<RewardsProvider>();
    
    await rewardsProvider.loadRewards();
    
    if (authProvider.currentUser != null) {
      await rewardsProvider.loadUserRedeemedRewards(
        authProvider.currentUser!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryRed,
          unselectedLabelColor: AppTheme.neutralGray500,
          indicatorColor: AppTheme.primaryRed,
          tabs: const [
            Tab(text: 'Katalog'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCatalogTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildCatalogTab() {
    return Consumer2<RewardsProvider, AuthProvider>(
      builder: (context, rewardsProvider, authProvider, _) {
        if (rewardsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final rewards = rewardsProvider.availableRewards;
        final userPoints = authProvider.currentUser?.saldoPoin ?? 0;

        return RefreshIndicator(
          onRefresh: _loadRewards,
          child: CustomScrollView(
            slivers: [
              // Points Balance Header
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.gradientDecoration.copyWith(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.stars,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Poin Anda',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              NumberFormat('#,###').format(userPoints),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Show ways to earn points
                          _showEarnPointsModal();
                        },
                        child: const Text(
                          'Cara Dapatkan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories Filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildCategoriesFilter(),
                ),
              ),

              // Rewards Grid
              if (rewards.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyRewards(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final reward = rewards[index];
                        return _buildRewardCard(reward, userPoints);
                      },
                      childCount: rewards.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<RewardsProvider>(
      builder: (context, rewardsProvider, _) {
        final redeemedRewards = rewardsProvider.userRedeemedRewards;

        if (redeemedRewards.isEmpty) {
          return _buildEmptyHistory();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: redeemedRewards.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final reward = redeemedRewards[index];
            return _buildHistoryCard(reward);
          },
        );
      },
    );
  }

  Widget _buildCategoriesFilter() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: RewardCategory.values.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(_getCategoryName(category)),
              selected: false, // TODO: Implement filter state
              onSelected: (selected) {
                // TODO: Implement category filtering
              },
              selectedColor: AppTheme.primaryRed.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryRed,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryName(RewardCategory category) {
    switch (category) {
      case RewardCategory.voucher:
        return 'Voucher';
      case RewardCategory.cashback:
        return 'Cashback';
      case RewardCategory.product:
        return 'Produk';
      case RewardCategory.experience:
        return 'Pengalaman';
      case RewardCategory.gift:
        return 'Hadiah';
    }
  }

  Widget _buildRewardCard(RewardModel reward, int userPoints) {
    final canRedeem = userPoints >= reward.poinDibutuhkan && reward.isAvailable;

    return GestureDetector(
      onTap: () => _showRewardDetails(reward, canRedeem),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: AppTheme.neutralGray100,
                child: reward.imageUrl.isNotEmpty
                    ? Image.network(
                        reward.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.card_giftcard,
                            size: 40,
                            color: AppTheme.neutralGray500,
                          );
                        },
                      )
                    : const Icon(
                        Icons.card_giftcard,
                        size: 40,
                        color: AppTheme.neutralGray500,
                      ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.nama,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      reward.deskripsi ?? '',
                      style: const TextStyle(
                        color: AppTheme.neutralGray600,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Points and Stock
                    Row(
                      children: [
                        const Icon(
                          Icons.stars,
                          color: AppTheme.accentGold,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          NumberFormat('#,###').format(reward.poinDibutuhkan),
                          style: TextStyle(
                            color: canRedeem ? AppTheme.primaryRed : AppTheme.neutralGray500,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: reward.stok > 0 
                                ? AppTheme.successGreen.withOpacity(0.1) 
                                : AppTheme.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Stok: ${reward.stok}',
                            style: TextStyle(
                              color: reward.stok > 0 ? AppTheme.successGreen : AppTheme.errorRed,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (!canRedeem && userPoints < reward.poinDibutuhkan)
                          const Icon(
                            Icons.lock,
                            color: AppTheme.neutralGray400,
                            size: 16,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(RewardModel reward) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.neutralGray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: reward.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        reward.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.card_giftcard,
                            color: AppTheme.neutralGray500,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.card_giftcard,
                      color: AppTheme.neutralGray500,
                    ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.nama,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.stars,
                        color: AppTheme.accentGold,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${NumberFormat('#,###').format(reward.poinDibutuhkan)} poin',
                        style: const TextStyle(
                          color: AppTheme.neutralGray600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Ditukar',
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(reward.createdAt),
                  style: const TextStyle(
                    color: AppTheme.neutralGray500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    // Show redemption code or details
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Text(
                    'Lihat Kode',
                    style: TextStyle(
                      fontSize: 12,
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

  Widget _buildEmptyRewards() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 80,
            color: AppTheme.neutralGray400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Reward',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.neutralGray600,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Reward menarik akan segera hadir!',
            style: TextStyle(
              color: AppTheme.neutralGray500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppTheme.neutralGray400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Riwayat',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.neutralGray600,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tukarkan poin Anda dengan reward menarik!',
            style: TextStyle(
              color: AppTheme.neutralGray500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _tabController.animateTo(0);
            },
            child: const Text('Lihat Reward'),
          ),
        ],
      ),
    );
  }

  void _showRewardDetails(RewardModel reward, bool canRedeem) {
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
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.neutralGray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppTheme.neutralGray100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: reward.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  reward.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.card_giftcard,
                                      size: 60,
                                      color: AppTheme.neutralGray500,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.card_giftcard,
                                size: 60,
                                color: AppTheme.neutralGray500,
                              ),
                      ),

                      const SizedBox(height: 24),

                      // Title and Points
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reward.nama,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.stars,
                                  color: AppTheme.accentGold,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  NumberFormat('#,###').format(reward.poinDibutuhkan),
                                  style: const TextStyle(
                                    color: AppTheme.accentGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        reward.deskripsi ?? '',
                        style: const TextStyle(
                          color: AppTheme.neutralGray600,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Details
                      _buildDetailRow('Kategori', _getCategoryName(reward.category)),
                      _buildDetailRow('Stok Tersisa', '${reward.stok} item'),
                      _buildDetailRow(
                        'Berlaku Hingga', 
                        DateFormat('dd MMM yyyy').format(reward.validUntil),
                      ),

                      const Spacer(),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: canRedeem ? () => _redeemReward(reward) : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: canRedeem 
                                ? AppTheme.primaryRed 
                                : AppTheme.neutralGray300,
                          ),
                          child: Text(
                            canRedeem 
                                ? 'Tukar Sekarang' 
                                : 'Poin Tidak Cukup',
                            style: TextStyle(
                              fontSize: 16,
                              color: canRedeem ? Colors.white : AppTheme.neutralGray600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _redeemReward(RewardModel reward) async {
    final authProvider = context.read<AuthProvider>();
    final rewardsProvider = context.read<RewardsProvider>();

    if (authProvider.currentUser == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penukaran'),
        content: Text(
          'Apakah Anda yakin ingin menukar ${NumberFormat('#,###').format(reward.poinDibutuhkan)} poin untuk ${reward.nama}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Tukar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await rewardsProvider.redeemReward(
      authProvider.currentUser!.id,
      reward.rewardId,
    );

    if (mounted) {
      Navigator.of(context).pop(); // Close modal

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Reward berhasil ditukar!' 
                : 'Gagal menukar reward. Silakan coba lagi.',
          ),
          backgroundColor: success 
              ? AppTheme.successGreen 
              : AppTheme.errorRed,
        ),
      );

      if (success) {
  await authProvider.loadUserProfile(); // ✅ Tanpa underscore
}
    }
  }

  void _showEarnPointsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
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
              mainAxisSize: MainAxisSize.min,
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
                  'Cara Mendapatkan Poin',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 24),

                _buildEarnPointItem(
                  Icons.shopping_bag,
                  'Belanja di Merchant',
                  '1 poin per Rp 1.000',
                  AppTheme.primaryRed,
                ),
                
                _buildEarnPointItem(
                  Icons.event_available,
                  'Daily Check-in',
                  '10 poin setiap hari',
                  AppTheme.successGreen,
                ),
                
                _buildEarnPointItem(
                  Icons.casino,
                  'Spin the Wheel',
                  '5-30 poin per spin',
                  AppTheme.accentGold,
                ),
                
                _buildEarnPointItem(
                  Icons.share,
                  'Referral Teman',
                  '100 poin per referral',
                  AppTheme.secondaryBlue,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Mengerti'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEarnPointItem(IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.neutralGray600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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