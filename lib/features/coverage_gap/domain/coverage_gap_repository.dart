import 'models/enrolled_student.dart';

abstract class CoverageGapRepository {
  Future<List<EnrolledStudent>> listEnrolledStudents();
}
