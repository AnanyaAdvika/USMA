import 'package:flutter_test/flutter_test.dart';
import 'package:usma/features/applications/domain/models/application_model.dart';
import 'package:usma/features/dashboard/domain/models/command_center_models.dart';
import 'package:usma/features/disbursements/domain/models/disbursement_model.dart';

void main() {
  group('Command Center, Lifecycle & RBAC Tests', () {
    // 1. Application Lifecycle & Custom Scheme Workflows
    test('1. Application lifecycle supports multi-stage verification transitions', () {
      final now = DateTime.now();
      final app = ApplicationModel(
        id: 'APP-2026-TEST-01',
        userId: 'user_01',
        schemeId: 'top_class_st',
        schemeTitle: 'Top Class Scholarship for ST Students',
        academicYear: '2026-2027',
        instituteName: 'IIT Delhi',
        courseName: 'B.Tech Electrical',
        sanctionedAmount: 286000,
        status: 'sanctioned',
        submittedAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 1)),
        timeline: [
          TimelineEvent(title: 'Submitted', description: 'DigiLocker verified submission', timestamp: now.subtract(const Duration(days: 20)), isCompleted: true),
          TimelineEvent(title: 'Institute Verification', description: 'Dean Academic approved', timestamp: now.subtract(const Duration(days: 15)), isCompleted: true),
          TimelineEvent(title: 'MoTA Sanction', description: 'Central quota sanction issued', timestamp: now.subtract(const Duration(days: 1)), isCompleted: true),
          TimelineEvent(title: 'PFMS DBT', description: 'Tuition and living allowance disbursement', timestamp: now.add(const Duration(days: 5)), isCompleted: false),
        ],
      );

      expect(app.isActive, isTrue);
      expect(app.timeline.length, 4);
      expect(app.timeline[0].isCompleted, isTrue);
      expect(app.timeline[3].isCompleted, isFalse);
    });

    // 2. Deficiency Item Lifecycle
    test('2. Deficiency item tracks severity, action required, and resolution', () {
      final now = DateTime.now();
      final def = DeficiencyItem(
        id: 'DEF-TEST-01',
        applicationId: 'APP-2026-TEST-01',
        schemeTitle: 'Top Class Scholarship for ST Students',
        issue: 'Fee structure receipt required signed by Registrar',
        source: 'MoTA Central Project Officer',
        date: now.subtract(const Duration(days: 2)),
        deadline: now.add(const Duration(days: 5)),
        severity: DeficiencySeverity.critical,
        actionRequired: 'Upload attested institute fee structure.',
        requiredDocumentType: 'FEE_RECEIPT',
        isResolved: false,
      );

      expect(def.severity, DeficiencySeverity.critical);
      expect(def.isResolved, isFalse);

      final map = def.toMap();
      expect(map['severity'], 'CRITICAL');
      expect(map['actionRequired'], contains('Upload attested'));
    });

    // 3. Payment Status & DBT Modeling
    test('3. DBT Disbursement model encapsulates PFMS transaction references', () {
      final now = DateTime.now();
      final disb = DisbursementModel(
        id: 'DISB-TEST-01',
        applicationId: 'APP-2026-TEST-01',
        schemeTitle: 'Top Class Scholarship',
        amount: 143000,
        utrNumber: 'PFMS-UTR-2026-9921',
        pfmsStatus: 'SUCCESS',
        bankName: 'State Bank of India',
        accountLast4: '4829',
        disbursementDate: now,
        academicInstallment: 'Installment 1 of 2',
      );

      expect(disb.pfmsStatus, 'SUCCESS');
      expect(disb.utrNumber, 'PFMS-UTR-2026-9921');
      expect(disb.amount, 143000);
    });

    // 4. Family Member Scholarship Overview
    test('4. Family member scholarship model structures sibling awards', () {
      const fam = FamilyMemberScholarship(
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
      );

      expect(fam.relationship, 'Brother');
      expect(fam.currentStatus, 'DISBURSED');
      expect(fam.sanctionedAmount, 5250);
    });
  });
}
