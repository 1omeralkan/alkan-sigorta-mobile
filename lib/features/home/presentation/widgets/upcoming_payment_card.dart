import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class UpcomingPaymentCard extends StatelessWidget {
  final String title;
  final double amount;
  final String dueDate;
  final int installmentNumber;
  final VoidCallback? onTap;

  const UpcomingPaymentCard({
    super.key,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.installmentNumber,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = _isOverdue(dueDate);
    final daysUntilDue = _getDaysUntilDue(dueDate);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          border: Border.all(
            color: isOverdue
                ? Colors.red.withValues(alpha: 0.3)
                : AppColors.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isOverdue
                  ? Colors.red.withValues(alpha: 0.1)
                  : AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: isOverdue
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Icon(
                isOverdue ? Icons.warning_rounded : Icons.schedule_outlined,
                color: isOverdue ? Colors.red : Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Taksit $installmentNumber',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDateText(daysUntilDue, isOverdue),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isOverdue ? Colors.red : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${amount.toStringAsFixed(2)} ₺',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? Colors.red : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isOverdue(String dueDate) {
    try {
      final date = DateTime.parse(dueDate);
      return date.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  int _getDaysUntilDue(String dueDate) {
    try {
      final date = DateTime.parse(dueDate);
      final now = DateTime.now();
      return date.difference(now).inDays;
    } catch (e) {
      return 0;
    }
  }

  String _getDateText(int days, bool isOverdue) {
    if (isOverdue) {
      return 'Gecikmiş!';
    } else if (days == 0) {
      return 'Bugün son gün!';
    } else if (days == 1) {
      return 'Yarın';
    } else if (days <= 7) {
      return '$days gün kaldı';
    } else {
      try {
        final date = DateTime.parse(dueDate);
        return '${date.day}.${date.month}.${date.year}';
      } catch (e) {
        return dueDate;
      }
    }
  }
}
