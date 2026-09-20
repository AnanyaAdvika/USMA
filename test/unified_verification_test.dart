import 'package:flutter_test/flutter_test.dart';
import 'package:usma/features/coverage_gap/domain/models/coverage_gap_analytics_model.dart';
import 'package:usma/features/verification/domain/models/unified_verification_models.dart';

void main() {
  group('Unified Verification, Mismatch & AI Analytics Tests', () {
    // 1. Verification Result Model with Mismatch Fields
    test('1. VerificationResult model tracks status and variance details without auto-rejection', () {
      final now = DateTime.now();
      const mismatch = MismatchField(
        fieldName: 'Name',
        declaredValue: 'Sunita Marandi',
        certificateValue: 'Sunita M.',
        reason: 'Abbreviation difference in father/applicant surname',
      );

      final result = VerificationResult(
        verificationType: VerificationType.incomeCertificate,
        sourceSystem: 'State Revenue Department (Mock API)',
        status: VerificationStatus.manualReview,
        confidence: 0.85,
        verifiedAt: now,
        mismatchFields: const [mismatch],
        requiresManualReview: true,
      );

      expect(result.status, VerificationStatus.manualReview);
      expect(result.requiresManualReview, isTrue);
      expect(result.mismatchFields.length, 1);
      expect(result.mismatchFields.first.declaredValue, 'Sunita Marandi');
      expect(result.mismatchFields.first.certificateValue, 'Sunita M.');
    });

    // 2. Document Intelligence Extraction & Field Matching
    test('2. ExtractedDocumentIntel extracts structured fields and identifies discrepancies', () {
      const intel = ExtractedDocumentIntel(
        documentType: 'INCOME_CERTIFICATE',
        extractedFields: {
          'Name': 'Sunita M.',
          'Annual Income': '₹1,80,000',
          'Validity': '2026-2027',
        },
        mismatches: [
          MismatchField(
            fieldName: 'Name',
            declaredValue: 'Sunita Marandi',
            certificateValue: 'Sunita M.',
            reason: 'Name spelling variation',
          ),
        ],
        confidence: 0.90,
        isVerified: false,
      );

      expect(intel.documentType, 'INCOME_CERTIFICATE');
      expect(intel.extractedFields['Annual Income'], '₹1,80,000');
      expect(intel.mismatches.isNotEmpty, isTrue);
      expect(intel.isVerified, isFalse);
    });

    // 3. Coverage Gap & Unreached Beneficiary Detection
    test('3. Coverage Gap Record identifies enrolled non-beneficiaries', () {
      const record = STStudentEnrollmentRecord(
        studentId: 'ST-2026-OD-002',
        studentName: 'Biren Hansdah',
        state: 'Odisha',
        district: 'Mayurbhanj',
        institutionName: 'Baripada Govt High School',
        educationLevel: 'Pre-Matric',
        academicYear: '2026-2027',
        familyAnnualIncome: 95000,
        statusCategory: 'POTENTIALLY_ELIGIBLE_NOT_APPLIED',
        mismatchDescription: 'Enrolled in Class 9, eligible for Pre-Matric but no application submitted in current cycle.',
      );

      expect(record.statusCategory, 'POTENTIALLY_ELIGIBLE_NOT_APPLIED');
      expect(record.activeSchemeName, isNull);
      expect(record.familyAnnualIncome, lessThanOrEqualTo(250000));
    });
  });
}
