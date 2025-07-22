import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../utils/app_theme.dart';
import '../gamification/spin_wheel_screen.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh user data
              await Future.delayed(const Duration(seconds: 1));
            },
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppTheme.primaryRed,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: AppTheme.gradientDecoration,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.white,
                                    backgroundImage: user.profileImageUrl != null
                                        ? NetworkImage(user.profileImageUrl!)
                                        : null,
                                    child: user.profileImageUrl == null
                                        ? Text(
                                            user.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                                            style: const TextStyle(
                                              color: AppTheme.primaryRed,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Selamat datang,',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.white.withOpacity(0.9),
                                              ),
                                        ),
                                        Text(
                                          user.fullName ?? 'Pengguna',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // Show notifications
                                    },
                                    icon: const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Balance Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildBalanceCard(
                                context,
                                'Poin',
                                NumberFormat('#,###').format(user.pointsBalance),
                                Icons.stars,
                                AppTheme.accentGold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildBalanceCard(
                                context,
                                'Saldo',
                                'Rp ${NumberFormat('#,###').format(user.walletBalance)}',
                                Icons.account_balance_wallet,
                                AppTheme.successGreen,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Gamification Section
                        _buildGamificationSection(context, user.id),

                        const SizedBox(height: 24),

                        // Quick Actions
                        _buildQuickActions(context),

                        const SizedBox(height: 24),

                        // Recent Activity or Recommendations
                        _buildRecentActivity(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up,
                color: AppTheme.successGreen,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.neutralGray600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationSection(BuildContext context, String userId) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aktivitas Harian',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Consumer<GamificationProvider>(
                  builder: (context, gamificationProvider, _) {
                    final authProvider = context.read<AuthProvider>();
                    final user = authProvider.currentUser!;
                    
                    final canCheckIn = gamificationProvider.canCheckIn(user.lastCheckIn);
                    
                    return _buildGamificationButton(
                      context,
                      'Check In',
                      'Dapatkan 10 poin',
                      Icons.event_available,
                      canCheckIn ? AppTheme.primaryRed : AppTheme.neutralGray400,
                      canCheckIn,
                      () async {
                        if (canCheckIn) {
                          final success = await gamificationProvider.performDailyCheckIn(userId);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  gamificationProvider.checkInResult?['message'] ?? 'Check-in berhasil!',
                                ),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Consumer<GamificationProvider>(
                  builder: (context, gamificationProvider, _) {
                    final authProvider = context.read<AuthProvider>();
                    final user = authProvider.currentUser!;
                    
                    final canSpin = gamificationProvider.canSpinWheel(user.lastSpinWheel);
                    
                    return _buildGamificationButton(
                      context,
                      'Spin Wheel',
                      'Menangkan hadiah',
                      Icons.casino,
                      canSpin ? AppTheme.accentGold : AppTheme.neutralGray400,
                      canSpin,
                      () {
                        if (canSpin) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SpinWheelScreen(),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGamificationButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool enabled,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.1) : AppTheme.neutralGray100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? color.withOpacity(0.3) : AppTheme.neutralGray300,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: enabled ? AppTheme.neutralGray900 : AppTheme.neutralGray500,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: enabled ? AppTheme.neutralGray600 : AppTheme.neutralGray400,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Scan QR',
                Icons.qr_code_scanner,
                AppTheme.primaryRed,
                () {
                  // Navigate to QR scanner
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Merchant',
                Icons.store,
                AppTheme.secondaryBlue,
                () {
                  // Navigate to merchants
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Referral',
                Icons.share,
                AppTheme.accentGold,
                () {
                  // Navigate to referral
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Column(
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
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Aktivitas Terbaru',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Navigate to full activity list
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildActivityItem(
              context,
              'Cashback diterima',
              'Rp 15.000 dari Indomaret',
              '2 jam yang lalu',
              Icons.account_balance_wallet,
              AppTheme.successGreen,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.neutralGray600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.neutralGray500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}