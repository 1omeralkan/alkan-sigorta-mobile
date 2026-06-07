import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/error_handler.dart';
import '../../data/models/dashboard_summary.dart';
import '../../data/models/recent_activity.dart';
import '../../../application/domain/repositories/application_repository.dart';
import '../../../collection/domain/repositories/collection_repository.dart';
import '../../../policy/domain/repositories/policy_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ApplicationRepository applicationRepository;
  final CollectionRepository collectionRepository;
  final PolicyRepository policyRepository;

  HomeCubit({
    required this.applicationRepository,
    required this.collectionRepository,
    required this.policyRepository,
  }) : super(HomeInitial());

  Future<void> loadDashboardData(int customerId) async {
    emit(HomeLoading());

    try {
      // Fetch all data in parallel
      final applications = await applicationRepository.getApplicationsByCustomerId(customerId);
      final collections = await collectionRepository.getCollectionsByCustomerId(customerId);
      final policies = await policyRepository.getPoliciesByCustomerId(customerId);

      // Calculate summary
      final pendingCount = applications.where((app) => app.status == 'PENDING').length;
      final unpaidCollections = collections.where((col) => !col.isPaid && col.isActive).toList();
      final totalPaymentsAmount = unpaidCollections.fold<double>(
        0.0,
        (sum, col) => sum + col.installmentAmount,
      );

      final summary = DashboardSummary(
        totalApplications: applications.length,
        activePolicies: policies.length,
        pendingApplications: pendingCount,
        totalPaymentsAmount: totalPaymentsAmount,
        upcomingPaymentsCount: unpaidCollections.length,
      );

      // Generate recent activities
      final recentActivities = _generateRecentActivities(applications, collections);

      // Get upcoming payments (next 5)
      final upcomingPayments = _getUpcomingPayments(unpaidCollections);

      emit(HomeLoaded(
        summary: summary,
        recentActivities: recentActivities,
        upcomingPayments: upcomingPayments,
      ));
    } catch (e) {
      emit(HomeError(ErrorHandler.getErrorMessage(e)));
    }
  }

  List<RecentActivity> _generateRecentActivities(List<dynamic> applications, List<dynamic> collections) {
    final activities = <RecentActivity>[];

    // Add application activities
    for (var app in applications.take(3)) {
      activities.add(RecentActivity(
        type: ActivityType.application,
        title: app.productName ?? 'Başvuru',
        subtitle: app.applicationNumber ?? '',
        date: app.applicationDate ?? DateTime.now().toIso8601String(),
        status: app.status,
        relatedId: app.id,
      ));
    }

    // Add payment activities (paid ones)
    final paidPayments = collections.where((col) => col.isPaid).take(2);
    for (var payment in paidPayments) {
      activities.add(RecentActivity(
        type: ActivityType.payment,
        title: 'Ödeme Yapıldı',
        subtitle: 'Taksit ${payment.installmentNumber} - ${payment.installmentAmount.toStringAsFixed(2)} ₺',
        date: payment.dueDate,
        status: 'PAID',
        relatedId: payment.id,
      ));
    }

    // Sort by date (newest first)
    activities.sort((a, b) {
      try {
        return DateTime.parse(b.date).compareTo(DateTime.parse(a.date));
      } catch (e) {
        return 0;
      }
    });

    return activities.take(5).toList();
  }

  List<dynamic> _getUpcomingPayments(List<dynamic> unpaidCollections) {
    // Sort by due date
    final sorted = unpaidCollections.toList();
    sorted.sort((a, b) {
      try {
        return DateTime.parse(a.dueDate).compareTo(DateTime.parse(b.dueDate));
      } catch (e) {
        return 0;
      }
    });

    return sorted.take(3).toList();
  }
}
