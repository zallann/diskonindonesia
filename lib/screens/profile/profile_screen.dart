import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // Profile Header
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.primaryRed,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: AppTheme.gradientDecoration,
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: user.profileImageUrl != null
                                ? NetworkImage(user.profileImageUrl!)
                                : null,
                            child: user.profileImageUrl == null
                                ? Text(
                                    user.nama?.substring(0, 1).toUpperCase() ?? 'U',
                                    style: const TextStyle(
                                      color: AppTheme.primaryRed,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.nama ?? 'Pengguna',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      // Edit profile
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Check-in Streak',
                              '0', // Default since not tracked in DB
                              Icons.local_fire_department,
                              AppTheme.warningOrange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Member Since',
                              _getYearsSince(user.createdAt),
                              Icons.calendar_today,
                              AppTheme.secondaryBlue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Menu Items
                      _buildMenuSection(
                        context,
                        'Akun',
                        [
                          _buildMenuItem(
                            context,
                            'Informasi Pribadi',
                            Icons.person_outline,
                            () {
                              // Navigate to personal info
                            },
                          ),
                          _buildMenuItem(
                            context,
                            'Keamanan',
                            Icons.security,
                            () {
                              // Navigate to security settings
                            },
                          ),
                          _buildMenuItem(
                            context,
                            'Notifikasi',
                            Icons.notifications_outlined,
                            () {
                              // Navigate to notification settings
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _buildMenuSection(
                        context,
                        'Program',
                        [
                          _buildMenuItem(
                            context,
                            'Kode Referral',
                            Icons.share,
                            () {
                              _showReferralModal(context, user.referralCode ?? '');
                            },
                          ),
                          _buildMenuItem(
                            context,
                            'Misi Harian',
                            Icons.assignment,
                            () {
                              // Navigate to missions
                            },
                          ),
                          _buildMenuItem(
                            context,
                            'Level & Badge',
                            Icons.military_tech,
                            () {
                              // Navigate to levels and badges
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _buildMenuSection(
                        context,
                        'Bantuan',
                        [
                          _buildMenuItem(
                            context,
                            'Pusat Bantuan',
                            Icons.help_outline,
                            () {
                              // Navigate to help center
                            },
                          ),
                          _buildMenuItem(
                            context,
                            'Hubungi Customer Service',
                            Icons.support_agent,
                            () {
                              // Contact customer service
                            },
                          ),
                          _buildMenuItem(
                            context,
                            'Tentang Aplikasi',
                            Icons.info_outline,
                            () {
                              // Show about dialog
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _showLogoutDialog(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorRed,
                            side: const BorderSide(color: AppTheme.errorRed),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 8),
                              Text(
                                'Keluar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
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
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.neutralGray600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralGray700,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppTheme.cardDecoration,
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppTheme.neutralGray600,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.neutralGray400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getYearsSince(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    final years = difference.inDays ~/ 365;
    
    if (years > 0) {
      return '${years}th';
    } else {
      final months = difference.inDays ~/ 30;
      if (months > 0) {
        return '${months}mo';
      } else {
        return '${difference.inDays}d';
      }
    }
  }

  void _showReferralModal(BuildContext context, String referralCode) {
    if (referralCode.isEmpty) {
      referralCode = 'REF123456'; // Default referral code
    }
    
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
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.neutralGray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                
                const Icon(
                  Icons.share,
                  size: 48,
                  color: AppTheme.primaryRed,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Kode Referral Anda',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Ajak teman dan dapatkan 100 poin untuk setiap referral!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.neutralGray600,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.neutralGray100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    referralCode,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Copy to clipboard
                        },
                        child: const Text('Salin Kode'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Share referral code
                        },
                        child: const Text('Bagikan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<AuthProvider>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}