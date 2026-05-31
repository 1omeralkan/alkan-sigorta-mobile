import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickalert/quickalert.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/storage_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    if (widget.applicationId != null) {
      // Specific application collections
      context.read<CollectionCubit>().loadCollectionsByApplicationId(widget.applicationId!);
    } else {
      // All customer collections
      final customerId = await _storageService.getCustomerId();
      if (customerId != null && mounted) {
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
          'Ödemeler',
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
      body: BlocConsumer<CollectionCubit, CollectionState>(
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
          // PaymentFailure mesajı artık payment_dialog içinde gösteriliyor
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
                      color: Colors.red.withOpacity(0.5),
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
                      onPressed: _loadCollections,
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
                        color: AppColors.primary.withOpacity(0.5),
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

            // Ödenmemiş ve ödenmiş taksitleri ayır
            final unpaidCollections = state.collections
                .where((c) => !c.isPaid)
                .toList()
              ..sort((a, b) => a.installmentNumber.compareTo(b.installmentNumber));

            final paidCollections = state.collections
                .where((c) => c.isPaid)
                .toList()
              ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

            // İlk ödenmemiş taksit numarasını bul (sıralı ödeme kontrolü için)
            final firstUnpaidInstallmentNumber = unpaidCollections.isNotEmpty
                ? unpaidCollections.first.installmentNumber
                : 999;

            return RefreshIndicator(
              onRefresh: _loadCollections,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.md),
                children: [
                  // Özet Kartı
                  _buildSummaryCard(state.collections),
                  const SizedBox(height: AppSizes.lg),

                  // Ödenmemiş Taksitler
                  if (unpaidCollections.isNotEmpty) ...[
                    const Text(
                      'Bekleyen Ödemeler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    ...unpaidCollections.map((collection) => _buildCollectionCard(collection, false, firstUnpaidInstallmentNumber)),
                    const SizedBox(height: AppSizes.lg),
                  ],

                  // Ödenmiş Taksitler
                  if (paidCollections.isNotEmpty) ...[
                    const Text(
                      'Ödenen Taksitler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    ...paidCollections.map((collection) => _buildCollectionCard(collection, true, firstUnpaidInstallmentNumber)),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryCard(List collections) {
    final totalAmount = collections.fold<double>(
      0, (sum, item) => sum + item.installmentAmount);
    final paidAmount = collections
        .where((item) => item.isPaid)
        .fold<double>(0, (sum, item) => sum + item.installmentAmount);
    final unpaidCount = collections.where((item) => !item.isPaid).length;

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pending_actions, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$unpaidCount Bekleyen Ödeme',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(collection, bool isPaid, int firstUnpaidInstallmentNumber) {
    final isOverdue = _isOverdue(collection.dueDate, collection.isPaid);
    final canPay = !isPaid && (collection.installmentNumber == firstUnpaidInstallmentNumber);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.orange))
                .withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Sol renkli çizgi
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                color: isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.orange),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.orange))
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isPaid ? Icons.check_circle : Icons.schedule,
                          color: isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.orange),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Taksit ${collection.installmentNumber}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (isOverdue)
                                  const Icon(Icons.warning, size: 14, color: Colors.red),
                                if (isOverdue) const SizedBox(width: 4),
                                Text(
                                  isPaid ? 'Ödendi' : (isOverdue ? 'Vadesi Geçmiş!' : 'Beklemede'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isPaid ? Colors.green : (isOverdue ? Colors.red : Colors.orange),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(collection.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!isPaid) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
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
                        icon: Icon(Icons.payment, size: 18),
                        label: Text(canPay ? 'Ödeme Yap' : 'Sıra Bekliyor'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canPay ? (isOverdue ? Colors.red : AppColors.primary) : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
