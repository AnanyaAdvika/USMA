// ============================================================
// USMA — Mock Integration Providers
// mock_providers.dart
//
// STATUS: MOCK / DEMONSTRATION ARCHITECTURE
//
// Every class in this file is a MOCK provider.
// It returns deterministic simulated data for demo purposes.
//
// FUTURE INTEGRATION:
//   Replace each class with a real HTTP adapter implementing
//   IntegrationProvider. Keep the interface unchanged so the
//   orchestrator requires zero modification.
//
// SECURITY NOTE:
//   No real Aadhaar numbers, bank account numbers, or personal
//   identifiers appear anywhere in this file or its responses.
//   Synthetic demo data only.
// ============================================================

import 'dart:async';
import '../../domain/integration_provider.dart';

// ─────────────────────────────────────────────────────────────
// Shared helper — simulate network latency without real I/O
// ─────────────────────────────────────────────────────────────
Future<void> _simulateLatency([int ms = 600]) =>
    Future.delayed(Duration(milliseconds: ms));

// ─────────────────────────────────────────────────────────────
// 1. DigiLocker Mock Provider
//    PROPOSED INTEGRATION: DigiLocker Pull API (MeitY)
//    FUTURE AUTH: OAuth 2.0 + client_id/client_secret from MeitY
// ─────────────────────────────────────────────────────────────
class DigiLockerMockProvider implements IntegrationProvider {
  @override
  GovernmentSystem get system => GovernmentSystem.digiLocker;

