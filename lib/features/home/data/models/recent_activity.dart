enum ActivityType {
  application,
  payment,
  policy,
}

class RecentActivity {
  final ActivityType type;
  final String title;
  final String subtitle;
  final String date;
  final String? status;
  final int? relatedId;

  RecentActivity({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    this.status,
    this.relatedId,
  });
}
