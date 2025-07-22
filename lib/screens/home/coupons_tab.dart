import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';

class CouponsTab extends StatefulWidget {
  const CouponsTab({super.key});

  @override
  State<CouponsTab> createState() => _CouponsTabState();
}

class _CouponsTabState extends State<CouponsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kupon'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryRed,
          unselectedLabelColor: AppTheme.neutralGray500,
          indicatorColor: AppTheme.primaryRed,
          tabs: const [
            Tab(text: 'Tersedia'),
            Tab(text: 'Saya'),
            Tab(text: 'Digunakan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableCouponsTab(),
          _buildMyCouponsTab(),
          _buildUsedCouponsTab(),
        ],
      ),
    );
  }

  Widget _buildAvailableCouponsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh available coupons
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.neutralGray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: AppTheme.neutralGray500,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari kupon atau merchant...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Categories
          _buildCategoriesSection(),

          const SizedBox(height: 24),

          // Featured Coupons
          _buildFeaturedCoupons(),

          const SizedBox(height: 24),

          // All Coupons
          _buildCouponsList(isAvailable: true),
        ],
      ),
    );
  }

  Widget _buildMyCouponsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh user coupons
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCouponsList(isAvailable: false),
        ],
      ),
    );
  }

  Widget _buildUsedCouponsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh used coupons
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUsedCouponsList(),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'name': 'Makanan', 'icon': Icons.restaurant, 'color': AppTheme.primaryRed},
      {'name': 'Fashion', 'icon': Icons.checkroom, 'color': AppTheme.accentGold},
      {'name': 'Electronics', 'icon': Icons.devices, 'color': AppTheme.secondaryBlue},
      {'name': 'Travel', 'icon': Icons.flight, 'color': AppTheme.successGreen},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: categories.map((category) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCategoryCard(
                  category['name'] as String,
                  category['icon'] as IconData,
                  category['color'] as Color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String name, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // Filter by category
      },
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
              name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCoupons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kupon Unggulan',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildFeaturedCouponCard(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCouponCard() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryRed, AppTheme.accentGold],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'DISKON 50%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'McDonald\'s',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Berlaku untuk semua menu',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Berakhir 31 Des 2024',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsList({required bool isAvailable}) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildCouponCard(isAvailable: isAvailable);
      },
    );
  }

  Widget _buildUsedCouponsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildUsedCouponCard();
      },
    );
  }

  Widget _buildCouponCard({required bool isAvailable}) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          // Left side - Discount
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryRed, AppTheme.accentGold],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '25%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Right side - Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'KFC Indonesia',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (!isAvailable)
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
                            'Tersimpan',
                            style: TextStyle(
                              color: AppTheme.successGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Diskon 25% untuk semua menu ayam',
                    style: TextStyle(
                      color: AppTheme.neutralGray600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.neutralGray100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Min. Rp 50.000',
                          style: TextStyle(
                            color: AppTheme.neutralGray600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        '31 Des 2024',
                        style: TextStyle(
                          color: AppTheme.neutralGray500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isAvailable) {
                          _showCouponDetailModal();
                        } else {
                          _showUseCouponModal();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAvailable 
                            ? AppTheme.primaryRed 
                            : AppTheme.successGreen,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        isAvailable ? 'Ambil' : 'Gunakan',
                        style: const TextStyle(fontSize: 14),
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
  }

  Widget _buildUsedCouponCard() {
    return Container(
      decoration: AppTheme.cardDecoration.copyWith(
        color: AppTheme.neutralGray100,
      ),
      child: Row(
        children: [
          // Left side - Discount (Grayed out)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.neutralGray300,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '25%',
                  style: TextStyle(
                    color: AppTheme.neutralGray600,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'OFF',
                  style: TextStyle(
                    color: AppTheme.neutralGray600,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Right side - Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'KFC Indonesia',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.neutralGray600,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.neutralGray300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Digunakan',
                          style: TextStyle(
                            color: AppTheme.neutralGray600,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Diskon 25% untuk semua menu ayam',
                    style: TextStyle(
                      color: AppTheme.neutralGray500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Digunakan pada 28 Des 2024',
                    style: TextStyle(
                      color: AppTheme.neutralGray500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hemat Rp 12.500',
                    style: TextStyle(
                      color: AppTheme.successGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCouponDetailModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
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
                
                // Coupon Visual
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryRed, AppTheme.accentGold],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '25%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'OFF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'KFC Indonesia',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'SPECIALOFFER25',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Detail Kupon',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                _buildDetailRow('Diskon', '25% dari total pembelian'),
                _buildDetailRow('Minimum Pembelian', 'Rp 50.000'),
                _buildDetailRow('Maksimum Diskon', 'Rp 25.000'),
                _buildDetailRow('Berlaku Hingga', '31 Desember 2024'),
                _buildDetailRow('Merchant', 'KFC Indonesia - Semua cabang'),

                const SizedBox(height: 24),

                Text(
                  'Syarat & Ketentuan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 12),

                const Text(
                  '• Kupon hanya berlaku untuk pembelian melalui aplikasi\n'
                  '• Tidak dapat digabung dengan promo lain\n'
                  '• Berlaku untuk semua menu ayam KFC\n'
                  '• Kupon hanya dapat digunakan satu kali',
                  style: TextStyle(
                    color: AppTheme.neutralGray600,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kupon berhasil disimpan!'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Simpan Kupon',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUseCouponModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
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

                // QR Code or Coupon Code
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.neutralGray100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code,
                        size: 120,
                        color: AppTheme.neutralGray600,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'SPECIALOFFER25',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Tunjukkan kode ini ke kasir atau scan QR code untuk menggunakan kupon',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.neutralGray600,
                    fontSize: 14,
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Tutup'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Copy coupon code
                        },
                        child: const Text('Salin Kode'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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