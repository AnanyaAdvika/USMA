import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../data/unified_verification_orchestrator.dart';
import '../domain/models/unified_verification_models.dart';

class UnifiedVerificationScreen extends ConsumerWidget {
  const UnifiedVerificationScreen({super.key});

  void _showMismatchDialog(BuildContext context, WidgetRef ref, VerificationResult res) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Information Mismatch Detected',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A variance was detected between your application profile and the official registry source.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final field in res.mismatchFields) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(field.fieldName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('Application: ', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          Text(field.declaredValue, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Certificate: ', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                          Text(field.certificateValue, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Reason: ${field.reason}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.infoBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: const Text(
                  'Note: Government policy prevents automatic rejection for spelling differences. This item is routed for Officer Review.',
                  style: TextStyle(fontSize: 10, color: AppColors.info, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Dismiss'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(unifiedVerificationOrchestratorProvider).submitForManualReview(res.verificationType, 'Student requested review confirmation');
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Submitted to Verification Officer for manual review.')),
                  );
                }
              },
              child: const Text('Submit for Review'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verificationsAsync = ref.watch(unifiedVerificationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unified Verification Layer'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: 6),
            child: const Text(
              'Demonstration Architecture • Multi-Source Mock API',
              style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
      body: verificationsAsync.when(
        data: (results) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.hub_outlined, color: AppColors.primary, size: 22),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Multi-source verification checks identity, caste, revenue, school, and DBT registry simultaneously via mock orchestrator.',
                          style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                const Text(
                  'Verification Status Breakdown',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),

                for (final item in results)
                  Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      side: BorderSide(
                        color: _getCardBorderColor(item.status),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _getStatusIcon(item.status),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  item.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              _buildStatusBadge(item.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Source: ${item.sourceSystem}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                          ),
                          if (item.errorMessage != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.errorMessage!,
                              style: TextStyle(
                                fontSize: 11,
                                color: item.status == VerificationStatus.manualReview ? AppColors.warning : AppColors.error,
                              ),
                            ),
                          ],
                          if (item.mismatchFields.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '1 variance detected',
                                  style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.bold),
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                  onPressed: () => _showMismatchDialog(context, ref, item),
                                  icon: const Icon(Icons.compare_arrows, size: 14),
                                  label: const Text('View Mismatch & Review', style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const AppLoadingIndicator(message: 'Orchestrating multi-source verification...'),
        error: (e, _) => AppErrorView(message: e.toString()),
      ),
    );
  }

  Widget _getStatusIcon(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return const CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.successBg,
          child: Icon(Icons.check, size: 14, color: AppColors.success),
        );
      case VerificationStatus.manualReview:
        return const CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.warningBg,
          child: Icon(Icons.priority_high, size: 14, color: AppColors.warning),
        );
      case VerificationStatus.pending:
        return const CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.infoBg,
          child: Icon(Icons.hourglass_empty, size: 14, color: AppColors.info),
        );
      case VerificationStatus.mismatch:
      case VerificationStatus.failed:
        return const CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.errorBg,
          child: Icon(Icons.close, size: 14, color: AppColors.error),
        );
      case VerificationStatus.sourceUnavailable:
        return const CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.surfaceVariant,
          child: Icon(Icons.cloud_off, size: 14, color: AppColors.textSecondary),
        );
    }
  }

  Widget _buildStatusBadge(VerificationStatus status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case VerificationStatus.verified:
        bg = AppColors.successBg;
        text = AppColors.success;
        label = 'Verified';
        break;
      case VerificationStatus.manualReview:
        bg = AppColors.warningBg;
        text = AppColors.warning;
        label = 'Manual Review';
        break;
      case VerificationStatus.pending:
        bg = AppColors.infoBg;
        text = AppColors.info;
        label = 'Pending';
        break;
      case VerificationStatus.mismatch:
        bg = AppColors.warningBg;
        text = AppColors.warning;
        label = 'Mismatch';
        break;
      case VerificationStatus.failed:
        bg = AppColors.errorBg;
        text = AppColors.error;
        label = 'Failed';
        break;
      case VerificationStatus.sourceUnavailable:
        bg = AppColors.surfaceVariant;
        text = AppColors.textSecondary;
        label = 'Unavailable';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }

  Color _getCardBorderColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return AppColors.success.withValues(alpha: 0.3);
      case VerificationStatus.manualReview:
        return AppColors.warning.withValues(alpha: 0.5);
      case VerificationStatus.failed:
        return AppColors.error.withValues(alpha: 0.4);
      default:
        return AppColors.border;
    }
  }
}
