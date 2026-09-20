enum VerificationStatus {
  verified,
  failed,
  mismatch,
  pending,
  manualReview,
  sourceUnavailable,
}

enum VerificationType {
  identity,
  stCertificate,
  incomeCertificate,
  academicRecord,
  institution,
  bankAccount,
  domicile,
  disabilityCertificate,
}

class MismatchField {
  final String fieldName;
  final String declaredValue;
  final String certificateValue;
  final String reason;

  const MismatchField({
    required this.fieldName,
    required this.declaredValue,
    required this.certificateValue,
    required this.reason,
  });

  Map<String, dynamic> toMap() => {
        'fieldName': fieldName,
        'declaredValue': declaredValue,
        'certificateValue': certificateValue,
        'reason': reason,
      };

  factory MismatchField.fromMap(Map<String, dynamic> map) => MismatchField(
        fieldName: map['fieldName']?.toString() ?? '',
        declaredValue: map['declaredValue']?.toString() ?? '',
        certificateValue: map['certificateValue']?.toString() ?? '',
        reason: map['reason']?.toString() ?? '',
      );
}

class VerificationResult {
  final VerificationType verificationType;
  final String sourceSystem; // e.g. 'UIDAI Aadhaar Vault (Mock)', 'State e-District (Mock)', 'AISHE / UDISE+ (Mock)', 'PFMS Gateway (Mock)'
  final VerificationStatus status;
  final double confidence; // 0.0 to 1.0
  final DateTime verifiedAt;
  final List<MismatchField> mismatchFields;
  final String? errorMessage;
  final bool requiresManualReview;
  final bool isSimulated;

  const VerificationResult({
    required this.verificationType,
    required this.sourceSystem,
    required this.status,
    this.confidence = 0.95,
    required this.verifiedAt,
    this.mismatchFields = const [],
    this.errorMessage,
    this.requiresManualReview = false,
    this.isSimulated = true,
  });

  String get displayName {
    switch (verificationType) {
      case VerificationType.identity:
        return 'Identity (Aadhaar)';
      case VerificationType.stCertificate:
        return 'ST Community Certificate';
      case VerificationType.incomeCertificate:
        return 'Annual Income Certificate';
      case VerificationType.academicRecord:
        return 'Academic Record / Marksheet';
      case VerificationType.institution:
        return 'Institution & Course (AISHE/UDISE+)';
      case VerificationType.bankAccount:
        return 'Bank Account & DBT Seeding';
      case VerificationType.domicile:
        return 'State Domicile Certificate';
      case VerificationType.disabilityCertificate:
        return 'Divyangjan / Disability Certificate';
    }
  }

  String get statusBadgeText {
    switch (status) {
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.failed:
        return 'Failed';
      case VerificationStatus.mismatch:
        return 'Mismatch Detected';
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.manualReview:
        return 'Manual Review';
      case VerificationStatus.sourceUnavailable:
        return 'Source Unavailable';
    }
  }
}

class ExtractedDocumentIntel {
  final String documentType;
  final Map<String, String> extractedFields;
  final List<MismatchField> mismatches;
  final double confidence;
  final bool isVerified;

  const ExtractedDocumentIntel({
    required this.documentType,
    required this.extractedFields,
    required this.mismatches,
    required this.confidence,
    required this.isVerified,
  });
}
