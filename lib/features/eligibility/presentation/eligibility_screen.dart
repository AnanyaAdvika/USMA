import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/tokens.dart';
import '../../applications/data/schemes_repository.dart';
import '../../applications/domain/models/scheme_model.dart';

class EligibilityScreen extends ConsumerStatefulWidget {
  const EligibilityScreen({super.key});

  @override
  ConsumerState<EligibilityScreen> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends ConsumerState<EligibilityScreen> {
  String _selectedCategory = 'ST';
  String _educationLevel = 'Post-Matric';
  double _income = 180000.0;
  List<SchemeModel>? _eligibleSchemes;
  bool _hasChecked = false;

  final List<String> _educationLevels = [
    'Pre-Matric',
    'Post-Matric',
    'Higher Education',
    'Overseas',
  ];

  void _calculateEligibility() {
    final schemes = ref.read(schemesListProvider).value ?? SchemesRepository.defaultSchemes;
    final results = schemes.where((s) {
      final matchesCategory = _selectedCategory == 'ST' || _selectedCategory == 'PVTG';
      final matchesIncome = _income <= s.maxFamilyIncome;
      final matchesEdu = s.educationLevel == _educationLevel || _educationLevel == 'Post-Matric';
      return matchesCategory && matchesIncome && matchesEdu;
    }).toList();

    setState(() {
      _eligibleSchemes = results;
      _hasChecked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoTA Eligibility Checker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find Your Eligible Scholarships',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter your criteria to filter Ministry of Tribal Affairs schemes instant eligibility.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),

            const Text('Social Category', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'ST', label: Text('Scheduled Tribe (ST)')),
                ButtonSegment(value: 'PVTG', label: Text('PVTG Tribe')),
              ],
              selected: {_selectedCategory},
              onSelectionChanged: (set) => setState(() => _selectedCategory = set.first),
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text('Level of Education', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _educationLevel,
              items: _educationLevels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _educationLevel = val);
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Annual Family Income (₹)', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '₹${_income.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            Slider(
              value: _income,
              min: 50000.0,
              max: 1000000.0,
              divisions: 19,
              activeColor: AppColors.primary,
              label: '₹${_income.toStringAsFixed(0)}',
              onChanged: (val) => setState(() => _income = val),
            ),
            const SizedBox(height: AppSpacing.xl),

            ElevatedButton.icon(
              onPressed: _calculateEligibility,
              icon: const Icon(Icons.search),
              label: const Text('Check Available Schemes'),
            ),

            if (_hasChecked) ...[
              const SizedBox(height: AppSpacing.xxl),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Eligible Schemes (${_eligibleSchemes?.length ?? 0})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_eligibleSchemes == null || _eligibleSchemes!.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text('No schemes match the criteria. Try adjusting income or education level.'),
                  ),
                )
              else
                ..._eligibleSchemes!.map(
                  (scheme) => Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ListTile(
                      title: Text(scheme.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('Up to ₹${scheme.maxAmount.toStringAsFixed(0)} • ${scheme.frequency}'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(minimumSize: const Size(80, 32)),
                        onPressed: () => context.push(AppRoutes.schemeDetailPath(scheme.id)),
                        child: const Text('Apply', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
