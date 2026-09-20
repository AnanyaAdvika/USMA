import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/failures.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/models/application_model.dart';
import '../domain/scholarship_uniqueness.dart';

abstract class IApplicationsRepository {
  Future<List<ApplicationModel>> getApplications(String userId);
  Future<ApplicationModel> getApplicationById(String applicationId);
  Future<ApplicationModel> submitApplication(ApplicationModel application);
}

List<ApplicationModel> _simulatedApplicationsFor(String userId) {
  final now = DateTime.now();
  return [
    ApplicationModel(
      id: 'APP-2026-ST-8821',
      userId: userId,
      schemeId: 'post_matric',
      schemeTitle: 'Post-Matric Scholarship for ST Students',
      academicYear: '2026-2027',
      instituteName: 'National Institute of Technology, Rourkela',
      courseName: 'B.Tech Computer Science & Engineering (Year 3)',
      sanctionedAmount: 85000,
      status: 'sanctioned',
      submittedAt: now.subtract(const Duration(days: 28)),
      updatedAt: now.subtract(const Duration(days: 2)),
      simulated: true,
      deficiencies: const [
        'Institute asked for a clearer fee receipt (does not block tracking).',
      ],
      timeline: [
        TimelineEvent(
          title: 'Submitted',
          description: 'SIMULATED: application received with DigiLocker wallet reuse.',
          timestamp: now.subtract(const Duration(days: 28)),
          isCompleted: true,
        ),
        TimelineEvent(
          title: 'Verification',
          description:
              'SIMULATED: AISHE / e-District checks. Mismatch routed to manual review.',
          timestamp: now.subtract(const Duration(days: 20)),
          isCompleted: true,
        ),
        TimelineEvent(
          title: 'Sanction',
          description: 'SIMULATED: MoTA sanction order queued for DBT.',
          timestamp: now.subtract(const Duration(days: 2)),
          isCompleted: true,
        ),
        TimelineEvent(
          title: 'Disbursement',
          description: 'SIMULATED: PFMS credit pending.',
          timestamp: now.add(const Duration(days: 5)),
          isCompleted: false,
        ),
      ],
    ),
  ];
}

class MockApplicationsRepository implements IApplicationsRepository {
  MockApplicationsRepository();

  final _uniqueness = const ScholarshipUniqueness();
  final List<ApplicationModel> _apps = [];
  bool _seeded = false;

  void _seed(String userId) {
    if (_seeded) return;
    _apps.addAll(_simulatedApplicationsFor(userId));
    _seeded = true;
  }

  @override
  Future<List<ApplicationModel>> getApplications(String userId) async {
    if (userId.isEmpty) {
      throw const AuthFailure('Sign in to view applications.');
    }
    _seed(userId);
    return List.unmodifiable(
      _apps.where((app) => app.userId == userId),
    );
  }

  @override
  Future<ApplicationModel> getApplicationById(String applicationId) async {
    for (final app in _apps) {
      if (app.id == applicationId) return app;
    }
    throw NotFoundFailure('Application "$applicationId" was not found.');
  }

  @override
  Future<ApplicationModel> submitApplication(ApplicationModel application) async {
    if (application.userId.isEmpty) {
      throw const AuthFailure('Sign in before submitting an application.');
    }
    _seed(application.userId);
    final existing = _apps.where((a) => a.userId == application.userId).toList();
    final conflict = _uniqueness.conflictIfApplying(
      existing: existing,
      userId: application.userId,
    );
    if (conflict != null) throw conflict;
    _apps.insert(0, application);
    return application;
  }
}

class LiveApplicationsRepository implements IApplicationsRepository {
  LiveApplicationsRepository(this._firestore);

  final FirebaseFirestore _firestore;
  final _uniqueness = const ScholarshipUniqueness();

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('applications');

  @override
  Future<List<ApplicationModel>> getApplications(String userId) async {
    if (userId.isEmpty) {
      throw const AuthFailure('Sign in to view applications.');
    }
    try {
      final snapshot = await _col.where('userId', isEqualTo: userId).get();
      return snapshot.docs
          .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<ApplicationModel> getApplicationById(String applicationId) async {
    try {
      final doc = await _col.doc(applicationId).get();
      if (!doc.exists || doc.data() == null) {
        throw NotFoundFailure('Application "$applicationId" was not found.');
      }
      return ApplicationModel.fromMap(doc.data()!, doc.id);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<ApplicationModel> submitApplication(ApplicationModel application) async {
    try {
      final existing = await getApplications(application.userId);
      final conflict = _uniqueness.conflictIfApplying(
        existing: existing,
        userId: application.userId,
      );
      if (conflict != null) throw conflict;
      await _col.doc(application.id).set(application.toMap());
      return application;
    } on Failure {
      rethrow;
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}

final applicationsRepositoryProvider = Provider<IApplicationsRepository>((ref) {
  if (AppConfig.isDemo) {
    return MockApplicationsRepository();
  }
  return LiveApplicationsRepository(ref.watch(firestoreProvider));
});

final userApplicationsProvider = FutureProvider<List<ApplicationModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    throw const AuthFailure('Sign in to view applications.');
  }
  return ref.watch(applicationsRepositoryProvider).getApplications(user.id);
});

final applicationDetailProvider =
    FutureProvider.family<ApplicationModel?, String>((ref, id) async {
  final list = await ref.watch(userApplicationsProvider.future);
  for (final app in list) {
    if (app.id == id) return app;
  }
  try {
    return await ref.watch(applicationsRepositoryProvider).getApplicationById(id);
  } on NotFoundFailure {
    return null;
  }
});
