import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/errors/failures.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/models/notification_model.dart';

abstract class INotificationsRepository {
  Future<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsRead(String userId, String id);
}

List<NotificationModel> _simulatedNotifications() {
  final now = DateTime.now();
  return [
    NotificationModel(
      id: 'notif_01',
      title: 'JAGO milestone: sanctioned',
      body: 'SIMULATED: Post-Matric application APP-2026-ST-8821 is sanctioned.',
      type: 'APPLICATION_UPDATE',
      timestamp: now.subtract(const Duration(hours: 3)),
      relatedId: 'APP-2026-ST-8821',
    ),
    NotificationModel(
      id: 'notif_02',
      title: 'DBT processing',
      body: 'SIMULATED: Installment 2 is queued on PFMS.',
      type: 'DISBURSEMENT',
      timestamp: now.subtract(const Duration(days: 2)),
      relatedId: 'DISB-2026-PFMS-NEW',
    ),
  ];
}

class MockNotificationsRepository implements INotificationsRepository {
  final Map<String, List<NotificationModel>> _byUser = {};

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    if (userId.isEmpty) throw const AuthFailure('Sign in to view alerts.');
    return _byUser.putIfAbsent(userId, _simulatedNotifications);
  }

  @override
  Future<void> markAsRead(String userId, String id) async {
    final list = _byUser[userId];
    if (list == null) return;
    final idx = list.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    final item = list[idx];
    list[idx] = NotificationModel(
      id: item.id,
      title: item.title,
      body: item.body,
      type: item.type,
      timestamp: item.timestamp,
      isRead: true,
      relatedId: item.relatedId,
    );
  }
}

class LiveNotificationsRepository implements INotificationsRepository {
  LiveNotificationsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    if (userId.isEmpty) throw const AuthFailure('Sign in to view alerts.');
    try {
      final snap = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();
      return snap.docs
          .map((d) => NotificationModel.fromMap(d.data(), d.id))
          .toList();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> markAsRead(String userId, String id) async {
    try {
      await _firestore.collection('notifications').doc(id).update({'isRead': true});
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}

final notificationsRepositoryProvider = Provider<INotificationsRepository>((ref) {
  if (AppConfig.isDemo) return MockNotificationsRepository();
  return LiveNotificationsRepository(ref.watch(firestoreProvider));
});

final userNotificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw const AuthFailure('Sign in to view alerts.');
  return ref.watch(notificationsRepositoryProvider).getNotifications(user.id);
});
