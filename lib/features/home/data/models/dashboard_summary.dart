class DashboardSummary {
  final int totalApplications;
  final int activePolicies;
  final int pendingApplications;
  final double totalPaymentsAmount;
  final int upcomingPaymentsCount;

  DashboardSummary({
    required this.totalApplications,
    required this.activePolicies,
    required this.pendingApplications,
    required this.totalPaymentsAmount,
    required this.upcomingPaymentsCount,
  });

  factory DashboardSummary.empty() {
    return DashboardSummary(
      totalApplications: 0,
      activePolicies: 0,
      pendingApplications: 0,
      totalPaymentsAmount: 0.0,
      upcomingPaymentsCount: 0,
    );
  }
}
