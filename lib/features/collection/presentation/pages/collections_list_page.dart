import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/quickalert.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/storage_service.dart';
import '../../../application/presentation/bloc/application_cubit.dart';
import '../../../application/presentation/bloc/application_state.dart';
import '../../../application/data/models/application_response.dart';
import '../../data/models/collection_response.dart';
import '../bloc/collection_cubit.dart';
import '../bloc/collection_state.dart';
import 'payment_dialog.dart';

class CollectionsListPage extends StatefulWidget {
  final int? applicationId;

  const CollectionsListPage({super.key, this.applicationId});

  @override
  State<CollectionsListPage> createState() => _CollectionsListPageState();
}

class _CollectionsListPageState extends State<CollectionsListPage> {
  final StorageService _storageService = StorageService();
  List<ApplicationResponse> _applications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final customerId = await _storageService.getCustomerId();
    if (customerId != null && mounted) {
      // Önce başvuruları yükle
      context.read<ApplicationCubit>().loadApplications(customerId);

      // Sonra ödemeleri yükle
      if (widget.applicationId != null) {
        context.read<CollectionCubit>().loadCollectionsByApplicationId(widget.applicationId!);
      } else {
        context.read<CollectionCubit>().loadCollections(customerId);
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  bool _isOverdue(String dateString, bool isPaid) {
    if (isPaid) return false;
    try {
      final dueDate = DateTime.parse(dateString);
      return dueDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Ödemelerim',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<ApplicationCubit, ApplicationState>(
        listener: (context, appState) {
          if (appState is ApplicationListLoaded) {
            setState(() {
              _applications = appState.applications;
            });
          }
        },
        child: BlocConsumer<CollectionCubit, CollectionState>(
          listener: (context, state) {
            if (state is PaymentSuccess) {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.success,
                title: 'Başarılı!',
                text: 'Ödeme başarıyla gerçekleştirildi',
                autoCloseDuration: const Duration(seconds: 2),
                showConfirmBtn: false,
              );
            }
          },
          builder: (context, state) {
            if (state is CollectionLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is CollectionFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Text(
                        state.message,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Dene'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is CollectionLoaded) {
              if (state.collections.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment,
                          size: 80,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        const Text(
                          'Ödeme Bulunamadı',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        const Text(
                          'Henüz hiç ödemeniz bulunmamaktadır.',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Ödemeleri başvurulara göre grupla
              final Map<int, List<dynamic>> groupedCollections = {};
              for (var collection in state.collections) {
                if (!groupedCollections.containsKey(collection.applicationId)) {
                  groupedCollections[collection.applicationId] = [];
                }
                groupedCollections[collection.applicationId]!.add(collection);
              }

              // Her grup içinde taksitleri sırala
              groupedCollections.forEach((key, value) {
                value.sort((a, b) => a.installmentNumber.compareTo(b.installmentNumber));
              });

              return RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  children: [
                    // Genel özet kartı
                    _buildOverallSummaryCard(state.collections),
                    const SizedBox(height: AppSizes.lg),

                    // Her başvuru için grup kartı
                    ...groupedCollections.entries.map((entry) {
                      final applicationId = entry.key;
                      final collections = entry.value;
                      final application = _applications.firstWhere(
                        (app) => app.id == applicationId,
                        orElse: () => ApplicationResponse(
                          id: applicationId,
                          applicationNumber: 'BAS-$applicationId',
                          customerId: 0,
                          productId: 0,
                          productName: 'Bilinmeyen Ürün',
                          amount: 0,
                          applicationDate: '',
                          status: '',
                          isActive: true,
                        ),
                      );

                      return _buildApplicationGroup(application, collections);
                    }),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildOverallSummaryCard(List collections) {
    final totalAmount = collections.fold<double>(
      0, (sum, item) => sum + item.installmentAmount);
    final paidAmount = collections
        .where((item) => item.isPaid)
        .fold<double>(0, (sum, item) => sum + item.installmentAmount);
    final unpaidCount = collections.where((item) => !item.isPaid).length;
    final paidCount = collections.where((item) => item.isPaid).length;

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Toplam Tutar',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${totalAmount.toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Ödenen',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${paidAmount.toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.pending_actions, color: Colors.white, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        '$unpaidCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Bekleyen',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        '$paidCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Ödendi',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationGroup(ApplicationResponse application, List collections) {
    final unpaidCollections = collections.where((c) => !c.isPaid).toList();
    final paidCollections = collections.where((c) => c.isPaid).toList();
    final totalAmount = collections.fold<double>(0, (sum, item) => sum + item.installmentAmount);
    final paidAmount = paidCollections.fold<double>(0, (sum, item) => sum + item.installmentAmount);

    // İlk ödenmemiş taksit numarasını bul
    final firstUnpaidInstallmentNumber = unpaidCollections.isNotEmpty
        ? unpaidCollections.first.installmentNumber
        : 999;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başvuru başlığı
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        application.applicationNumber,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${paidCollections.length}/${collections.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'Ödendi',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // İlerleme çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ödenen: ${paidAmount.toStringAsFixed(2)} ₺',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Toplam: ${totalAmount.toStringAsFixed(2)} ₺',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: paidCollections.length / collections.length,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Taksit listesi
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bekleyen taksitler
                if (unpaidCollections.isNotEmpty) ...[
                  const Text(
                    'Bekleyen Taksitler',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...unpaidCollections.map((collection) =>
                    _buildInstallmentRow(collection, false, firstUnpaidInstallmentNumber)),
                ],

                // Ödenen taksitler
                if (paidCollections.isNotEmpty) ...[
                  if (unpaidCollections.isNotEmpty) const SizedBox(height: 12),
                  const Text(
                    'Ödenen Taksitler',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...paidCollections.map((collection) =>
                    _buildInstallmentRow(collection, true, firstUnpaidInstallmentNumber)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentRow(CollectionResponse collection, bool isPaid, int firstUnpaidInstallmentNumber) {
    final isOverdue = _isOverdue(collection.dueDate, collection.isPaid);
    final canPay = !isPaid && (collection.installmentNumber == firstUnpaidInstallmentNumber);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.orange)).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.orange)).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.orange)).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPaid ? Icons.check_circle : (isOverdue ? Icons.warning : Icons.schedule),
              color: isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.orange),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Taksit ${collection.installmentNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPaid ? '✓ Ödendi' : (isOverdue ? '⚠ Gecikmeli' : '○ Bekliyor'),
                      style: TextStyle(
                        fontSize: 11,
                        color: isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.orange),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Vade: ${_formatDate(collection.dueDate)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${collection.installmentAmount.toStringAsFixed(2)} ₺',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (!isPaid) ...[
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: canPay ? () {
                    showDialog(
                      context: context,
                      builder: (ctx) => BlocProvider.value(
                        value: context.read<CollectionCubit>(),
                        child: PaymentDialog(
                          collectionId: collection.id,
                          amount: collection.installmentAmount,
                        ),
                      ),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canPay ? (isOverdue ? Colors.red : AppColors.primary) : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    canPay ? 'Öde' : 'Sıra',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: canPay ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
