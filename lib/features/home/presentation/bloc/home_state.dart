import '../../data/models/dashboard_summary.dart';
import '../../data/models/recent_activity.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final DashboardSummary summary;
  final List<RecentActivity> recentActivities;
  final List<dynamic> upcomingPayments;

  HomeLoaded({
    required this.summary,
    required this.recentActivities,
    required this.upcomingPayments,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
