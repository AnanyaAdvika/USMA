class EnrolledStudent {
  final String id;
  final String displayName;
  final String enrolmentSource; // UDISE+, APAAR, OTR
  final String state;
  final String district;
  final bool receivingScholarship;
  final bool simulated;

  const EnrolledStudent({
    required this.id,
    required this.displayName,
    required this.enrolmentSource,
    required this.state,
    required this.district,
    required this.receivingScholarship,
    this.simulated = false,
  });
}

class CoverageGapDetector {
  const CoverageGapDetector();

  List<EnrolledStudent> gaps(List<EnrolledStudent> enrolled) {
    return enrolled.where((s) => !s.receivingScholarship).toList();
  }
}
