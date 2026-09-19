import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/disbursement_model.dart';
import '../../auth/data/auth_repository.dart';

abstract class IDisbursementsRepository {
  Future<List<DisbursementModel>> getDisbursements(String userId);
}

class DisbursementsRepository implements IDisbursementsRepository {
  final FirebaseFirestore? _firestore;

  final List<DisbursementModel> _localDisbursements = [
    DisbursementModel(
      id: 'DISB-2026-PFMS-9921',
      applicationId: 'APP-2026-ST-8821',
      schemeTitle: 'Post-Matric Scholarship for ST Students (PMS-ST)',
      amount: 42500.0,
      utrNumber: 'SBIN002938192026',
      pfmsStatus: 'SUCCESS',
      bankName: 'State Bank of India',
      accountLast4: '3819',
      disbursementDate: DateTime.now().subtract(const Duration(days: 12)),
      academicInstallment: 'Semester 5 Maintenance & Tuition (Installment 1 of 2)',
    ),
    DisbursementModel(
      id: 'DISB-2025-PFMS-4412',
      applicationId: 'APP-2025-ST-1102',
      schemeTitle: 'Post-Matric Scholarship for ST Students (PMS-ST)',
      amount: 42500.0,
      utrNumber: 'SBIN001128491025',
      pfmsStatus: 'SUCCESS',
      bankName: 'State Bank of India',
      accountLast4: '3819',
      disbursementDate: DateTime.now().subtract(const Duration(days: 180)),
      academicInstallment: 'Semester 4 Maintenance & Tuition (Installment 2 of 2)',
    ),
    DisbursementModel(
      id: 'DISB-2026-PFMS-NEW',
      applicationId: 'APP-2026-ST-8821',
      schemeTitle: 'Post-Matric Scholarship for ST Students (PMS-ST)',
      amount: 42500.0,
      utrNumber: 'PENDING_BANK_ACK',
      pfmsStatus: 'PROCESSING',
      bankName: 'State Bank of India',
      accountLast4: '3819',
      disbursementDate: DateTime.now().add(const Duration(days: 3)),
      academicInstallment: 'Semester 6 Maintenance & Tuition (Installment 2 of 2)',
    ),
  ];

  DisbursementsRepository(this._firestore);

  @override
  Future<List<DisbursementModel>> getDisbursements(String userId) async {
    try {
      if (_firestore != null) {
        final snap = await _firestore!.collection('disbursements').get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => DisbursementModel.fromMap(d.data(), d.id)).toList();
        }
      }
    } catch (_) {}
    return _localDisbursements;
  }
}

final disbursementsRepositoryProvider = Provider<IDisbursementsRepository>((ref) {
  return DisbursementsRepository(ref.watch(firestoreProvider));
});

final userDisbursementsProvider = FutureProvider<List<DisbursementModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(disbursementsRepositoryProvider);
  return repo.getDisbursements(user?.id ?? 'demo_user_001');
});
