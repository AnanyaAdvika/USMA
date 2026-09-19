import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/document_model.dart';
import '../../auth/data/auth_repository.dart';

abstract class IDocumentsRepository {
  Future<List<DocumentModel>> getDocuments(String userId);
  Future<DocumentModel> uploadDocument(DocumentModel document);
  Future<void> syncDigiLocker();
}

class DocumentsRepository implements IDocumentsRepository {
  final FirebaseFirestore? _firestore;

  final List<DocumentModel> _localDocs = [
    DocumentModel(
      id: 'doc_aadhaar_01',
      userId: 'demo_user_001',
      title: 'Aadhaar Card',
      type: 'AADHAAR',
      source: 'DIGILOCKER',
      fileUrl: 'https://cdn.digitallocker.gov.in/sample_aadhaar.pdf',
      uri: 'in.gov.uidai:aadhaar:XXXXXXXX4829',
      verificationStatus: 'VERIFIED',
      issuedDate: DateTime(2021, 5, 12),
      uploadedAt: DateTime.now().subtract(const Duration(days: 90)),
      sizeBytes: 420000,
    ),
    DocumentModel(
      id: 'doc_caste_02',
      userId: 'demo_user_001',
      title: 'Scheduled Tribe (ST) Certificate',
      type: 'CASTE_CERTIFICATE',
      source: 'DIGILOCKER',
      fileUrl: 'https://cdn.edistrict.odisha.gov.in/caste_cert.pdf',
      uri: 'in.gov.edistrict.odisha:caste:ST-2022-8819',
      verificationStatus: 'VERIFIED',
      issuedDate: DateTime(2022, 7, 19),
      uploadedAt: DateTime.now().subtract(const Duration(days: 85)),
      sizeBytes: 512000,
    ),
    DocumentModel(
      id: 'doc_income_03',
      userId: 'demo_user_001',
      title: 'Annual Income Certificate (FY 2025-26)',
      type: 'INCOME_CERTIFICATE',
      source: 'DIGILOCKER',
      fileUrl: 'https://cdn.edistrict.odisha.gov.in/income_cert.pdf',
      uri: 'in.gov.edistrict.odisha:income:INC-2025-9921',
      verificationStatus: 'VERIFIED',
      issuedDate: DateTime(2025, 4, 10),
      uploadedAt: DateTime.now().subtract(const Duration(days: 30)),
      sizeBytes: 380000,
    ),
    DocumentModel(
      id: 'doc_marksheet_04',
      userId: 'demo_user_001',
      title: 'Higher Secondary (Class XII) Marksheet',
      type: 'MARKSHEET',
      source: 'DIGILOCKER',
      fileUrl: 'https://cdn.cbse.gov.in/marksheet_xii.pdf',
      uri: 'in.gov.cbse:marksheet:2024-771829',
      verificationStatus: 'VERIFIED',
      issuedDate: DateTime(2024, 6, 2),
      uploadedAt: DateTime.now().subtract(const Duration(days: 60)),
      sizeBytes: 620000,
    ),
    DocumentModel(
      id: 'doc_fee_receipt_05',
      userId: 'demo_user_001',
      title: 'NIT Rourkela Semester Fee Receipt',
      type: 'FEE_RECEIPT',
      source: 'MANUAL_UPLOAD',
      fileUrl: 'https://nitrkl.ac.in/fees/rec_8829.pdf',
      verificationStatus: 'VERIFIED',
      issuedDate: DateTime(2026, 7, 15),
      uploadedAt: DateTime.now().subtract(const Duration(days: 28)),
      sizeBytes: 290000,
    ),
  ];

  DocumentsRepository(this._firestore);

  @override
  Future<List<DocumentModel>> getDocuments(String userId) async {
    try {
      if (_firestore != null) {
        final snap = await _firestore!.collection('documents').where('userId', isEqualTo: userId).get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => DocumentModel.fromMap(d.data(), d.id)).toList();
        }
      }
    } catch (_) {}
    return _localDocs;
  }

  @override
  Future<DocumentModel> uploadDocument(DocumentModel document) async {
    _localDocs.insert(0, document);
    try {
      if (_firestore != null) {
        await _firestore!.collection('documents').doc(document.id).set(document.toMap());
      }
    } catch (_) {}
    return document;
  }

  @override
  Future<void> syncDigiLocker() async {
    await Future.delayed(const Duration(milliseconds: 1200));
  }
}

final documentsRepositoryProvider = Provider<IDocumentsRepository>((ref) {
  return DocumentsRepository(ref.watch(firestoreProvider));
});

final userDocumentsProvider = FutureProvider<List<DocumentModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(documentsRepositoryProvider);
  return repo.getDocuments(user?.id ?? 'demo_user_001');
});
