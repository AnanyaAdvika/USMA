import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/data/auth_repository.dart';
import '../data/documents_repository.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(userDocumentsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DigiLocker Document Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sync DigiLocker',
            onPressed: () async {
              final uid = user?.id ?? 'demo_user_001';
              await ref.read(documentsRepositoryProvider).syncDigiLocker(uid);
              ref.invalidate(userDocumentsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('DigiLocker documents synced successfully!')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.primary.withOpacity(0.08),
            child: const Row(
              children: [
                Icon(Icons.verified, color: AppColors.primary, size: 20),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Documents fetched via DigiLocker are government-verified and eliminate physical paper submissions.',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: docsAsync.when(
              data: (docs) {
                if (docs.isEmpty) {
                  return const Center(child: Text('No verified documents found.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, idx) {
                    final doc = docs[idx];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: doc.source == 'DIGILOCKER' ? AppColors.infoBg : AppColors.surfaceVariant,
                          child: Icon(
                            doc.source == 'DIGILOCKER' ? Icons.verified_user : Icons.description,
                            color: doc.source == 'DIGILOCKER' ? AppColors.info : AppColors.textSecondary,
                          ),
                        ),
                        title: Text(doc.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Issued: ${doc.issuedDate.day}/${doc.issuedDate.month}/${doc.issuedDate.year} • ${doc.source}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        trailing: const StatusBadge(status: 'VERIFIED', isSmall: true),
                      ),
                    );
                  },
                );
              },
              loading: () => const AppLoadingIndicator(message: 'Connecting to DigiLocker...'),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
