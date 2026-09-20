import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failures.dart';
import '../domain/models/verification_models.dart';
import '../domain/verification_gateway.dart';
import '../domain/verification_policy.dart';

class MockVerificationGateway implements VerificationGateway {
  MockVerificationGateway({this.policy = const VerificationPolicy()});

  final VerificationPolicy policy;

  @override
  Future<UnifiedVerificationResult> verify(VerificationRequest request) async {
    // SIMULATED: no DigiLocker / AISHE / UIDAI / UDISE+ / APAAR / e-District / UGC-NTA call.
    final sources = [
      SourceVerification(
        source: VerificationSource.digiLocker,
        simulated: true,
        checks: [
          FieldCheck(
            field: 'name',
            declaredValue: request.declaredName,
            sourceValue: request.declaredName,
            matches: true,
          ),
        ],
      ),
      SourceVerification(
        source: VerificationSource.aishe,
        simulated: true,
        checks: [
          FieldCheck(
            field: 'institute',
            declaredValue: request.declaredInstitute,
            sourceValue: '${request.declaredInstitute} (AISHE code pending)',
            matches: false,
          ),
        ],
      ),
      SourceVerification(
        source: VerificationSource.udisePlus,
        simulated: true,
        checks: const [
          FieldCheck(
            field: 'enrolment',
            declaredValue: 'enrolled',
            sourceValue: 'enrolled',
            matches: true,
          ),
        ],
      ),
      SourceVerification(
        source: VerificationSource.apaar,
        simulated: true,
        checks: [
          FieldCheck(
            field: 'apaarId',
            declaredValue: request.declaredApaarId,
            sourceValue: request.declaredApaarId,
            matches: true,
          ),
        ],
      ),
      SourceVerification(
        source: VerificationSource.uidai,
        simulated: true,
        checks: [
          FieldCheck(
            field: 'aadhaarLast4',
            declaredValue: request.declaredAadhaarLast4,
            sourceValue: request.declaredAadhaarLast4,
            matches: true,
          ),
        ],
      ),
      SourceVerification(
        source: VerificationSource.stateEDistrict,
        simulated: true,
        checks: [
          FieldCheck(
            field: 'stCertificate',
            declaredValue: request.declaredCasteCertificateId,
            sourceValue: request.declaredCasteCertificateId,
            matches: true,
          ),
        ],
      ),
      SourceVerification(
        source: VerificationSource.ugcNta,
        simulated: true,
        checks: const [
          FieldCheck(
            field: 'academicRecord',
            declaredValue: 'declared',
            sourceValue: 'pending NTA match',
            matches: false,
          ),
        ],
      ),
    ];

    return policy.decide(
      applicationId: request.applicationId,
      sources: sources,
      simulated: true,
    );
  }
}

class LiveVerificationGateway implements VerificationGateway {
  @override
  Future<UnifiedVerificationResult> verify(VerificationRequest request) async {
    throw const IntegrationFailure(
      'Unified verification (DigiLocker, AISHE, UDISE+, APAAR, UIDAI, State e-District, UGC-NTA) must run on the USMA backend. This client does not call government endpoints.',
    );
  }
}

final verificationGatewayProvider = Provider<VerificationGateway>((ref) {
  if (AppConfig.isDemo) return MockVerificationGateway();
  return LiveVerificationGateway();
});
