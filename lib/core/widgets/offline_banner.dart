import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/connectivity_provider.dart';
import '../theme/tokens.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: AppColors.error,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs + 2,
        horizontal: AppSpacing.md,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
          SizedBox(width: AppSpacing.sm),
          Text(
            'You are offline. Showing cached scholarship data.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
