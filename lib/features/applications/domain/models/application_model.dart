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
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isCompleted: map['isCompleted'] == true,
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
  /// Canonical stages: submitted → under_verification → deficiency_raised
  /// → sanctioned → disbursed | rejected
  final String status;
  final DateTime submittedAt;
  final DateTime updatedAt;
  final List<TimelineEvent> timeline;
  final List<String> deficiencies;
  final bool manualReviewRequired;
  final bool simulated;

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
    this.deficiencies = const [],
    this.manualReviewRequired = false,
    this.simulated = false,
  });

  bool get isActive {
    const closed = {'disbursed', 'rejected'};
    return !closed.contains(status);
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawTimeline = map['timeline'] as List<dynamic>? ?? [];
    return ApplicationModel(
      id: docId,
      userId: map['userId']?.toString() ?? '',
      schemeId: map['schemeId']?.toString() ?? '',
      schemeTitle: map['schemeTitle']?.toString() ?? '',
      academicYear: map['academicYear']?.toString() ?? '2026-2027',
      instituteName: map['instituteName']?.toString() ?? '',
      courseName: map['courseName']?.toString() ?? '',
      sanctionedAmount: (map['sanctionedAmount'] as num?)?.toDouble() ?? 0,
      status: map['status']?.toString() ?? 'submitted',
      submittedAt: DateTime.tryParse(map['submittedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      timeline: rawTimeline
          .map((e) => TimelineEvent.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      deficiencies: List<String>.from(map['deficiencies'] ?? const []),
      manualReviewRequired: map['manualReviewRequired'] == true,
      simulated: map['simulated'] == true,
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
      'deficiencies': deficiencies,
      'manualReviewRequired': manualReviewRequired,
      'simulated': simulated,
    };
  }
}
