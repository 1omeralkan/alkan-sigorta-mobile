import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/storage_service.dart';
import '../bloc/application_cubit.dart';
import '../bloc/application_state.dart';

class ApplicationsListPage extends StatefulWidget {
  const ApplicationsListPage({super.key});

  @override
  State<ApplicationsListPage> createState() => _ApplicationsListPageState();
}

class _ApplicationsListPageState extends State<ApplicationsListPage> {
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final customerId = await _storageService.getCustomerId();
    if (customerId != null && mounted) {
      context.read<ApplicationCubit>().loadApplications(customerId);
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Beklemede';
      case 'APPROVED':
        return 'Onaylandı';
      case 'REJECTED':
        return 'Reddedildi';
      case 'COMPLETED':
        return 'Tamamlandı';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
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
          'Başvurularım',
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
      body: BlocBuilder<ApplicationCubit, ApplicationState>(
        builder: (context, state) {
          if (state is ApplicationListLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is ApplicationListFailure) {
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
                      onPressed: _loadApplications,
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

          if (state is ApplicationListLoaded) {
            if (state.applications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment,
                        size: 80,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      const Text(
                        'Başvurularınız',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      const Text(
                        'Henüz başvuru bulunmamaktadır.',
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

            return RefreshIndicator(
              onRefresh: _loadApplications,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSizes.md),
                itemCount: state.applications.length,
                itemBuilder: (context, index) {
                  final application = state.applications[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSizes.md),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  application.productName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(application.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(application.status),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  _getStatusText(application.status),
                                  style: TextStyle(
                                    color: _getStatusColor(application.status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.sm),
                          const Divider(),
                          const SizedBox(height: AppSizes.sm),
                          _buildInfoRow(
                            Icons.confirmation_number,
                            'Başvuru No',
                            application.applicationNumber,
                          ),
                          const SizedBox(height: AppSizes.xs),
                          _buildInfoRow(
                            Icons.attach_money,
                            'Tutar',
                            '${application.amount.toStringAsFixed(2)} TL',
                          ),
                          const SizedBox(height: AppSizes.xs),
                          _buildInfoRow(
                            Icons.date_range,
                            'Başvuru Tarihi',
                            _formatDate(application.applicationDate),
                          ),
                          if (application.paymentTypeName != null) ...[
                            const SizedBox(height: AppSizes.xs),
                            _buildInfoRow(
                              Icons.payment,
                              'Ödeme Tipi',
                              application.paymentTypeName!,
                            ),
                          ],
                          if (application.installmentCount != null) ...[
                            const SizedBox(height: AppSizes.xs),
                            _buildInfoRow(
                              Icons.format_list_numbered,
                              'Taksit Sayısı',
                              '${application.installmentCount} Ay',
                            ),
                          ],
                          if (application.installmentAmount != null) ...[
                            const SizedBox(height: AppSizes.xs),
                            _buildInfoRow(
                              Icons.money,
                              'Taksit Tutarı',
                              '${application.installmentAmount!.toStringAsFixed(2)} TL',
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment,
                    size: 80,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  const Text(
                    'Başvurularınız',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSizes.xs),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
