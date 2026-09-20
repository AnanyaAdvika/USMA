import 'models/verification_models.dart';

/// Mismatches route to manual review and never block the application.
class VerificationPolicy {
  const VerificationPolicy();

  UnifiedVerificationResult decide({
    required String applicationId,
    required List<SourceVerification> sources,
    bool simulated = false,
  }) {
    final hasMismatch = sources.any((s) => s.hasMismatch);
    return UnifiedVerificationResult(
      applicationId: applicationId,
      sources: sources,
      sentToManualReview: hasMismatch,
      applicationBlocked: false,
      simulated: simulated,
    );
  }
}
