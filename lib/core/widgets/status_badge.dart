import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final (textColor, bgColor, icon) = _resolveStatusTheme(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppSpacing.xs + 2 : AppSpacing.sm + 2,
        vertical: isSmall ? 2 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 12 : 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, IconData) _resolveStatusTheme(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('approved') || lower.contains('disbursed') || lower.contains('verified') || lower.contains('success')) {
      return (AppColors.success, AppColors.successBg, Icons.check_circle_rounded);
    } else if (lower.contains('pending') || lower.contains('processing') || lower.contains('under review') || lower.contains('submitted')) {
      return (AppColors.info, AppColors.infoBg, Icons.hourglass_top_rounded);
    } else if (lower.contains('action') || lower.contains('defect') || lower.contains('warning')) {
      return (AppColors.warning, AppColors.warningBg, Icons.warning_amber_rounded);
    } else if (lower.contains('rejected') || lower.contains('failed') || lower.contains('cancelled')) {
      return (AppColors.error, AppColors.errorBg, Icons.cancel_rounded);
    }
    return (AppColors.textSecondary, AppColors.surfaceVariant, Icons.info_outline_rounded);
  }
}
