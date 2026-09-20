class STStudentEnrollmentRecord {
  final String studentId;
  final String studentName;
  final String state;
  final String district;
  final String institutionName;
  final String educationLevel;
  final String academicYear;
  final double familyAnnualIncome;
  final String statusCategory; // 'ACTIVE_BENEFICIARY', 'ENROLLED_NO_SCHOLARSHIP', 'POTENTIALLY_ELIGIBLE_NOT_APPLIED', 'DATA_MISMATCH'
  final String? activeSchemeName;
  final String? mismatchDescription;

  const STStudentEnrollmentRecord({
    required this.studentId,
    required this.studentName,
    required this.state,
    required this.district,
    required this.institutionName,
    required this.educationLevel,
    required this.academicYear,
    required this.familyAnnualIncome,
    required this.statusCategory,
    this.activeSchemeName,
    this.mismatchDescription,
  });
}

class AdminAnalyticsSummary {
  final int totalEnrolledST;
  final int scholarshipApplicants;
  final int activeBeneficiaries;
  final int potentiallyEligibleNonBeneficiaries;
  final int verificationPending;
  final int paymentPending;
  final int applicationDeficiencies;
  final double totalDisbursedAmount;

  const AdminAnalyticsSummary({
    required this.totalEnrolledST,
    required this.scholarshipApplicants,
    required this.activeBeneficiaries,
    required this.potentiallyEligibleNonBeneficiaries,
    required this.verificationPending,
    required this.paymentPending,
    required this.applicationDeficiencies,
    required this.totalDisbursedAmount,
  });
}
