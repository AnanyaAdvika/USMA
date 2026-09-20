enum EligibilityStatus {
  eligible,
  conditionallyEligible,
  ineligible,
  incompleteProfile,
}

class SchemeEligibilityEvaluation {
  final String schemeId;
  final String schemeName;
  final EligibilityStatus status;
  final bool isEligible;
  final List<String> passedCriteria;
  final List<String> failedCriteria;
  final List<String> missingDocuments;
  final List<String> pendingActions;
  final String recommendation;

  const SchemeEligibilityEvaluation({
    required this.schemeId,
    required this.schemeName,
    required this.status,
    required this.isEligible,
    required this.passedCriteria,
    required this.failedCriteria,
    required this.missingDocuments,
    required this.pendingActions,
    required this.recommendation,
  });

  String get statusBadgeText {
    switch (status) {
      case EligibilityStatus.eligible:
        return 'Eligible';
      case EligibilityStatus.conditionallyEligible:
        return 'Conditionally Eligible';
      case EligibilityStatus.ineligible:
        return 'Not Eligible';
      case EligibilityStatus.incompleteProfile:
        return 'Incomplete Profile';
    }
  }
}

class StudentEligibilityProfile {
  final String? userId;
  final bool? isScheduledTribe;
  final String? socialCategory; // 'ST', 'PVTG', 'SC', 'OBC', 'GEN'
  final bool isPvtg;
  final double? familyAnnualIncome;
  final String? educationLevel; // 'Pre-Matric', 'Post-Matric', 'Higher Education', 'Research', 'Overseas'
  final String? currentClassOrDegree; // 'Class 9', 'Class 10', 'B.Tech', 'MBBS', 'M.Phil', 'Ph.D', etc.
  final String? institutionType; // 'PREMIER_NOTIFIED', 'REGULAR_RECOGNIZED', 'FOREIGN_QS500', 'OTHER'
  final double? qualifyingMarksPercentage;
  final int? studentAge;
  final bool hasAadhaar;
  final bool hasAadhaarSeededBank;
  final List<String> availableDocumentTypes; // 'CASTE_CERTIFICATE', 'INCOME_CERTIFICATE', 'AADHAAR', 'PASSPORT', 'OFFER_LETTER_PREMIER', 'OFFER_LETTER_FOREIGN', 'PHD_REGISTRATION'

  const StudentEligibilityProfile({
    this.userId,
    this.isScheduledTribe = true,
    this.socialCategory = 'ST',
    this.isPvtg = false,
    this.familyAnnualIncome,
    this.educationLevel,
    this.currentClassOrDegree,
    this.institutionType,
    this.qualifyingMarksPercentage,
    this.studentAge,
    this.hasAadhaar = true,
    this.hasAadhaarSeededBank = true,
    this.availableDocumentTypes = const [],
  });

  bool get hasCompleteBasicProfile =>
      socialCategory != null &&
      familyAnnualIncome != null &&
      educationLevel != null;
}
