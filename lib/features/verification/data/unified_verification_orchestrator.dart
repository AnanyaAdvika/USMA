import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/unified_verification_models.dart';

abstract class IUnifiedVerificationOrchestrator {
  Future<List<VerificationResult>> runUnifiedVerification(String userId);
  Future<ExtractedDocumentIntel> extractAndVerifyDocument({
    required String documentType,
    required String fileUrl,
    required Map<String, String> studentProfile,
  });
  Future<void> submitForManualReview(VerificationType type, String reason);
}

class MockUnifiedVerificationOrchestrator implements IUnifiedVerificationOrchestrator {
  @override
  Future<List<VerificationResult>> runUnifiedVerification(String userId) async {
    final now = DateTime.now();
    return [
      VerificationResult(
        verificationType: VerificationType.identity,
        sourceSystem: 'UIDAI Aadhaar Gateway (Mock API)',
        status: VerificationStatus.verified,
        confidence: 0.99,
        verifiedAt: now.subtract(const Duration(days: 30)),
        requiresManualReview: false,
      ),
      VerificationResult(
        verificationType: VerificationType.stCertificate,
        sourceSystem: 'State e-District Portal (Mock API)',
        status: VerificationStatus.verified,
        confidence: 0.98,
        verifiedAt: now.subtract(const Duration(days: 25)),
        requiresManualReview: false,
      ),
      VerificationResult(
        verificationType: VerificationType.incomeCertificate,
        sourceSystem: 'State Revenue Department (Mock API)',
        status: VerificationStatus.manualReview,
        confidence: 0.72,
        verifiedAt: now.subtract(const Duration(days: 2)),
        requiresManualReview: true,
        mismatchFields: const [
          MismatchField(
            fieldName: 'Applicant / Parent Name Spelling',
            declaredValue: 'Sunita Marandi',
            certificateValue: 'Sunita M.',
            reason: 'Partial abbreviation mismatch between application profile and revenue record.',
          ),
        ],
        errorMessage: 'Name variance detected. Routed to manual verification officer.',
      ),
      VerificationResult(
        verificationType: VerificationType.academicRecord,
        sourceSystem: 'DigiLocker CBSE / State Board (Mock API)',
        status: VerificationStatus.verified,
        confidence: 0.96,
        verifiedAt: now.subtract(const Duration(days: 20)),
        requiresManualReview: false,
      ),
      VerificationResult(
        verificationType: VerificationType.institution,
        sourceSystem: 'AISHE / UDISE+ Registry (Mock API)',
        status: VerificationStatus.verified,
        confidence: 0.95,
        verifiedAt: now.subtract(const Duration(days: 15)),
        requiresManualReview: false,
      ),
      VerificationResult(
        verificationType: VerificationType.bankAccount,
        sourceSystem: 'PFMS / NPCI Aadhaar Mapper (Mock API)',
        status: VerificationStatus.pending,
        confidence: 0.80,
        verifiedAt: now,
        requiresManualReview: false,
        errorMessage: 'Awaiting daily batch settlement confirmation from NPCI mapper.',
      ),
    ];
  }

  @override
  Future<ExtractedDocumentIntel> extractAndVerifyDocument({
    required String documentType,
    required String fileUrl,
    required Map<String, String> studentProfile,
  }) async {
    if (documentType.toUpperCase().contains('INCOME')) {
      return const ExtractedDocumentIntel(
        documentType: 'INCOME_CERTIFICATE',
        extractedFields: {
          'Name': 'Sunita M.',
          'Annual Income': '₹1,80,000',
          'Issuing Authority': 'Tehsildar, Baripada',
          'Validity': '2026-2027',
        },
        mismatches: [
          MismatchField(
            fieldName: 'Name',
            declaredValue: 'Sunita Marandi',
            certificateValue: 'Sunita M.',
            reason: 'Initial vs expanded surname variance.',
          ),
        ],
        confidence: 0.88,
        isVerified: false,
      );
    }

    return const ExtractedDocumentIntel(
      documentType: 'CASTE_CERTIFICATE',
      extractedFields: {
        'Name': 'Sunita Marandi',
        'Tribe': 'Santhal (Scheduled Tribe)',
        'Certificate No': 'ST-2022-8819',
        'State': 'Odisha',
      },
      mismatches: [],
      confidence: 0.98,
      isVerified: true,
    );
  }

  @override
  Future<void> submitForManualReview(VerificationType type, String reason) async {
    // Simulated submission to District Nodal Officer workflow
  }
}

final unifiedVerificationOrchestratorProvider =
    Provider<IUnifiedVerificationOrchestrator>((ref) {
  return MockUnifiedVerificationOrchestrator();
});

final unifiedVerificationListProvider =
    FutureProvider<List<VerificationResult>>((ref) async {
  return ref.watch(unifiedVerificationOrchestratorProvider).runUnifiedVerification('demo_user_001');
});
