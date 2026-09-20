import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/coverage_gap_analytics_model.dart';

abstract class ICoverageGapAnalyticsRepository {
  Future<AdminAnalyticsSummary> getAnalyticsSummary({
    String? state,
    String? district,
    String? academicYear,
    String? scheme,
    String? institution,
  });
  Future<List<STStudentEnrollmentRecord>> getStudentRecords();
}

class MockCoverageGapAnalyticsRepository implements ICoverageGapAnalyticsRepository {
  final List<STStudentEnrollmentRecord> _records = [
    const STStudentEnrollmentRecord(
      studentId: 'ST-2026-OD-001',
      studentName: 'Sunita Marandi',
      state: 'Odisha',
      district: 'Mayurbhanj',
      institutionName: 'NIT Rourkela',
      educationLevel: 'Post-Matric',
      academicYear: '2026-2027',
      familyAnnualIncome: 180000,
      statusCategory: 'ACTIVE_BENEFICIARY',
      activeSchemeName: 'Post-Matric Scholarship for ST Students',
    ),
    const STStudentEnrollmentRecord(
      studentId: 'ST-2026-OD-002',
      studentName: 'Biren Hansdah',
      state: 'Odisha',
      district: 'Mayurbhanj',
      institutionName: 'Baripada Govt High School',
      educationLevel: 'Pre-Matric',
      academicYear: '2026-2027',
      familyAnnualIncome: 95000,
      statusCategory: 'POTENTIALLY_ELIGIBLE_NOT_APPLIED',
      activeSchemeName: null,
      mismatchDescription: 'Enrolled in Class 9, eligible for Pre-Matric but no application submitted in current cycle.',
    ),
    const STStudentEnrollmentRecord(
      studentId: 'ST-2026-JH-003',
      studentName: 'Amit Munda',
      state: 'Jharkhand',
      district: 'Ranchi',
      institutionName: 'Ranchi University',
      educationLevel: 'Research',
      academicYear: '2026-2027',
      familyAnnualIncome: 240000,
      statusCategory: 'ACTIVE_BENEFICIARY',
      activeSchemeName: 'National Fellowship for ST Students (NFST)',
    ),
    const STStudentEnrollmentRecord(
      studentId: 'ST-2026-MP-004',
      studentName: 'Pooja Gond',
      state: 'Madhya Pradesh',
      district: 'Mandla',
      institutionName: 'IIT Indore',
      educationLevel: 'Higher Education',
      academicYear: '2026-2027',
      familyAnnualIncome: 310000,
      statusCategory: 'ACTIVE_BENEFICIARY',
      activeSchemeName: 'Top Class Scholarship for ST Students',
    ),
    const STStudentEnrollmentRecord(
      studentId: 'ST-2026-AS-005',
      studentName: 'Rakesh Bodo',
      state: 'Assam',
      district: 'Kokrajhar',
      institutionName: 'Kokrajhar College',
      educationLevel: 'Post-Matric',
      academicYear: '2026-2027',
      familyAnnualIncome: 140000,
      statusCategory: 'DATA_MISMATCH',
      mismatchDescription: 'APAAR ID name spelling mismatch between UDISE+ and State Caste Registry.',
    ),
  ];

  @override
  Future<AdminAnalyticsSummary> getAnalyticsSummary({
    String? state,
    String? district,
    String? academicYear,
    String? scheme,
    String? institution,
  }) async {
    return const AdminAnalyticsSummary(
      totalEnrolledST: 482900,
      scholarshipApplicants: 364200,
      activeBeneficiaries: 312000,
      potentiallyEligibleNonBeneficiaries: 68700,
      verificationPending: 38500,
      paymentPending: 13700,
      applicationDeficiencies: 14200,
      totalDisbursedAmount: 1845000000.0, // ₹184.5 Cr
    );
  }

  @override
  Future<List<STStudentEnrollmentRecord>> getStudentRecords() async {
    return List.unmodifiable(_records);
  }
}

final coverageGapAnalyticsRepositoryProvider =
    Provider<ICoverageGapAnalyticsRepository>((ref) {
  return MockCoverageGapAnalyticsRepository();
});

final adminAnalyticsSummaryProvider =
    FutureProvider<AdminAnalyticsSummary>((ref) async {
  return ref.watch(coverageGapAnalyticsRepositoryProvider).getAnalyticsSummary();
});

final coverageGapRecordsProvider =
    FutureProvider<List<STStudentEnrollmentRecord>>((ref) async {
  return ref.watch(coverageGapAnalyticsRepositoryProvider).getStudentRecords();
});
