// ============================================================
// USMA — JAGO Scholarship Assistance System
// jago_intent_and_context.dart
//
// Structured Intent Classification & Comprehensive Student Context
// ============================================================

/// Canonical JAGO Intents
enum JagoIntent {
  eligibility,
  applicationStatus,
  documents,
  deficiency,
  verification,
  payment,
  sanction,
  deadline,
  schemeInformation,
  grievance,
  howToApply,
  generalHelp,
}

/// Structured Action representation for quick user navigation
class JagoAction {
  final String label;
  final String route;
  final Map<String, dynamic>? arguments;
  final bool isExternal;

  const JagoAction({
    required this.label,
    required this.route,
    this.arguments,
    this.isExternal = false,
  });
}

/// Structured Source provenance
class JagoSource {
  final String name;
  final String url;
  final String portal;

  const JagoSource({
    required this.name,
    required this.url,
    required this.portal,
  });

  static const JagoSource motaPortal = JagoSource(
    name: 'Ministry of Tribal Affairs (MoTA)',
    url: 'https://tribal.nic.in/ScholarshiP.aspx',
    portal: 'tribal.nic.in',
  );

  static const JagoSource dbtTribal = JagoSource(
    name: 'DBT Tribal Portal (Pre/Post-Matric)',
    url: 'https://dbttribal.gov.in/',
    portal: 'dbttribal.gov.in',
  );

  static const JagoSource nspPortal = JagoSource(
    name: 'National Scholarship Portal (NSP Top Class)',
    url: 'https://scholarships.gov.in',
    portal: 'scholarships.gov.in',
  );

  static const JagoSource fellowshipPortal = JagoSource(
    name: 'MoTA Fellowship Portal (NFST)',
    url: 'https://fellowship.tribal.gov.in/',
    portal: 'fellowship.tribal.gov.in',
  );

  static const JagoSource overseasPortal = JagoSource(
    name: 'MoTA Overseas Scholarship Portal (NOS)',
    url: 'https://overseas.tribal.gov.in/',
    portal: 'overseas.tribal.gov.in',
  );

  static const JagoSource grievancePortal = JagoSource(
    name: 'MoTA Central Grievance Portal',
    url: 'https://tribal.nic.in/Grievance/',
    portal: 'tribal.nic.in/Grievance',
  );
}

/// Comprehensive Student Context passed into JAGO
class ComprehensiveStudentContext {
  final String studentName;
  final String? studentId;
  final String? socialCategory; // 'ST', 'PVTG', etc.
  final bool isPvtg;
  final double? annualFamilyIncome;
  final String? educationLevel; // 'Class 10', 'Higher Secondary', 'College / Undergraduate', 'Ph.D'
  final String? currentCourse;
  final String? state;
  final String? institutionName;
  final String? activeSchemeId;
  final String? activeSchemeTitle;
  final String? applicationStatus; // 'submitted', 'under_verification', 'deficiency_raised', 'sanctioned', 'disbursed', 'rejected'
  final String? verificationStatus; // 'INSTITUTE_PENDING', 'STATE_PENDING', 'DIGILOCKER_MATCHED', 'MISMATCH_DETECTED'
  final List<String> missingDocuments;
  final List<String> deficiencies;
  final String? paymentStatus; // 'SUCCESS', 'PENDING_BANK', 'PROCESSING', 'FAILED', 'NONE'
  final double? lastDisbursedAmount;
  final String? lastPaymentUtr;
  final DateTime? lastPaymentDate;
  final String? sanctionOrderNumber;
  final double? sanctionedAmount;
  final DateTime? sanctionDate;
  final String languageCode; // 'en', 'hi', 'or' (Odia)
  final bool isSimulatedData;

  const ComprehensiveStudentContext({
    required this.studentName,
    this.studentId,
    this.socialCategory = 'ST',
    this.isPvtg = false,
    this.annualFamilyIncome,
    this.educationLevel,
    this.currentCourse,
    this.state,
    this.institutionName,
    this.activeSchemeId,
    this.activeSchemeTitle,
    this.applicationStatus,
    this.verificationStatus,
    this.missingDocuments = const [],
    this.deficiencies = const [],
    this.paymentStatus,
    this.lastDisbursedAmount,
    this.lastPaymentUtr,
    this.lastPaymentDate,
    this.sanctionOrderNumber,
    this.sanctionedAmount,
    this.sanctionDate,
    this.languageCode = 'en',
    this.isSimulatedData = true,
  });

  bool get hasActiveApplication =>
      activeSchemeTitle != null && applicationStatus != null;
  bool get hasIncomeRecorded => annualFamilyIncome != null;
  bool get hasDeficiencies => deficiencies.isNotEmpty;
  bool get hasMissingDocuments => missingDocuments.isNotEmpty;
}

/// Standardized JAGO Structured Response
class JagoStructuredResponse {
  final JagoIntent intent;
  final String answer;
  final String reason;
  final String currentStatus;
  final String requiredAction;
  final JagoSource source;
  final List<JagoAction> actions;
  final List<String> suggestions;
  final Map<String, dynamic>? grievanceDraft; // Set if intent is grievance
  final bool isGrievanceDraft;

  const JagoStructuredResponse({
    required this.intent,
    required this.answer,
    required this.reason,
    required this.currentStatus,
    required this.requiredAction,
    required this.source,
    this.actions = const [],
    this.suggestions = const [],
    this.grievanceDraft,
    this.isGrievanceDraft = false,
  });

  /// Formatted text representation following Rule #11:
  /// Answer -> Reason -> Current Status -> Required Action -> Source
  String toFormattedText() {
    final buffer = StringBuffer();
    buffer.writeln(answer);
    buffer.writeln();
    if (reason.isNotEmpty) {
      buffer.writeln('📋 Reason: $reason');
    }
    if (currentStatus.isNotEmpty) {
      buffer.writeln('⚡ Current Status: $currentStatus');
    }
    if (requiredAction.isNotEmpty) {
      buffer.writeln('👉 Required Action: $requiredAction');
    }
    buffer.writeln('🏛️ Source: ${source.name} (${source.portal})');
    return buffer.toString().trim();
  }
}
