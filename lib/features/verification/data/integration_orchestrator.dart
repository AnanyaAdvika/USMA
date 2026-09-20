// ============================================================
// USMA — Integration Orchestrator
// integration_orchestrator.dart
//
// STATUS:
//   Domain logic   → REAL IMPLEMENTATION
//   Provider calls → MOCK (demo mode)
//
// PROPOSED INTEGRATION ARCHITECTURE (not an API contract):
//   Identity        → DigiLocker / UIDAI
//   Academic record → UDISE+ / APAAR / institution
//   College info    → AISHE
//   NET/JRF         → UGC / NTA
//   Certificate     → State e-District
//   Scholarship app → NSP
//   Payment/DBT     → PFMS
//
// FAILURE POLICY:
//   sourceUnavailable → retry up to [maxRetries] times
//   still unavailable → manualReview (never auto-reject)
//   mismatch          → manualReview (never auto-reject)
// ============================================================

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/integration_provider.dart';
import 'providers/mock_providers.dart';
import 'verification_audit_log.dart';

// ─────────────────────────────────────────────────────────────
// Orchestration result for a single verification run
// ─────────────────────────────────────────────────────────────
class OrchestrationResult {
  final String orchestrationId;
  final String studentToken;
  final List<IntegrationResponse> responses;
  final bool anyManualReview;
  final bool anyMismatch;
  final DateTime completedAt;
  final bool isSimulated;

  const OrchestrationResult({
    required this.orchestrationId,
    required this.studentToken,
    required this.responses,
    required this.anyManualReview,
    required this.anyMismatch,
    required this.completedAt,
    required this.isSimulated,
  });

  IntegrationStatus get overallStatus {
    if (anyManualReview) return IntegrationStatus.manualReview;
    if (anyMismatch) return IntegrationStatus.mismatch;
    final hasPending = responses.any((r) => r.status == IntegrationStatus.pending);
    final hasFailed = responses.any((r) => r.status == IntegrationStatus.failed);
    if (hasFailed) return IntegrationStatus.failed;
    if (hasPending) return IntegrationStatus.pending;
    return IntegrationStatus.verified;
  }
}

// ─────────────────────────────────────────────────────────────
// Orchestrator
// ─────────────────────────────────────────────────────────────
class IntegrationOrchestrator {
  IntegrationOrchestrator({
    required this.providers,
    required this.auditLog,
    this.maxRetries = 2,
  });

  final Map<GovernmentSystem, IntegrationProvider> providers;
  final VerificationAuditLog auditLog;
  final int maxRetries;

  // ── Core orchestration entry point ──────────────────────────
  Future<OrchestrationResult> runVerification({
    required String studentToken,
    required Map<String, String> fieldsToVerify,
    List<GovernmentSystem>? systems,
  }) async {
    final orchestrationId =
        'orch_${DateTime.now().millisecondsSinceEpoch}_$studentToken';

    final activeSystems = systems ?? providers.keys.toList();
    final results = <IntegrationResponse>[];

    for (final system in activeSystems) {
      final provider = providers[system];
      if (provider == null) continue;

      final reqId = '${orchestrationId}_${system.name}';
      final request = IntegrationRequest(
        requestId: reqId,
        studentId: studentToken,
        fieldsToVerify: fieldsToVerify,
        createdAt: DateTime.now(),
      );

      final response = await _callWithRetry(provider, request);
      results.add(response);

      // Write audit entry (field names only — no PII values)
      auditLog.record(VerificationAuditEntry.fromResponse(
        verificationId: reqId,
        studentToken: studentToken,
        response: response,
      ));
    }

    final anyManualReview = results.any((r) => r.requiresManualReview);
    final anyMismatch =
        results.any((r) => r.status == IntegrationStatus.mismatch);

    return OrchestrationResult(
      orchestrationId: orchestrationId,
      studentToken: studentToken,
      responses: results,
      anyManualReview: anyManualReview,
      anyMismatch: anyMismatch,
      completedAt: DateTime.now(),
      isSimulated: results.every((r) => r.isSimulated),
    );
  }

