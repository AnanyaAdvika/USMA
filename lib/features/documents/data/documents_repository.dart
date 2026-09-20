import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/failures.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/models/document_model.dart';

abstract class IDocumentsRepository {
  Future<List<DocumentModel>> getDocuments(String userId);
  Future<DocumentModel> uploadDocument(DocumentModel document);
  Future<void> syncDigiLocker(String userId);
}

List<DocumentModel> _simulatedWallet(String userId) {
  final now = DateTime.now();
  return [
    DocumentModel(
      id: 'doc_aadhaar_01',
      userId: userId,
      title: 'Aadhaar Card',
      type: 'AADHAAR',
      source: 'DIGILOCKER',
      fileUrl: 'simulated://wallet/aadhaar',
      uri: 'in.gov.uidai:aadhaar:XXXXXXXX4829',
      verificationStatus: 'VERIFIED',
      issuedDate: DateTime(2021, 5, 12),
      uploadedAt: now.subtract(const Duration(days: 90)),
      sizeBytes: 420000,
    ),
    DocumentModel(
      id: 'doc_caste_02',
      userId: userId,
      title: 'Scheduled Tribe (ST) Certificate',
      type: 'CASTE_CERTIFICATE',
      source: 'DIGILOCKER',
      fileUrl: 'simulated://wallet/st-certificate',
      uri: 'in.gov.edistrict:caste:ST-2022-8819',
      verificationStatus: 'VERIFIED',
      issuedDate: DateTime(2022, 7, 19),
      uploadedAt: now.subtract(const Duration(days: 85)),
      sizeBytes: 512000,
    ),
    DocumentModel(
      id: 'doc_income_03',
      userId: userId,
      title: 'Annual Income Certificate',
      type: 'INCOME_CERTIFICATE',
      source: 'STATE_EDISTRICT',
      fileUrl: 'simulated://wallet/income',
      uri: 'in.gov.edistrict:income:INC-2025-9921',
      verificationStatus: 'VERIFIED',
      issuedDate: DateTime(2025, 4, 10),
      uploadedAt: now.subtract(const Duration(days: 30)),
      sizeBytes: 380000,
    ),
  ];
}

class MockDocumentsRepository implements IDocumentsRepository {
  final Map<String, List<DocumentModel>> _byUser = {};

  List<DocumentModel> _ensure(String userId) {
    return _byUser.putIfAbsent(userId, () => _simulatedWallet(userId));
  }

  @override
  Future<List<DocumentModel>> getDocuments(String userId) async {
    if (userId.isEmpty) throw const AuthFailure('Sign in to open the document wallet.');
    return List.unmodifiable(_ensure(userId));
  }

  @override
  Future<DocumentModel> uploadDocument(DocumentModel document) async {
    _ensure(document.userId).insert(0, document);
    return document;
  }

  @override
  Future<void> syncDigiLocker(String userId) async {
    // SIMULATED DigiLocker pull — no government endpoint is called.
    _ensure(userId);
  }
}

class LiveDocumentsRepository implements IDocumentsRepository {
  LiveDocumentsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<DocumentModel>> getDocuments(String userId) async {
    if (userId.isEmpty) throw const AuthFailure('Sign in to open the document wallet.');
    try {
      final snap = await _firestore
          .collection('documents')
          .where('userId', isEqualTo: userId)
          .get();
      return snap.docs
          .map((d) => DocumentModel.fromMap(d.data(), d.id))
          .toList();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<DocumentModel> uploadDocument(DocumentModel document) async {
    try {
      await _firestore.collection('documents').doc(document.id).set(document.toMap());
      return document;
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> syncDigiLocker(String userId) async {
    throw const IntegrationFailure(
      'DigiLocker sync must run through the USMA backend. This app does not call government endpoints.',
    );
  }
}

final documentsRepositoryProvider = Provider<IDocumentsRepository>((ref) {
  if (AppConfig.isDemo) return MockDocumentsRepository();
  return LiveDocumentsRepository(ref.watch(firestoreProvider));
});

final userDocumentsProvider = FutureProvider<List<DocumentModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw const AuthFailure('Sign in to open the document wallet.');
  return ref.watch(documentsRepositoryProvider).getDocuments(user.id);
});
