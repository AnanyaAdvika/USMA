class TimelineEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  const TimelineEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    this.isCompleted = false,
  });

  factory TimelineEvent.fromMap(Map<String, dynamic> map) {
    return TimelineEvent(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}

class ApplicationModel {
  final String id;
  final String userId;
  final String schemeId;
  final String schemeTitle;
  final String academicYear;
  final String instituteName;
  final String courseName;
  final double sanctionedAmount;
  final String status; // 'SUBMITTED', 'INSTITUTE_VERIFIED', 'STATE_VERIFIED', 'MINISTRY_APPROVED', 'DISBURSED', 'ACTION_REQUIRED', 'REJECTED'
  final DateTime submittedAt;
  final DateTime updatedAt;
  final List<TimelineEvent> timeline;
  final String? defectRemark;

  const ApplicationModel({
    required this.id,
    required this.userId,
    required this.schemeId,
    required this.schemeTitle,
    required this.academicYear,
    required this.instituteName,
    required this.courseName,
    required this.sanctionedAmount,
    required this.status,
    required this.submittedAt,
    required this.updatedAt,
    required this.timeline,
    this.defectRemark,
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawTimeline = map['timeline'] as List<dynamic>? ?? [];
    return ApplicationModel(
      id: docId,
      userId: map['userId'] ?? '',
      schemeId: map['schemeId'] ?? '',
      schemeTitle: map['schemeTitle'] ?? '',
      academicYear: map['academicYear'] ?? '2026-2027',
      instituteName: map['instituteName'] ?? '',
      courseName: map['courseName'] ?? '',
      sanctionedAmount: (map['sanctionedAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'SUBMITTED',
      submittedAt: map['submittedAt'] != null
          ? DateTime.tryParse(map['submittedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      timeline: rawTimeline
          .map((e) => TimelineEvent.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      defectRemark: map['defectRemark'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'schemeId': schemeId,
      'schemeTitle': schemeTitle,
      'academicYear': academicYear,
      'instituteName': instituteName,
      'courseName': courseName,
      'sanctionedAmount': sanctionedAmount,
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'timeline': timeline.map((e) => e.toMap()).toList(),
      'defectRemark': defectRemark,
    };
  }
}
