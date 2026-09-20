import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/failures.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/models/disbursement_model.dart';

abstract class IDisbursementsRepository {
  Future<List<DisbursementModel>> getDisbursements(String userId);
}

List<DisbursementModel> _simulatedDisbursements() {
  final now = DateTime.now();
  return [
    DisbursementModel(
      id: 'DISB-2026-PFMS-9921',
      applicationId: 'APP-2026-ST-8821',
      schemeTitle: 'Post-Matric Scholarship for ST Students',
      amount: 42500,
      utrNumber: 'SIM-SBIN002938192026',
      pfmsStatus: 'SUCCESS',
      bankName: 'State Bank of India',
      accountLast4: '3819',
      disbursementDate: now.subtract(const Duration(days: 12)),
      academicInstallment: 'Installment 1 of 2',
    ),
    DisbursementModel(
      id: 'DISB-2026-PFMS-NEW',
      applicationId: 'APP-2026-ST-8821',
      schemeTitle: 'Post-Matric Scholarship for ST Students',
      amount: 42500,
      utrNumber: 'PENDING_BANK_ACK',
      pfmsStatus: 'PROCESSING',
      bankName: 'State Bank of India',
      accountLast4: '3819',
      disbursementDate: now.add(const Duration(days: 3)),
      academicInstallment: 'Installment 2 of 2',
    ),
  ];
}

class MockDisbursementsRepository implements IDisbursementsRepository {
  @override
  Future<List<DisbursementModel>> getDisbursements(String userId) async {
    if (userId.isEmpty) throw const AuthFailure('Sign in to view DBT status.');
    return _simulatedDisbursements();
  }
}

class LiveDisbursementsRepository implements IDisbursementsRepository {
  LiveDisbursementsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<DisbursementModel>> getDisbursements(String userId) async {
    if (userId.isEmpty) throw const AuthFailure('Sign in to view DBT status.');
    try {
      final snap = await _firestore
          .collection('disbursements')
          .where('userId', isEqualTo: userId)
          .get();
      return snap.docs
          .map((d) => DisbursementModel.fromMap(d.data(), d.id))
          .toList();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}

final disbursementsRepositoryProvider = Provider<IDisbursementsRepository>((ref) {
  if (AppConfig.isDemo) return MockDisbursementsRepository();
  return LiveDisbursementsRepository(ref.watch(firestoreProvider));
});

final userDisbursementsProvider = FutureProvider<List<DisbursementModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw const AuthFailure('Sign in to view DBT status.');
  return ref.watch(disbursementsRepositoryProvider).getDisbursements(user.id);
});