  @override
  bool get isSimulated => true;

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  Future<IntegrationResponse> verify(IntegrationRequest request) async {
    await _simulateLatency(700);
    return IntegrationResponse(
      sourceSystem: system,
      requestId: request.requestId,
      status: IntegrationStatus.verified,
      verifiedFields: ['name', 'dob', 'aadhaarLast4', 'gender'],
      mismatchedFields: const {},
      timestamp: DateTime.now(),
      isSimulated: true,
      requiresManualReview: false,
      error: null,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 2. UDISE+ Mock Provider
//    PROPOSED INTEGRATION: UDISE+ REST API (MoE/NIC)
//    FUTURE AUTH: API key issued by NIEPA / state NIC node
// ─────────────────────────────────────────────────────────────
class UDISEMockProvider implements IntegrationProvider {
  @override
  GovernmentSystem get system => GovernmentSystem.udisePlus;

  @override
  bool get isSimulated => true;

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  Future<IntegrationResponse> verify(IntegrationRequest request) async {
    await _simulateLatency(500);
    return IntegrationResponse(
      sourceSystem: system,
      requestId: request.requestId,
      status: IntegrationStatus.verified,
      verifiedFields: ['udiseCode', 'schoolName', 'enrolmentStatus', 'grade'],
      mismatchedFields: const {},
      timestamp: DateTime.now(),
      isSimulated: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 3. APAAR / ABC Mock Provider
//    PROPOSED INTEGRATION: Academic Bank of Credits API (MoE)
//    FUTURE AUTH: OAuth 2.0 with APAAR token
// ─────────────────────────────────────────────────────────────
class APAARMockProvider implements IntegrationProvider {
  @override
  GovernmentSystem get system => GovernmentSystem.apaar;

  @override
  bool get isSimulated => true;

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  Future<IntegrationResponse> verify(IntegrationRequest request) async {
    await _simulateLatency(550);
    final apaarId = request.fieldsToVerify['apaarId'] ?? '';
    final sourceApaarId = apaarId; // mock: matches exactly
    final matches = apaarId == sourceApaarId;
    return IntegrationResponse(
      sourceSystem: system,
      requestId: request.requestId,
      status: matches ? IntegrationStatus.verified : IntegrationStatus.mismatch,
      verifiedFields: matches ? ['apaarId', 'name', 'institution'] : [],
      mismatchedFields: matches ? {} : {'apaarId': sourceApaarId},
      timestamp: DateTime.now(),
      isSimulated: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 4. AISHE Mock Provider
//    PROPOSED INTEGRATION: AISHE Web API (MoE / NIEPA)
//    FUTURE AUTH: API key from AISHE nodal officer
// ─────────────────────────────────────────────────────────────
class AISHEMockProvider implements IntegrationProvider {
  @override
  GovernmentSystem get system => GovernmentSystem.aishe;

  @override
  bool get isSimulated => true;

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  Future<IntegrationResponse> verify(IntegrationRequest request) async {
    await _simulateLatency(650);
    // Simulate a mild mismatch: institution name abbreviation differs
    final declared = request.fieldsToVerify['institutionName'] ?? '';
    const sourceValue = 'Govt. College (AISHE code pending verification)';
    final matches = declared.isNotEmpty &&
        declared.toLowerCase().contains('govt');
    return IntegrationResponse(
      sourceSystem: system,
      requestId: request.requestId,
      status: matches ? IntegrationStatus.verified : IntegrationStatus.mismatch,
      verifiedFields: ['aisheCode', 'courseLevel', 'affiliatingUniversity'],
      mismatchedFields: matches ? {} : {'institutionName': sourceValue},
      timestamp: DateTime.now(),
      isSimulated: true,
      requiresManualReview: !matches,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 5. NSP Mock Provider
//    PROPOSED INTEGRATION: NSP API (MoE / NIC)
//    FUTURE AUTH: NSP institution/state nodal credentials
// ─────────────────────────────────────────────────────────────
class NSPMockProvider implements IntegrationProvider {
  @override
  GovernmentSystem get system => GovernmentSystem.nsp;

  @override
  bool get isSimulated => true;

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  Future<IntegrationResponse> verify(IntegrationRequest request) async {
    await _simulateLatency(800);
    return IntegrationResponse(
      sourceSystem: system,
      requestId: request.requestId,
      status: IntegrationStatus.pending,
      verifiedFields: [],
      mismatchedFields: const {},
      timestamp: DateTime.now(),
      isSimulated: true,
      error: 'NSP batch sync in progress. Awaiting daily reconciliation.',
      requiresManualReview: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 6. PFMS Mock Provider
//    PROPOSED INTEGRATION: PFMS DBT API (Ministry of Finance)
//    FUTURE AUTH: PFMS agency code + MoF-issued API key
// ─────────────────────────────────────────────────────────────
class PFMSMockProvider implements IntegrationProvider {
  @override
  GovernmentSystem get system => GovernmentSystem.pfms;

  @override
  bool get isSimulated => true;

  @override
  Duration get timeout => const Duration(seconds: 12);

  @override
  Future<IntegrationResponse> verify(IntegrationRequest request) async {
    await _simulateLatency(900);
    return IntegrationResponse(
      sourceSystem: system,
      requestId: request.requestId,
      status: IntegrationStatus.pending,
      verifiedFields: [],
      mismatchedFields: const {},
      timestamp: DateTime.now(),
      isSimulated: true,
      error: 'Awaiting NPCI Aadhaar mapper batch settlement confirmation.',
      requiresManualReview: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 7. State e-District Mock Provider
//    PROPOSED INTEGRATION: State e-District APIs vary by state.
//    FUTURE AUTH: State NIC API key per state deployment.
// ─────────────────────────────────────────────────────────────
class StateEDistrictMockProvider implements IntegrationProvider {
  @override
  GovernmentSystem get system => GovernmentSystem.stateEDistrict;

  @override
  bool get isSimulated => true;

  @override
  Duration get timeout => const Duration(seconds: 15);

  @override
  Future<IntegrationResponse> verify(IntegrationRequest request) async {
    await _simulateLatency(1100);
    // Simulate name abbreviation mismatch (the canonical demo scenario)
    final declaredName = request.fieldsToVerify['name'] ?? '';
    // Mock: source returns abbreviated surname
    final parts = declaredName.trim().split(' ');
    final sourceName = parts.length > 1
        ? '${parts.first} ${parts.last[0]}.'
        : declaredName;
    final matches = declaredName == sourceName;
    return IntegrationResponse(
      sourceSystem: system,
      requestId: request.requestId,
      status: matches ? IntegrationStatus.verified : IntegrationStatus.mismatch,
      verifiedFields: ['stCertificateId', 'tribe', 'state', 'issueDate'],
      mismatchedFields: matches ? {} : {'name': sourceName},
      timestamp: DateTime.now(),
      isSimulated: true,
      requiresManualReview: !matches,
      error: matches
          ? null
          : 'Name abbreviation mismatch between application and revenue record. '
              'Routed to manual verification officer.',
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 8. UGC Mock Provider
//    PROPOSED INTEGRATION: UGC NET result / institution API
//    FUTURE AUTH: UGC portal credentials (not yet available)
// ─────────────────────────────────────────────────────────────
class UGCMockProvider implements IntegrationProvider {
  @override
  GovernmentSystem get system => GovernmentSystem.ugc;

  @override
  bool get isSimulated => true;

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  Future<IntegrationResponse> verify(IntegrationRequest request) async {
    await _simulateLatency(600);
    return IntegrationResponse(
      sourceSystem: system,
      requestId: request.requestId,
      status: IntegrationStatus.verified,
      verifiedFields: ['ugcApprovedInstitution', 'courseApproval'],
      mismatchedFields: const {},
      timestamp: DateTime.now(),
      isSimulated: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 9. NTA Mock Provider
//    PROPOSED INTEGRATION: NTA result verification API
//    FUTURE AUTH: NTA portal credentials (not yet available)
// ─────────────────────────────────────────────────────────────
class NTAMockProvider implements IntegrationProvider {
  @override
  GovernmentSystem get system => GovernmentSystem.nta;

  @override
  bool get isSimulated => true;

  @override
  Duration get timeout => const Duration(seconds: 10);

  @override
  Future<IntegrationResponse> verify(IntegrationRequest request) async {
    await _simulateLatency(650);
    return IntegrationResponse(
      sourceSystem: system,
      requestId: request.requestId,
      status: IntegrationStatus.verified,
      verifiedFields: ['applicationNumber', 'examName', 'score', 'rank'],
      mismatchedFields: const {},
      timestamp: DateTime.now(),
      isSimulated: true,
    );
  }
}
