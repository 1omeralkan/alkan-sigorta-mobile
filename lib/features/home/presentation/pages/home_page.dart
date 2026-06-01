import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService _storageService = StorageService();
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await _storageService.getCustomerName();
    if (mounted) {
      setState(() {
        _userName = name ?? 'Kullanıcı';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Sabit Header - Design System'e uygun
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.md,
                ),
                child: Row(
                  children: [
                    // User Avatar
                    Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.textOnPrimary,
                        size: AppSizes.iconMedium,
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hoş Geldiniz',
                            style: TextStyle(
                              color: AppColors.textOnPrimary.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _userName,
                            style: const TextStyle(
                              color: AppColors.textOnPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Logout Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showLogoutDialog(context),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: Icon(
                            Icons.logout,
                            color: AppColors.textOnPrimary,
                            size: AppSizes.iconMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Kaydırılabilir İçerik
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.lg),
              children: [

                // Özellik Kartları Grid
                const Text(
                  'Hızlı İşlemler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSizes.md,
                  crossAxisSpacing: AppSizes.md,
                  childAspectRatio: 1.1,
                  children: [
                    _buildFeatureCard(
                      context,
                      icon: Icons.add_circle_outline,
                      title: 'Yeni Başvuru',
                      subtitle: 'Başvuru Oluştur',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(context, '/application-create');
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.assignment_outlined,
                      title: 'Başvurularım',
                      subtitle: 'Tüm Başvurular',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pushNamed(context, '/applications');
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.payment_outlined,
                      title: 'Ödemelerim',
                      subtitle: 'Tahsilat İşlemleri',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(context, '/collections');
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.info_outline,
                      title: 'Yardım',
                      subtitle: 'Destek & Bilgi',
                      color: Colors.purple,
                      onTap: () {
                        _showInfoDialog(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.xl),

                // Bilgilendirme Kartı
                Container(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        child: Icon(
                          Icons.verified_user,
                          color: AppColors.primary,
                          size: AppSizes.iconLarge,
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alkan Sigorta',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Güvenli ve hızlı sigorta işlemleri',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Hesabınızdan çıkmak istediğinize emin misiniz?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.sm,
              ),
            ),
            child: const Text(
              'İptal',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _storageService.deleteToken();
              await _storageService.deleteCustomerId();
              await _storageService.deleteCustomerName();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.sm,
              ),
              elevation: AppSizes.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
            ),
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.info, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Yardım & Destek'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alkan Sigorta Mobil Uygulaması',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text('• Sigorta başvurusu oluşturabilirsiniz'),
            Text('• Başvurularınızı takip edebilirsiniz'),
            Text('• Ödeme işlemlerinizi yapabilirsiniz'),
            SizedBox(height: 12),
            Text(
              'Destek için: info@alkansigorta.com',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
