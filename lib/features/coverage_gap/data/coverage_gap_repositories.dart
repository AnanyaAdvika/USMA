import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failures.dart';
import '../domain/coverage_gap_repository.dart';
import '../domain/models/enrolled_student.dart';

class MockCoverageGapRepository implements CoverageGapRepository {
  @override
  Future<List<EnrolledStudent>> listEnrolledStudents() async {
    // SIMULATED enrolment snapshot — not a UDISE+/APAAR/OTR feed.
    return const [
      EnrolledStudent(
        id: 'enr_01',
        displayName: 'Sunita Marandi',
        enrolmentSource: 'APAAR',
        state: 'Odisha',
        district: 'Mayurbhanj',
        receivingScholarship: true,
        simulated: true,
      ),
      EnrolledStudent(
        id: 'enr_02',
        displayName: 'Ramesh Tudu',
        enrolmentSource: 'UDISE+',
        state: 'Odisha',
        district: 'Mayurbhanj',
        receivingScholarship: false,
        simulated: true,
      ),
      EnrolledStudent(
        id: 'enr_03',
        displayName: 'Anita Soren',
        enrolmentSource: 'OTR',
        state: 'Jharkhand',
        district: 'Dumka',
        receivingScholarship: false,
        simulated: true,
      ),
    ];
  }
}

class LiveCoverageGapRepository implements CoverageGapRepository {
  @override
  Future<List<EnrolledStudent>> listEnrolledStudents() async {
    throw const IntegrationFailure(
      'Coverage-gap detection needs UDISE+/APAAR/OTR feeds on the USMA backend. This app does not call those systems.',
    );
  }
}

final coverageGapRepositoryProvider = Provider<CoverageGapRepository>((ref) {
  if (AppConfig.isDemo) return MockCoverageGapRepository();
  return LiveCoverageGapRepository();
});

final enrolledStudentsProvider = FutureProvider<List<EnrolledStudent>>((ref) {
  return ref.watch(coverageGapRepositoryProvider).listEnrolledStudents();
});
