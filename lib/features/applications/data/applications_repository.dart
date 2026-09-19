import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/application_model.dart';
import '../../auth/data/auth_repository.dart';

abstract class IApplicationsRepository {
  Future<List<ApplicationModel>> getApplications(String userId);
  Future<ApplicationModel?> getApplicationById(String applicationId);
  Future<ApplicationModel> submitApplication(ApplicationModel application);
}

class ApplicationsRepository implements IApplicationsRepository {
  final FirebaseFirestore? _firestore;

  final List<ApplicationModel> _localApplications = [
    ApplicationModel(
      id: 'APP-2026-ST-8821',
      userId: 'demo_user_001',
      schemeId: 'mota_pms_st_01',
      schemeTitle: 'Post-Matric Scholarship for ST Students (PMS-ST)',
      academicYear: '2026-2027',
      instituteName: 'National Institute of Technology, Rourkela',
      courseName: 'B.Tech Computer Science & Engineering (Year 3)',
      sanctionedAmount: 85000.0,
      status: 'MINISTRY_APPROVED',
      submittedAt: DateTime.now().subtract(const Duration(days: 28)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      timeline: [
        TimelineEvent(
          title: 'Application Submitted',
          description: 'Application successfully verified with DigiLocker documents.',
          timestamp: DateTime.now().subtract(const Duration(days: 28)),
          isCompleted: true,
        ),
        TimelineEvent(
          title: 'Institute Verification (AISHE)',
          description: 'Verified by Nodal Officer, NIT Rourkela.',
          timestamp: DateTime.now().subtract(const Duration(days: 20)),
          isCompleted: true,
        ),
        TimelineEvent(
          title: 'District & State Welfare Verification',
          description: 'Caste & Income certified by District Welfare Office, Mayurbhanj.',
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
          isCompleted: true,
        ),
        TimelineEvent(
          title: 'Ministry Sanction & DBT PFMS Queued',
          description: 'Sanction order issued by Ministry of Tribal Affairs (MoTA).',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isCompleted: true,
        ),
        TimelineEvent(
          title: 'Direct Bank Transfer (DBT)',
          description: 'Aadhaar Payment Bridge System transfer into seeded bank account.',
          timestamp: DateTime.now().add(const Duration(days: 5)),
          isCompleted: false,
        ),
      ],
    ),
    ApplicationModel(
      id: 'APP-2026-ST-5190',
      userId: 'demo_user_001',
      schemeId: 'mota_top_class_03',
      schemeTitle: 'National Scholarship for Top Class Education for ST Students',
      academicYear: '2026-2027',
      instituteName: 'Indian Institute of Technology, Kharagpur',
      courseName: 'M.Tech Artificial Intelligence',
      sanctionedAmount: 200000.0,
      status: 'INSTITUTE_VERIFIED',
      submittedAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now().subtract(const Duration(days: 6)),
      timeline: [
        TimelineEvent(
          title: 'Application Submitted',
          description: 'Submitted online with e-KYC authentication.',
          timestamp: DateTime.now().subtract(const Duration(days: 14)),
          isCompleted: true,
        ),
        TimelineEvent(
          title: 'Institute Verification (AISHE)',
          description: 'Academic standing verified by IIT Kharagpur Dean Office.',
          timestamp: DateTime.now().subtract(const Duration(days: 6)),
          isCompleted: true,
        ),
        TimelineEvent(
          title: 'State Welfare Department Verification',
          description: 'Verification pending at State Welfare Department portal.',
          timestamp: DateTime.now().add(const Duration(days: 4)),
          isCompleted: false,
        ),
      ],
    ),
  ];

  ApplicationsRepository(this._firestore);

  @override
  Future<List<ApplicationModel>> getApplications(String userId) async {
    try {
      if (_firestore != null) {
        final snapshot = await _firestore!
            .collection('applications')
            .where('userId', isEqualTo: userId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      }
    } catch (_) {}
    return _localApplications;
  }

  @override
  Future<ApplicationModel?> getApplicationById(String applicationId) async {
    try {
      if (_firestore != null) {
        final doc = await _firestore!.collection('applications').doc(applicationId).get();
        if (doc.exists && doc.data() != null) {
          return ApplicationModel.fromMap(doc.data()!, doc.id);
        }
      }
    } catch (_) {}
    return _localApplications.firstWhere(
      (a) => a.id == applicationId,
      orElse: () => _localApplications.first,
    );
  }

  @override
  Future<ApplicationModel> submitApplication(ApplicationModel application) async {
    _localApplications.insert(0, application);
    try {
      if (_firestore != null) {
        await _firestore!
            .collection('applications')
            .doc(application.id)
            .set(application.toMap());
      }
    } catch (_) {}
    return application;
  }
}

final applicationsRepositoryProvider = Provider<IApplicationsRepository>((ref) {
  return ApplicationsRepository(ref.watch(firestoreProvider));
});

final userApplicationsProvider = FutureProvider<List<ApplicationModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(applicationsRepositoryProvider);
  return repo.getApplications(user?.id ?? 'demo_user_001');
});

final applicationDetailProvider = FutureProvider.family<ApplicationModel?, String>((ref, id) async {
  final repo = ref.watch(applicationsRepositoryProvider);
  return repo.getApplicationById(id);
});
