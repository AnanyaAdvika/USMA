class SchemeModel {
  final String id;
  final String code;
  final String title;
  final String shortTitle;
  final String ministry;
  final String description;
  final double maxAmount;
  final String frequency;
  final double maxFamilyIncome;
  final String educationLevel;
  final List<String> educationLevels;
  final List<String> classes;
  final List<String> sourceSystems;
  final DateTime deadline;
  final List<String> requiredDocuments;

  const SchemeModel({
    required this.id,
    required this.code,
    required this.title,
    required this.shortTitle,
    this.ministry = 'Ministry of Tribal Affairs (MoTA)',
    required this.description,
    required this.maxAmount,
    this.frequency = 'Per Annum',
    required this.maxFamilyIncome,
    required this.educationLevel,
    required this.educationLevels,
    required this.classes,
    required this.sourceSystems,
    required this.deadline,
    required this.requiredDocuments,
  });

  bool get isFeatured =>
      id == 'post_matric' || id == 'top_class' || id == 'nfst';

  factory SchemeModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final levels = List<String>.from(
      map['educationLevels'] ?? const <String>[],
    );
    final educationLevel = levels.isNotEmpty
        ? levels.first
        : (map['educationLevel'] as String? ?? 'post_matric');
    return SchemeModel(
      id: docId ?? map['id']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      shortTitle: map['shortTitle']?.toString() ?? map['title']?.toString() ?? '',
      ministry: map['ministry']?.toString() ??
          'Ministry of Tribal Affairs (MoTA)',
      description: map['description']?.toString() ?? '',
      maxAmount: (map['maxAmount'] as num?)?.toDouble() ?? 0,
      frequency: map['frequency']?.toString() ?? 'Per Annum',
      maxFamilyIncome: (map['maxFamilyIncome'] as num?)?.toDouble() ?? 0,
      educationLevel: educationLevel,
      educationLevels: levels.isEmpty ? [educationLevel] : levels,
      classes: List<String>.from(map['classes'] ?? const <String>[]),
      sourceSystems: List<String>.from(
        map['sourceSystems'] ?? const <String>[],
      ),
      deadline: DateTime.tryParse(map['deadlineIso']?.toString() ?? '') ??
          DateTime.tryParse(map['deadline']?.toString() ?? '') ??
          DateTime(2026, 12, 31),
      requiredDocuments: List<String>.from(
        map['requiredDocuments'] ?? const <String>[],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'shortTitle': shortTitle,
      'ministry': ministry,
      'description': description,
      'maxAmount': maxAmount,
      'frequency': frequency,
      'maxFamilyIncome': maxFamilyIncome,
      'educationLevel': educationLevel,
      'educationLevels': educationLevels,
      'classes': classes,
      'sourceSystems': sourceSystems,
      'deadlineIso': deadline.toIso8601String(),
      'requiredDocuments': requiredDocuments,
    };
  }
}
