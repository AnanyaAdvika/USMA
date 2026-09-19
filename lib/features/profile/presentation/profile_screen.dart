import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/tokens.dart';
import '../../auth/data/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficiary Student Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0] : 'S',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    user?.name ?? 'Sunita Marandi',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ST Community • ${user?.tribe ?? "Santhal"}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Profile info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _buildInfoTile('Aadhaar Number', 'XXXX-XXXX-${user?.aadhaarLast4 ?? "4829"}', Icons.fingerprint, true),
                    const Divider(),
                    _buildInfoTile('APAAR Student ID', user?.apaarId ?? 'APAAR-2026-9938-11', Icons.badge, true),
                    const Divider(),
                    _buildInfoTile('Seeded Bank Account', 'State Bank of India (..${user?.bankAccountLast4 ?? "3819"})', Icons.account_balance, true),
                    const Divider(),
                    _buildInfoTile('State & District', '${user?.state ?? "Odisha"}, ${user?.district ?? "Mayurbhanj"}', Icons.location_on, false),
                    const Divider(),
                    _buildInfoTile('Annual Family Income', '₹${(user?.familyAnnualIncome ?? 180000).toStringAsFixed(0)}', Icons.currency_rupee, false),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.ekyc),
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text('Update e-KYC Verification'),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (isVerified)
            const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 16),
                SizedBox(width: 4),
                Text('Verified', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
        ],
      ),
    );
  }
}
