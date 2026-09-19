class SchemeModel {
  final String id;
  final String title;
  final String ministry;
  final String description;
  final double maxAmount;
  final String frequency; // e.g. "Per Annum"
  final double maxFamilyIncome;
  final String educationLevel; // "Pre-Matric", "Post-Matric", "Higher Education", "National Fellowship", "Overseas"
  final DateTime deadline;
  final bool isFeatured;
  final List<String> requiredDocuments;

  const SchemeModel({
    required this.id,
    required this.title,
    this.ministry = 'Ministry of Tribal Affairs (MoTA)',
    required this.description,
    required this.maxAmount,
    this.frequency = 'Per Annum',
    required this.maxFamilyIncome,
    required this.educationLevel,
    required this.deadline,
    this.isFeatured = false,
    required this.requiredDocuments,
  });

  factory SchemeModel.fromMap(Map<String, dynamic> map, String docId) {
    return SchemeModel(
      id: docId,
      title: map['title'] ?? '',
      ministry: map['ministry'] ?? 'Ministry of Tribal Affairs (MoTA)',
      description: map['description'] ?? '',
      maxAmount: (map['maxAmount'] as num?)?.toDouble() ?? 0.0,
      frequency: map['frequency'] ?? 'Per Annum',
      maxFamilyIncome: (map['maxFamilyIncome'] as num?)?.toDouble() ?? 250000.0,
      educationLevel: map['educationLevel'] ?? 'Post-Matric',
      deadline: map['deadline'] != null 
          ? DateTime.tryParse(map['deadline'].toString()) ?? DateTime.now().add(const Duration(days: 60))
          : DateTime.now().add(const Duration(days: 60)),
      isFeatured: map['isFeatured'] ?? false,
      requiredDocuments: List<String>.from(map['requiredDocuments'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'ministry': ministry,
      'description': description,
      'maxAmount': maxAmount,
      'frequency': frequency,
      'maxFamilyIncome': maxFamilyIncome,
      'educationLevel': educationLevel,
      'deadline': deadline.toIso8601String(),
      'isFeatured': isFeatured,
      'requiredDocuments': requiredDocuments,
    };
  }
}
