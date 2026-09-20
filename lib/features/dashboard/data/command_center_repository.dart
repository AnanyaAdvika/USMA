import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/models/command_center_models.dart';

abstract class ICommandCenterRepository {
  Future<List<DeficiencyItem>> getDeficiencies(String userId);
  Future<void> resolveDeficiency(String deficiencyId);
  Future<List<FamilyMemberScholarship>> getFamilyScholarships(String userId);
}

class MockCommandCenterRepository implements ICommandCenterRepository {
  final List<DeficiencyItem> _deficiencies = [
    DeficiencyItem(
      id: 'DEF-2026-001',
      applicationId: 'APP-2026-ST-8821',
      schemeTitle: 'Post-Matric Scholarship for ST Students',
      issue: 'Annual Income Certificate validity expired for current financial year',
      source: 'State e-District Verification Gateway',
      date: DateTime.now().subtract(const Duration(days: 3)),
      deadline: DateTime.now().add(const Duration(days: 4)),
      severity: DeficiencySeverity.critical,
      actionRequired: 'Upload renewed FY 2026-27 Income Certificate issued by Tehsildar / SDO.',
      requiredDocumentType: 'INCOME_CERTIFICATE',
    ),
    DeficiencyItem(
      id: 'DEF-2026-002',
      applicationId: 'APP-2026-ST-8821',
      schemeTitle: 'Post-Matric Scholarship for ST Students',
      issue: 'Aadhaar-NPCI mapper bank seeding status pending confirmation',
      source: 'PFMS DBT Gateway',
      date: DateTime.now().subtract(const Duration(days: 1)),
      deadline: DateTime.now().add(const Duration(days: 7)),
      severity: DeficiencySeverity.moderate,
      actionRequired: 'Verify DBT bank account seeding in settings to prevent payment bounce.',
      requiredDocumentType: 'BANK_PASSBOOK',
    ),
  ];

  final List<FamilyMemberScholarship> _familyScholarships = [
    const FamilyMemberScholarship(
      memberId: 'FAM-001',
      memberName: 'Rahul Marandi',
      relationship: 'Brother',
      schemeId: 'pre_matric_st',
      schemeName: 'Pre-Matric Scholarship for ST Students',
      currentStatus: 'DISBURSED',
      sanctionedAmount: 5250,
      disbursedAmount: 5250,
      academicYear: '2026-2027',
      hasDeficiency: false,
    ),
    const FamilyMemberScholarship(
      memberId: 'FAM-002',
      memberName: 'Sunita Marandi (Self)',
      relationship: 'Self',
      schemeId: 'post_matric_st',
      schemeName: 'Post-Matric Scholarship for ST Students',
      currentStatus: 'SANCTIONED',
      sanctionedAmount: 85000,
      disbursedAmount: 42500,
      academicYear: '2026-2027',
      hasDeficiency: true,
    ),
    const FamilyMemberScholarship(
      memberId: 'FAM-003',
      memberName: 'Anjali Marandi',
      relationship: 'Sister',
      schemeId: 'top_class_st',
      schemeName: 'Top Class Scholarship for ST Students (IIT Bombay)',
      currentStatus: 'VERIFICATION_PENDING',
      sanctionedAmount: 286000,
      disbursedAmount: 0,
      academicYear: '2026-2027',
      hasDeficiency: false,
    ),
  ];

  @override
  Future<List<DeficiencyItem>> getDeficiencies(String userId) async {
    return List.unmodifiable(_deficiencies);
  }

  @override
  Future<void> resolveDeficiency(String deficiencyId) async {
    final idx = _deficiencies.indexWhere((d) => d.id == deficiencyId);
    if (idx != -1) {
      final old = _deficiencies[idx];
      _deficiencies[idx] = DeficiencyItem(
        id: old.id,
        applicationId: old.applicationId,
        schemeTitle: old.schemeTitle,
        issue: old.issue,
        source: old.source,
        date: old.date,
        deadline: old.deadline,
        severity: old.severity,
        actionRequired: old.actionRequired,
        requiredDocumentType: old.requiredDocumentType,
        isResolved: true,
      );
    }
  }

  @override
  Future<List<FamilyMemberScholarship>> getFamilyScholarships(String userId) async {
    return List.unmodifiable(_familyScholarships);
  }
}

final commandCenterRepositoryProvider = Provider<ICommandCenterRepository>((ref) {
  return MockCommandCenterRepository();
});

final userDeficienciesProvider = FutureProvider<List<DeficiencyItem>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(commandCenterRepositoryProvider);
  return repo.getDeficiencies(user?.id ?? 'demo_user_001');
});

final familyScholarshipsProvider = FutureProvider<List<FamilyMemberScholarship>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(commandCenterRepositoryProvider);
  return repo.getFamilyScholarships(user?.id ?? 'demo_user_001');
});
