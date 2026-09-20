enum VerificationSource {
  digiLocker,
  aishe,
  udisePlus,
  apaar,
  uidai,
  stateEDistrict,
  ugcNta,
}

class FieldCheck {
  final String field;
  final String declaredValue;
  final String sourceValue;
  final bool matches;

  const FieldCheck({
    required this.field,
    required this.declaredValue,
    required this.sourceValue,
    required this.matches,
  });
}

class SourceVerification {
  final VerificationSource source;
  final List<FieldCheck> checks;
  final bool simulated;

  const SourceVerification({
    required this.source,
    required this.checks,
    this.simulated = false,
  });

  bool get hasMismatch => checks.any((c) => !c.matches);
}

class UnifiedVerificationResult {
  final String applicationId;
  final List<SourceVerification> sources;
  final bool sentToManualReview;
  /// Always false: mismatches never block submission.
  final bool applicationBlocked;
  final bool simulated;

  const UnifiedVerificationResult({
    required this.applicationId,
    required this.sources,
    required this.sentToManualReview,
    this.applicationBlocked = false,
    this.simulated = false,
  });
}

class VerificationRequest {
  final String applicationId;
  final String declaredName;
  final String declaredInstitute;
  final String declaredAadhaarLast4;
  final String declaredApaarId;
  final String declaredCasteCertificateId;

  const VerificationRequest({
    required this.applicationId,
    required this.declaredName,
    required this.declaredInstitute,
    required this.declaredAadhaarLast4,
    required this.declaredApaarId,
    required this.declaredCasteCertificateId,
  });
}
