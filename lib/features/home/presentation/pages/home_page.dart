import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/storage_service.dart';
import '../../../application/domain/repositories/application_repository.dart';
import '../../../collection/domain/repositories/collection_repository.dart';
import '../../../policy/domain/repositories/policy_repository.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../widgets/welcome_header.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/section_header.dart';
import '../widgets/activity_timeline_item.dart';
import '../widgets/upcoming_payment_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService _storageService = StorageService();
  String _userName = '';
  int? _customerId;
  HomeCubit? _homeCubit;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _homeCubit = HomeCubit(
        applicationRepository: context.read<ApplicationRepository>(),
        collectionRepository: context.read<CollectionRepository>(),
        policyRepository: context.read<PolicyRepository>(),
      );
      _isInitialized = true;

      // Load data if customerId is available
      if (_customerId != null) {
        _homeCubit!.loadDashboardData(_customerId!);
      }
    }
  }

  Future<void> _loadUserData() async {
    final name = await _storageService.getCustomerName();
    final id = await _storageService.getCustomerId();

    if (mounted) {
      setState(() {
        _userName = name ?? 'Kullanıcı';
        _customerId = id;
      });

      if (_customerId != null && _isInitialized) {
        _homeCubit!.loadDashboardData(_customerId!);
      }
    }
  }

  Future<void> _refreshData() async {
    if (_customerId != null && _homeCubit != null) {
      await _homeCubit!.loadDashboardData(_customerId!);
    }
  }

  @override
  void dispose() {
    _homeCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          WelcomeHeader(
            userName: _userName,
            onLogoutTap: () => _showLogoutDialog(context),
          ),
          Expanded(
            child: _homeCubit == null
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : BlocBuilder<HomeCubit, HomeState>(
                    bloc: _homeCubit,
                    builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is HomeError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppSizes.md),
                        const Text(
                          'Bir Hata Oluştu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        ElevatedButton.icon(
                          onPressed: _refreshData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tekrar Dene'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is HomeLoaded) {
                  return RefreshIndicator(
                    onRefresh: _refreshData,
                    color: AppColors.primary,
                    child: ListView(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      children: [
                        // Statistics Cards
                        const SectionHeader(
                          title: 'Özet',
                          icon: Icons.dashboard_outlined,
                        ),
                        const SizedBox(height: AppSizes.md),
                        Row(
                          children: [
                            Expanded(
                              child: DashboardStatCard(
                                icon: Icons.assignment_outlined,
                                title: 'Başvurular',
                                value: '${state.summary.totalApplications}',
                                color: Colors.blue,
                                onTap: () {
                                  Navigator.pushNamed(context, '/applications');
                                },
                              ),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: DashboardStatCard(
                                icon: Icons.shield_outlined,
                                title: 'Aktif Poliçe',
                                value: '${state.summary.activePolicies}',
                                color: Colors.teal,
                                onTap: () {
                                  Navigator.pushNamed(context, '/policies');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.md),
                        Row(
                          children: [
                            Expanded(
                              child: DashboardStatCard(
                                icon: Icons.pending_actions_outlined,
                                title: 'Bekleyen',
                                value: '${state.summary.pendingApplications}',
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: DashboardStatCard(
                                icon: Icons.payment_outlined,
                                title: 'Toplam Borç',
                                value: '${state.summary.totalPaymentsAmount.toStringAsFixed(0)}₺',
                                color: Colors.green,
                                onTap: () {
                                  Navigator.pushNamed(context, '/collections');
                                },
                              ),
                            ),
                          ],
                        ),

                        // Upcoming Payments
                        if (state.upcomingPayments.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.xl),
                          SectionHeader(
                            title: 'Yaklaşan Ödemeler',
                            icon: Icons.schedule_outlined,
                            actionText: 'Tümü',
                            onActionTap: () {
                              Navigator.pushNamed(context, '/collections');
                            },
                          ),
                          const SizedBox(height: AppSizes.md),
                          ...state.upcomingPayments.map((payment) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSizes.md),
                              child: UpcomingPaymentCard(
                                title: 'Taksit Ödemesi',
                                amount: payment.installmentAmount,
                                dueDate: payment.dueDate,
                                installmentNumber: payment.installmentNumber,
                                onTap: () {
                                  Navigator.pushNamed(context, '/collections');
                                },
                              ),
                            );
                          }),
                        ],

                        // Recent Activities
                        if (state.recentActivities.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.xl),
                          const SectionHeader(
                            title: 'Son Aktiviteler',
                            icon: Icons.history_outlined,
                          ),
                          const SizedBox(height: AppSizes.md),
                          ...state.recentActivities.asMap().entries.map((entry) {
                            final index = entry.key;
                            final activity = entry.value;
                            return ActivityTimelineItem(
                              activity: activity,
                              isLast: index == state.recentActivities.length - 1,
                            );
                          }),
                        ],

                        const SizedBox(height: AppSizes.xl),

                        // Quick Actions
                        const SectionHeader(
                          title: 'Hızlı İşlemler',
                          icon: Icons.bolt_outlined,
                        ),
                        const SizedBox(height: AppSizes.md),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: AppSizes.md,
                          crossAxisSpacing: AppSizes.md,
                          childAspectRatio: 0.95,
                          children: [
                            QuickActionCard(
                              icon: Icons.add_circle_outline,
                              title: 'Yeni Başvuru',
                              subtitle: 'Başvuru Yap',
                              color: Colors.blue,
                              onTap: () {
                                Navigator.pushNamed(context, '/application-create');
                              },
                            ),
                            QuickActionCard(
                              icon: Icons.assignment_outlined,
                              title: 'Başvurular',
                              subtitle: 'Listele',
                              color: Colors.orange,
                              onTap: () {
                                Navigator.pushNamed(context, '/applications');
                              },
                            ),
                            QuickActionCard(
                              icon: Icons.shield_outlined,
                              title: 'Poliçelerim',
                              subtitle: 'Görüntüle',
                              color: Colors.teal,
                              onTap: () {
                                Navigator.pushNamed(context, '/policies');
                              },
                            ),
                            QuickActionCard(
                              icon: Icons.payment_outlined,
                              title: 'Ödemeler',
                              subtitle: 'Tahsilat',
                              color: Colors.green,
                              onTap: () {
                                Navigator.pushNamed(context, '/collections');
                              },
                            ),
                            QuickActionCard(
                              icon: Icons.refresh_outlined,
                              title: 'Yenile',
                              subtitle: 'Güncelle',
                              color: Colors.deepPurple,
                              onTap: _refreshData,
                            ),
                            QuickActionCard(
                              icon: Icons.help_outline,
                              title: 'Yardım',
                              subtitle: 'Destek',
                              color: Colors.purple,
                              onTap: () {
                                _showInfoDialog(context);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSizes.md),
                      ],
                    ),
                  );
                }

                // Initial state - show loading
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              },
                    ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
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
                Navigator.pop(dialogContext);
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
