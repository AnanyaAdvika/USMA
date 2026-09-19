import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/scheme_model.dart';
import '../../auth/data/auth_repository.dart';

abstract class ISchemesRepository {
  Future<List<SchemeModel>> getSchemes();
  Future<SchemeModel?> getSchemeById(String id);
}

class SchemesRepository implements ISchemesRepository {
  final FirebaseFirestore? _firestore;

  SchemesRepository(this._firestore);

  static final List<SchemeModel> defaultSchemes = [
    SchemeModel(
      id: 'mota_pms_st_01',
      title: 'Post-Matric Scholarship for ST Students (PMS-ST)',
      ministry: 'Ministry of Tribal Affairs (MoTA)',
      description: 'Comprehensive financial assistance for Scheduled Tribe students studying at post-matriculation or post-secondary stages to enable them to complete their higher education.',
      maxAmount: 120000.0,
      frequency: 'Per Annum',
      maxFamilyIncome: 250000.0,
      educationLevel: 'Post-Matric',
      deadline: DateTime.now().add(const Duration(days: 45)),
      isFeatured: true,
      requiredDocuments: [
        'Caste Certificate (ST)',
        'Income Certificate',
        'Aadhaar Card',
        'Previous Academic Marksheet',
        'Fee Receipt / Bonafide Certificate'
      ],
    ),
    SchemeModel(
      id: 'mota_nfst_02',
      title: 'National Fellowship & Higher Education for ST Students (NFST)',
      ministry: 'Ministry of Tribal Affairs (MoTA)',
      description: 'Fellowship to ST candidates for pursuing regular and full-time M.Phil. and Ph.D. courses in recognized Indian universities and institutions.',
      maxAmount: 420000.0,
      frequency: 'Per Annum',
      maxFamilyIncome: 600000.0,
      educationLevel: 'Higher Education',
      deadline: DateTime.now().add(const Duration(days: 30)),
      isFeatured: true,
      requiredDocuments: [
        'Caste Certificate (ST)',
        'Post Graduation Marksheet / Degree',
        'Admission Letter from University',
        'Research Proposal Synopsis',
        'Bank Account Details (Aadhaar Seeded)'
      ],
    ),
    SchemeModel(
      id: 'mota_top_class_03',
      title: 'National Scholarship for Top Class Education for ST Students',
      ministry: 'Ministry of Tribal Affairs (MoTA)',
      description: 'Encouraging meritorious ST students to pursue quality education in premier institutes (IITs, IIMs, AIIMS, NITs, NLUs) across India.',
      maxAmount: 250000.0,
      frequency: 'Full Tuition + Maintenance',
      maxFamilyIncome: 600000.0,
      educationLevel: 'Higher Education',
      deadline: DateTime.now().add(const Duration(days: 60)),
      isFeatured: true,
      requiredDocuments: [
        'ST Certificate',
        'Allotment / Admission Letter',
        'Fee Structure from Institute',
        'Income Certificate'
      ],
    ),
    SchemeModel(
      id: 'mota_nos_04',
      title: 'National Overseas Scholarship for ST Candidates (NOS)',
      ministry: 'Ministry of Tribal Affairs (MoTA)',
      description: 'Financial support to meritorious ST students for pursuing Master level courses, Ph.D. and Post-Doctoral research abroad in recognized foreign universities.',
      maxAmount: 1800000.0,
      frequency: 'Full Course Coverage',
      maxFamilyIncome: 800000.0,
      educationLevel: 'Overseas',
      deadline: DateTime.now().add(const Duration(days: 90)),
      isFeatured: false,
      requiredDocuments: [
        'Caste Certificate (ST)',
        'Unconditional Offer Letter from Foreign University',
        'Valid Indian Passport',
        'IELTS / GRE Scorecard',
        'Family Income Affidavit'
      ],
    ),
    SchemeModel(
      id: 'mota_pre_matric_05',
      title: 'Pre-Matric Scholarship for ST Students (Classes IX & X)',
      ministry: 'Ministry of Tribal Affairs (MoTA)',
      description: 'Support to tribal students studying in class IX and X to minimize dropout rates and prepare them for higher secondary progression.',
      maxAmount: 25000.0,
      frequency: 'Per Annum',
      maxFamilyIncome: 200000.0,
      educationLevel: 'Pre-Matric',
      deadline: DateTime.now().add(const Duration(days: 40)),
      isFeatured: false,
      requiredDocuments: [
        'Caste Certificate',
        'Income Certificate',
        'School Bonafide Certificate',
        'Bank Passbook Copy'
      ],
    ),
  ];

  @override
  Future<List<SchemeModel>> getSchemes() async {
    try {
      if (_firestore != null) {
        final snapshot = await _firestore!.collection('schemes').get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => SchemeModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      }
    } catch (_) {}
    return defaultSchemes;
  }

  @override
  Future<SchemeModel?> getSchemeById(String id) async {
    try {
      if (_firestore != null) {
        final doc = await _firestore!.collection('schemes').doc(id).get();
        if (doc.exists && doc.data() != null) {
          return SchemeModel.fromMap(doc.data()!, doc.id);
        }
      }
    } catch (_) {}
    return defaultSchemes.firstWhere((s) => s.id == id, orElse: () => defaultSchemes.first);
  }
}

final schemesRepositoryProvider = Provider<ISchemesRepository>((ref) {
  return SchemesRepository(ref.watch(firestoreProvider));
});

final schemesListProvider = FutureProvider<List<SchemeModel>>((ref) async {
  return ref.watch(schemesRepositoryProvider).getSchemes();
});

final schemeDetailProvider = FutureProvider.family<SchemeModel?, String>((ref, id) async {
  return ref.watch(schemesRepositoryProvider).getSchemeById(id);
});
