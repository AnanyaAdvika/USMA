import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/notifications_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
      ),
      body: notifsAsync.when(
        data: (notifs) {
          if (notifs.isEmpty) {
            return const Center(child: Text('No notifications at this time.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: notifs.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, idx) {
              final item = notifs[idx];
              return Card(
                color: item.isRead ? AppColors.surface : AppColors.infoBg.withOpacity(0.3),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.notifications_active, color: AppColors.primary),
                  ),
                  title: Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(item.body, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        '${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year} • ${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  onTap: () {
                    ref.read(notificationsRepositoryProvider).markAsRead(item.id);
                    ref.invalidate(userNotificationsProvider);
                  },
                ),
              );
            },
          );
        },
        loading: () => const AppLoadingIndicator(),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
