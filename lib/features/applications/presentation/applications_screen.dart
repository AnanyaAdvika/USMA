import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/applications_repository.dart';

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(userApplicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Apply New Scheme',
            onPressed: () => context.push(AppRoutes.schemes),
          ),
        ],
      ),
      body: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return AppEmptyStateView(
              title: 'No Active Applications',
              message: 'You have not submitted any scholarship applications yet.',
              action: ElevatedButton(
                onPressed: () => context.push(AppRoutes.schemes),
                child: const Text('Explore MoTA Schemes'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: apps.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, idx) {
              final app = apps[idx];
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () => context.push(AppRoutes.applicationDetailPath(app.id)),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              app.id,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary),
                            ),
                            StatusBadge(status: app.status),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          app.schemeTitle,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${app.instituteName} • ${app.academicYear}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sanctioned: ₹${app.sanctionedAmount.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            const Text(
                              'View Status Timeline →',
                              style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const AppLoadingIndicator(message: 'Fetching applications...'),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
