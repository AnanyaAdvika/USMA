import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../data/schemes_repository.dart';

class SchemesScreen extends ConsumerStatefulWidget {
  const SchemesScreen({super.key});

  @override
  ConsumerState<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends ConsumerState<SchemesScreen> {
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Post-Matric',
    'Higher Education',
    'Pre-Matric',
    'Overseas',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schemesAsync = ref.watch(schemesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoTA Scholarship Schemes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search schemes (PMS-ST, Fellowship, Top Class)...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: schemesAsync.when(
              data: (schemes) {
                final query = _searchController.text.toLowerCase().trim();
                final filtered = schemes.where((s) {
                  final matchesCat = _selectedCategory == 'All' || s.educationLevel == _selectedCategory;
                  final matchesQuery = query.isEmpty ||
                      s.title.toLowerCase().contains(query) ||
                      s.description.toLowerCase().contains(query);
                  return matchesCat && matchesQuery;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No matching scholarship schemes found.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, idx) {
                    final scheme = filtered[idx];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        scheme.title,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        scheme.ministry,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Text(
                                    scheme.educationLevel,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              scheme.description,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Benefit Amount', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                                    Text(
                                      '₹${scheme.maxAmount.toStringAsFixed(0)} ${scheme.frequency}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(110, 36),
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                  ),
                                  onPressed: () => context.push(AppRoutes.schemeDetailPath(scheme.id)),
                                  child: const Text('View Scheme', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const AppLoadingIndicator(message: 'Loading MoTA schemes...'),
              error: (err, _) => AppErrorView(
                message: err.toString(),
                onRetry: () => ref.refresh(schemesListProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