  // ── Retry wrapper ───────────────────────────────────────────
  Future<IntegrationResponse> _callWithRetry(
    IntegrationProvider provider,
    IntegrationRequest request,
  ) async {
    int attempts = 0;
    while (attempts <= maxRetries) {
      try {
        final response = await provider
            .verify(request)
            .timeout(provider.timeout);
        return response;
      } on TimeoutException {
        attempts++;
        if (attempts > maxRetries) {
          return IntegrationResponse(
            sourceSystem: provider.system,
            requestId: request.requestId,
            status: IntegrationStatus.sourceUnavailable,
            timestamp: DateTime.now(),
            isSimulated: provider.isSimulated,
            error:
                '${provider.system.displayName}: source unavailable after '
                '$maxRetries retries. Routed to manual review.',
            requiresManualReview: true,
          );
        }
        await Future.delayed(const Duration(milliseconds: 800));
      } catch (_) {
        return IntegrationResponse(
          sourceSystem: provider.system,
          requestId: request.requestId,
          status: IntegrationStatus.sourceUnavailable,
          timestamp: DateTime.now(),
          isSimulated: provider.isSimulated,
          error:
              '${provider.system.displayName}: unexpected error. '
              'Routed to manual review.',
          requiresManualReview: true,
        );
      }
    }
    // Should never reach here but satisfy Dart's flow analysis
    return IntegrationResponse(
      sourceSystem: provider.system,
      requestId: request.requestId,
      status: IntegrationStatus.sourceUnavailable,
      timestamp: DateTime.now(),
      isSimulated: provider.isSimulated,
      requiresManualReview: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Provider registry — swap mock → live here when ready
// ─────────────────────────────────────────────────────────────
final _mockProviderRegistry = <GovernmentSystem, IntegrationProvider>{
  GovernmentSystem.digiLocker: DigiLockerMockProvider(),
  GovernmentSystem.udisePlus: UDISEMockProvider(),
  GovernmentSystem.apaar: APAARMockProvider(),
  GovernmentSystem.aishe: AISHEMockProvider(),
  GovernmentSystem.nsp: NSPMockProvider(),
  GovernmentSystem.pfms: PFMSMockProvider(),
  GovernmentSystem.stateEDistrict: StateEDistrictMockProvider(),
  GovernmentSystem.ugc: UGCMockProvider(),
  GovernmentSystem.nta: NTAMockProvider(),
};

final integrationOrchestratorProvider = Provider<IntegrationOrchestrator>((ref) {
  final auditLog = ref.read(verificationAuditLogProvider.notifier);
  return IntegrationOrchestrator(
    providers: _mockProviderRegistry,
    auditLog: auditLog,
  );
});

// ─────────────────────────────────────────────────────────────
// Integration status snapshot (per-system connectivity state)
// ─────────────────────────────────────────────────────────────
class IntegrationSystemStatus {
  final GovernmentSystem system;
  final bool isConnected;
  final bool isSimulated;
  final String statusLabel;

  const IntegrationSystemStatus({
    required this.system,
    required this.isConnected,
    required this.isSimulated,
    required this.statusLabel,
  });
}

final integrationStatusListProvider =
    FutureProvider<List<IntegrationSystemStatus>>((ref) async {
  // Each provider performs a lightweight ping (simulated)
  await Future.delayed(const Duration(milliseconds: 400));
  return [
    const IntegrationSystemStatus(
      system: GovernmentSystem.digiLocker,
      isConnected: true,
      isSimulated: true,
      statusLabel: 'Demo Connected',
    ),
    const IntegrationSystemStatus(
      system: GovernmentSystem.udisePlus,
      isConnected: true,
      isSimulated: true,
      statusLabel: 'Demo Connected',
    ),
    const IntegrationSystemStatus(
      system: GovernmentSystem.apaar,
      isConnected: true,
      isSimulated: true,
      statusLabel: 'Demo Connected',
    ),
    const IntegrationSystemStatus(
      system: GovernmentSystem.aishe,
      isConnected: true,
      isSimulated: true,
      statusLabel: 'Demo Connected',
    ),
    const IntegrationSystemStatus(
      system: GovernmentSystem.pfms,
      isConnected: true,
      isSimulated: true,
      statusLabel: 'Demo Connected',
    ),
    const IntegrationSystemStatus(
      system: GovernmentSystem.stateEDistrict,
      isConnected: false,
      isSimulated: true,
      statusLabel: 'Manual Review',
    ),
    const IntegrationSystemStatus(
      system: GovernmentSystem.nsp,
      isConnected: true,
      isSimulated: true,
      statusLabel: 'Demo Connected',
    ),
    const IntegrationSystemStatus(
      system: GovernmentSystem.ugc,
      isConnected: true,
      isSimulated: true,
      statusLabel: 'Demo Connected',
    ),
    const IntegrationSystemStatus(
      system: GovernmentSystem.nta,
      isConnected: true,
      isSimulated: true,
      statusLabel: 'Demo Connected',
    ),
  ];
});
