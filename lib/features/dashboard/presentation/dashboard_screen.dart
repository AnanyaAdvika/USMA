import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/data/auth_repository.dart';
import '../../applications/data/applications_repository.dart';
import '../../applications/data/schemes_repository.dart';
import '../../disbursements/data/disbursements_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final applicationsAsync = ref.watch(userApplicationsProvider);
    final schemesAsync = ref.watch(schemesListProvider);
    final disbursementsAsync = ref.watch(userDisbursementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'USMA',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
                Text(
                  'Ministry of Tribal Affairs',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_outlined, color: AppColors.primary),
            tooltip: 'Eligibility Checker',
            onPressed: () => context.push(AppRoutes.eligibility),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push(AppRoutes.profile),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userApplicationsProvider);
          ref.invalidate(schemesListProvider);
          ref.invalidate(userDisbursementsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Johar, ${user?.name ?? "Student"}! 🙏',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${user?.tribe ?? "ST"} Community • ${user?.district ?? ""}, ${user?.state ?? ""}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified, color: Colors.amberAccent, size: 14),
                              SizedBox(width: 4),
                              Text('DigiLocker Verified', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Quick stats row
                    Row(
                      children: [
                        _buildStatTile('Active Applications', '2', Icons.assignment_turned_in_outlined),
                        const SizedBox(width: AppSpacing.md),
                        _buildStatTile('Disbursed (FY 26)', '₹85,000', Icons.account_balance_wallet_outlined),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Action Bar / Fast Nav
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.checklist_rtl_rounded,
                      title: 'Check Eligibility',
                      subtitle: 'Find eligible ST schemes',
                      color: AppColors.secondary,
                      onTap: () => context.push(AppRoutes.eligibility),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'MoTA Saathi',
                      subtitle: '24/7 AI multilingual help',
                      color: AppColors.primary,
                      onTap: () => context.push(AppRoutes.chatbot),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Active Application Tracker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Scholarship Tracking',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.applications),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              applicationsAsync.when(
                data: (apps) {
                  if (apps.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Text('No active applications currently in process.'),
                      ),
                    );
                  }
                  final app = apps.first;
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
                            const Divider(),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sanctioned: ₹${app.sanctionedAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                                const Row(
                                  children: [
                                    Text('View Timeline', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                    Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error loading applications: $err'),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // MoTA Available Scholarship Schemes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MoTA Scholarship Schemes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.schemes),
                    child: const Text('Explore All'),
                  ),
                ],
              ),
              schemesAsync.when(
                data: (schemes) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: schemes.take(3).length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, idx) {
                      final scheme = schemes[idx];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.school, color: AppColors.primary),
                          ),
                          title: Text(
                            scheme.title,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Up to ₹${scheme.maxAmount.toStringAsFixed(0)} ${scheme.frequency} • ${scheme.educationLevel}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () => context.push(AppRoutes.schemeDetailPath(scheme.id)),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Recent DBT PFMS Disbursements
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Direct Benefit Transfers (DBT)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.disbursements),
                    child: const Text('History'),
                  ),
                ],
              ),
              disbursementsAsync.when(
                data: (disbursements) {
                  if (disbursements.isEmpty) return const SizedBox.shrink();
                  final item = disbursements.first;
                  return Card(
                    color: AppColors.surfaceVariant.withOpacity(0.5),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.successBg,
                        child: Icon(Icons.check, color: AppColors.success),
                      ),
                      title: Text(
                        '₹${item.amount.toStringAsFixed(0)} Disbursed',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                      subtitle: Text(
                        'UTR: ${item.utrNumber} • ${item.bankName} (..${item.accountLast4})',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: const StatusBadge(status: 'SUCCESS', isSmall: true),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
