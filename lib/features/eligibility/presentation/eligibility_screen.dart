import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/tokens.dart';
import '../../documents/data/documents_repository.dart';
import '../../applications/data/schemes_repository.dart';
import '../domain/eligibility_engine.dart';
import '../domain/eligibility_result.dart';

class EligibilityScreen extends ConsumerStatefulWidget {
  const EligibilityScreen({super.key});

  @override
  ConsumerState<EligibilityScreen> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends ConsumerState<EligibilityScreen> {
  String _selectedCategory = 'ST';
  String _educationLevel = 'Post-Matric';
  String _institutionType = 'PREMIER_NOTIFIED';
  double _income = 200000.0;
  bool _hasChecked = false;
  List<SchemeEligibilityEvaluation>? _evaluations;

  final List<String> _educationLevels = [
    'Pre-Matric (Class IX & X)',
    'Post-Matric (Class XI - Graduation)',
    'Higher Education (Premier Institutes)',
    'Research (M.Phil & Ph.D)',
    'Overseas Studies',
  ];

  final List<String> _institutionTypes = [
    '265 MoTA-Notified Premier Institute',
    'Recognized Government / Private School / College',
    'Foreign University (Top 500 QS)',
  ];

  void _calculateEligibility() {
    final motaSchemes = ref.read(motaSchemesListProvider).value ?? const [];
    final docs = ref.read(userDocumentsProvider).asData?.value ?? const [];

    String mappedEduLevel = 'Post-Matric';
    if (_educationLevel.contains('Pre-Matric')) {
      mappedEduLevel = 'Pre-Matric';
    } else if (_educationLevel.contains('Higher Education')) {
      mappedEduLevel = 'Higher Education';
    } else if (_educationLevel.contains('Research')) {
      mappedEduLevel = 'Research';
    } else if (_educationLevel.contains('Overseas')) {
      mappedEduLevel = 'Overseas';
    }

    String mappedInst = 'REGULAR_RECOGNIZED';
    if (_institutionType.contains('Premier')) {
      mappedInst = 'PREMIER_NOTIFIED';
    } else if (_institutionType.contains('Foreign')) {
      mappedInst = 'FOREIGN_QS500';
    }

    final profile = StudentEligibilityProfile(
      isScheduledTribe: _selectedCategory == 'ST' || _selectedCategory == 'PVTG',
      socialCategory: _selectedCategory,
      isPvtg: _selectedCategory == 'PVTG',
      familyAnnualIncome: _income,
      educationLevel: mappedEduLevel,
      currentClassOrDegree: mappedEduLevel,
      institutionType: mappedInst,
      hasAadhaar: true,
      hasAadhaarSeededBank: true,
      availableDocumentTypes: docs.map((d) => d.type).toList(),
    );

    final evals = MoTAEligibilityEngine.evaluateAllSchemes(
      profile: profile,
      schemes: motaSchemes,
    );

    setState(() {
      _evaluations = evals;
      _hasChecked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoTA Dynamic Eligibility Engine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Official Scheme Eligibility Check',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Evaluates your criteria against statutory Ministry of Tribal Affairs guidelines.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),

            const Text('Social Category (Statutory Requirement)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'ST', label: Text('Scheduled Tribe (ST)')),
                ButtonSegment(value: 'PVTG', label: Text('PVTG Tribe (Priority)')),
                ButtonSegment(value: 'GEN', label: Text('General / Other')),
              ],
              selected: {_selectedCategory},
              onSelectionChanged: (set) => setState(() => _selectedCategory = set.first),
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text('Education Level', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _educationLevel,
              isExpanded: true,
              items: _educationLevels.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _educationLevel = val);
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text('Institution Category', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _institutionType,
              isExpanded: true,
              items: _institutionTypes.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _institutionType = val);
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Annual Family Income', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '₹${_income.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
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
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text('Evaluate Eligibility Across All Schemes'),
            ),

            if (_hasChecked && _evaluations != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Evaluation Results (${_evaluations!.length} MoTA Schemes)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text('Source: MoTA', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              for (final eval in _evaluations!)
                Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side: BorderSide(
                      color: eval.isEligible
                          ? AppColors.success.withValues(alpha: 0.5)
                          : AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                eval.schemeName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(eval.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          eval.recommendation,
                          style: TextStyle(
                            fontSize: 12,
                            color: eval.isEligible ? AppColors.textSecondary : AppColors.error,
                          ),
                        ),
                        if (eval.failedCriteria.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          for (final fail in eval.failedCriteria)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.close, color: AppColors.error, size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(fail, style: const TextStyle(fontSize: 11, color: AppColors.error))),
                                ],
                              ),
                            ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => context.push(AppRoutes.schemeDetailPath(eval.schemeId)),
                            icon: const Icon(Icons.arrow_forward, size: 14),
                            label: const Text('View Scheme & Rules', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(EligibilityStatus status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case EligibilityStatus.eligible:
        bg = AppColors.successBg;
        text = AppColors.success;
        label = 'Eligible';
        break;
      case EligibilityStatus.conditionallyEligible:
        bg = AppColors.warningBg;
        text = AppColors.warning;
        label = 'Doc Pending';
        break;
      case EligibilityStatus.ineligible:
        bg = AppColors.errorBg;
        text = AppColors.error;
        label = 'Ineligible';
        break;
      case EligibilityStatus.incompleteProfile:
        bg = AppColors.surfaceVariant;
        text = AppColors.textSecondary;
        label = 'Incomplete';
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
}
