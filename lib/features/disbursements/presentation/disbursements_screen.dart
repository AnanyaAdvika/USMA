import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/disbursements_repository.dart';

class DisbursementsScreen extends ConsumerWidget {
  const DisbursementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disbursementsAsync = ref.watch(userDisbursementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Benefit Transfer (DBT)'),
      ),
      body: disbursementsAsync.when(
        data: (disbursements) {
          if (disbursements.isEmpty) {
            return const Center(child: Text('No disbursement records found.'));
          }

          final totalDisbursed = disbursements
              .where((d) => d.pfmsStatus == 'SUCCESS')
              .fold<double>(0.0, (sum, d) => sum + d.amount);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.success, Color(0xFF15803D)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total DBT Scholarship Credited',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${totalDisbursed.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Row(
                        children: [
                          Icon(Icons.account_balance, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'State Bank of India (Aadhaar Seeded)',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const Text(
                  'PFMS Transaction History',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: disbursements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, idx) {
                    final item = disbursements[idx];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.academicInstallment,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                StatusBadge(status: item.pfmsStatus),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.schemeTitle,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const Divider(),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('UTR / Bank Reference', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                                    Text(item.utrNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Text(
                                  '₹${item.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const AppLoadingIndicator(),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
