import 'mota_scheme_model.dart';

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
  final MotaSchemeModel? motaScheme;

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
    this.motaScheme,
  });

  bool get isFeatured =>
      id == 'post_matric' ||
      id == 'post_matric_st' ||
      id == 'top_class' ||
      id == 'top_class_st' ||
      id == 'nfst';

  factory SchemeModel.fromMotaScheme(MotaSchemeModel mota) {
    return SchemeModel(
      id: mota.schemeId,
      code: mota.shortName,
      title: mota.schemeName,
      shortTitle: mota.shortName,
      ministry: 'Ministry of Tribal Affairs (MoTA)',
      description: mota.description,
      maxAmount: mota.scholarshipBenefits.annualMaxEstimatedAmount,
      frequency: mota.scholarshipBenefits.frequency,
      maxFamilyIncome: mota.incomeLimit.maxFamilyIncome,
      educationLevel: mota.targetEducationLevel,
      educationLevels: mota.targetEducationLevels,
      classes: mota.targetEducationLevels,
      sourceSystems: [mota.applicationPortal.portalName],
      deadline: DateTime(2026, 12, 31),
      requiredDocuments: mota.requiredDocuments,
      motaScheme: mota,
    );
  }

  factory SchemeModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final levels = List<String>.from(
      map['targetEducationLevels'] ?? map['educationLevels'] ?? const <String>[],
    );
    final educationLevel = levels.isNotEmpty
        ? levels.first
        : (map['targetEducationLevel'] as String? ??
            map['educationLevel'] as String? ??
            'Post-Matric');

    final double income = map['incomeLimit'] is Map
        ? ((map['incomeLimit']['maxFamilyIncome'] as num?)?.toDouble() ?? 250000.0)
        : ((map['maxFamilyIncome'] as num?)?.toDouble() ?? 250000.0);

    final double amount = map['scholarshipBenefits'] is Map
        ? ((map['scholarshipBenefits']['annualMaxEstimatedAmount'] as num?)
                ?.toDouble() ??
            0.0)
        : ((map['maxAmount'] as num?)?.toDouble() ?? 0.0);

    MotaSchemeModel? mota;
    try {
      mota = MotaSchemeModel.fromMap(map);
    } catch (_) {
      // Graceful fallback
    }

    return SchemeModel(
      id: docId ??
          map['schemeId']?.toString() ??
          map['id']?.toString() ??
          '',
      code: map['shortName']?.toString() ?? map['code']?.toString() ?? '',
      title: map['schemeName']?.toString() ?? map['title']?.toString() ?? '',
      shortTitle: map['shortName']?.toString() ??
          map['shortTitle']?.toString() ??
          map['title']?.toString() ??
          '',
      ministry: map['ministry']?.toString() ??
          'Ministry of Tribal Affairs (MoTA)',
      description: map['description']?.toString() ?? '',
      maxAmount: amount,
      frequency: (map['scholarshipBenefits'] is Map
              ? map['scholarshipBenefits']['frequency']?.toString()
              : map['frequency']?.toString()) ??
          'Per Annum',
      maxFamilyIncome: income,
      educationLevel: educationLevel,
      educationLevels: levels.isEmpty ? [educationLevel] : levels,
      classes: List<String>.from(map['classes'] ?? levels),
      sourceSystems: List<String>.from(
        map['sourceSystems'] ??
            (map['applicationPortal'] is Map
                ? [map['applicationPortal']['portalName']]
                : const <String>[]),
      ),
      deadline: DateTime.tryParse(map['deadlineIso']?.toString() ?? '') ??
          DateTime.tryParse(map['deadline']?.toString() ?? '') ??
          DateTime(2026, 12, 31),
      requiredDocuments: List<String>.from(
        map['requiredDocuments'] ?? const <String>[],
      ),
      motaScheme: mota,
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
