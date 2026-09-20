enum UserRole {
  student,
  institutionVerifier,
  stateOfficer,
  ministryOfficer,
  admin,
}

enum DeficiencySeverity {
  critical, // Blocks application movement
  moderate, // Action required before next stage
  low,      // Advisory / informational
}

class DeficiencyItem {
  final String id;
  final String applicationId;
  final String schemeTitle;
  final String issue;
  final String source; // e.g. 'Institute Nodal Officer', 'State e-District', 'PFMS Gateway', 'MoTA Portal'
  final DateTime date;
  final DateTime deadline;
  final DeficiencySeverity severity;
  final String actionRequired;
  final String? requiredDocumentType;
  final bool isResolved;

  const DeficiencyItem({
    required this.id,
    required this.applicationId,
    required this.schemeTitle,
    required this.issue,
    required this.source,
    required this.date,
    required this.deadline,
    required this.severity,
    required this.actionRequired,
    this.requiredDocumentType,
    this.isResolved = false,
  });

  factory DeficiencyItem.fromMap(Map<String, dynamic> map, String docId) {
    DeficiencySeverity severity = DeficiencySeverity.moderate;
    final sevStr = map['severity']?.toString().toUpperCase();
    if (sevStr == 'CRITICAL') {
      severity = DeficiencySeverity.critical;
    } else if (sevStr == 'LOW') {
      severity = DeficiencySeverity.low;
    }

    return DeficiencyItem(
      id: docId,
      applicationId: map['applicationId']?.toString() ?? '',
      schemeTitle: map['schemeTitle']?.toString() ?? '',
      issue: map['issue']?.toString() ?? '',
      source: map['source']?.toString() ?? 'Verification Officer',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      deadline: DateTime.tryParse(map['deadline']?.toString() ?? '') ??
          DateTime.now().add(const Duration(days: 7)),
      severity: severity,
      actionRequired: map['actionRequired']?.toString() ?? '',
      requiredDocumentType: map['requiredDocumentType']?.toString(),
      isResolved: map['isResolved'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'applicationId': applicationId,
        'schemeTitle': schemeTitle,
        'issue': issue,
        'source': source,
        'date': date.toIso8601String(),
        'deadline': deadline.toIso8601String(),
        'severity': severity.name.toUpperCase(),
        'actionRequired': actionRequired,
        'requiredDocumentType': requiredDocumentType,
        'isResolved': isResolved,
      };
}

class FamilyMemberScholarship {
  final String memberId;
  final String memberName;
  final String relationship; // 'Son', 'Daughter', 'Sibling'
  final String schemeId;
  final String schemeName;
  final String currentStatus; // 'SUBMITTED', 'SANCTIONED', 'DISBURSED', 'VERIFICATION_PENDING'
  final double sanctionedAmount;
  final double disbursedAmount;
  final String academicYear;
  final bool hasDeficiency;

  const FamilyMemberScholarship({
    required this.memberId,
    required this.memberName,
    required this.relationship,
    required this.schemeId,
    required this.schemeName,
    required this.currentStatus,
    required this.sanctionedAmount,
    required this.disbursedAmount,
    required this.academicYear,
    this.hasDeficiency = false,
  });

  factory FamilyMemberScholarship.fromMap(Map<String, dynamic> map) {
    return FamilyMemberScholarship(
      memberId: map['memberId']?.toString() ?? '',
      memberName: map['memberName']?.toString() ?? '',
      relationship: map['relationship']?.toString() ?? 'Child',
      schemeId: map['schemeId']?.toString() ?? '',
      schemeName: map['schemeName']?.toString() ?? '',
      currentStatus: map['currentStatus']?.toString() ?? 'SUBMITTED',
      sanctionedAmount: (map['sanctionedAmount'] as num?)?.toDouble() ?? 0.0,
      disbursedAmount: (map['disbursedAmount'] as num?)?.toDouble() ?? 0.0,
      academicYear: map['academicYear']?.toString() ?? '2026-2027',
      hasDeficiency: map['hasDeficiency'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'memberId': memberId,
        'memberName': memberName,
        'relationship': relationship,
        'schemeId': schemeId,
        'schemeName': schemeName,
        'currentStatus': currentStatus,
        'sanctionedAmount': sanctionedAmount,
        'disbursedAmount': disbursedAmount,
        'academicYear': academicYear,
        'hasDeficiency': hasDeficiency,
      };
}
