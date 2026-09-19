import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class AppErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorView({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.errorBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(140, 44),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
