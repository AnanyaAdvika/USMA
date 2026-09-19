import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../data/schemes_repository.dart';

class SchemeDetailScreen extends ConsumerWidget {
  final String schemeId;

  const SchemeDetailScreen({super.key, required this.schemeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemeAsync = ref.watch(schemeDetailProvider(schemeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheme Details'),
      ),
      body: schemeAsync.when(
        data: (scheme) {
          if (scheme == null) {
            return const Center(child: Text('Scheme not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scheme.ministry,
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _buildDetailBadge(
                            icon: Icons.currency_rupee_rounded,
                            label: 'Benefit',
                            value: '₹${scheme.maxAmount.toStringAsFixed(0)} ${scheme.frequency}',
                          ),
                          const SizedBox(width: AppSpacing.md),
                          _buildDetailBadge(
                            icon: Icons.event_rounded,
                            label: 'Deadline',
                            value: '${scheme.deadline.day}/${scheme.deadline.month}/${scheme.deadline.year}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Scheme Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  scheme.description,
                  style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Eligibility Criteria',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildCriterionItem('Belong to recognized Scheduled Tribe (ST) community.'),
                _buildCriterionItem('Annual family income from all sources must not exceed ₹${scheme.maxFamilyIncome.toStringAsFixed(0)}.'),
                _buildCriterionItem('Studying in recognized school/institute/university (${scheme.educationLevel}).'),
                _buildCriterionItem('Must hold a valid Aadhaar-seeded bank account for DBT payment.'),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Required Documents (DigiLocker / Manual)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...scheme.requiredDocuments.map((doc) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Text(doc, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    )),
                const SizedBox(height: AppSpacing.xxl),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.applySchemePath(scheme.id));
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Apply Now (e-Verification)'),
                ),
              ],
            ),
          );
        },
        loading: () => const AppLoadingIndicator(),
        error: (err, _) => AppErrorView(message: err.toString()),
      ),
    );
  }

  Widget _buildDetailBadge({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              ],
            ),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildCriterionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 4),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}
