import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/notification_model.dart';
import '../../auth/data/auth_repository.dart';

abstract class INotificationsRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
}

class NotificationsRepository implements INotificationsRepository {
  final FirebaseFirestore? _firestore;

  final List<NotificationModel> _localNotifications = [
    NotificationModel(
      id: 'notif_01',
      title: 'MoTA Scholarship Sanctioned! 🎓',
      body: 'Your application APP-2026-ST-8821 for Post-Matric Scholarship has been approved by Ministry of Tribal Affairs.',
      type: 'APPLICATION_UPDATE',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      relatedId: 'APP-2026-ST-8821',
    ),
    NotificationModel(
      id: 'notif_02',
      title: 'DBT Credit Initiated (₹42,500)',
      body: 'PFMS has processed transfer for UTR SBIN002938192026 to your Aadhaar-seeded SBI account ending in 3819.',
      type: 'DISBURSEMENT',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: false,
      relatedId: 'DISB-2026-PFMS-9921',
    ),
    NotificationModel(
      id: 'notif_03',
      title: 'National Overseas Scholarship (NOS) Window Open',
      body: 'Applications for MoTA National Overseas Scholarship 2026-27 are now open. Check eligibility.',
      type: 'SCHEME_DEADLINE',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      isRead: true,
      relatedId: 'mota_nos_04',
    ),
    NotificationModel(
      id: 'notif_04',
      title: 'DigiLocker Document Verified',
      body: 'Your ST Caste Certificate was automatically verified through Odisha e-District repository.',
      type: 'DOCUMENT_VERIFIED',
      timestamp: DateTime.now().subtract(const Duration(days: 8)),
      isRead: true,
      relatedId: 'doc_caste_02',
    ),
  ];

  NotificationsRepository(this._firestore);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      if (_firestore != null) {
        final snap = await _firestore!.collection('notifications').get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => NotificationModel.fromMap(d.data(), d.id)).toList();
        }
      }
    } catch (_) {}
    return _localNotifications;
  }

  @override
  Future<void> markAsRead(String id) async {
    final idx = _localNotifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final item = _localNotifications[idx];
      _localNotifications[idx] = NotificationModel(
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
}

final notificationsRepositoryProvider = Provider<INotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(firestoreProvider));
});

final userNotificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  return ref.watch(notificationsRepositoryProvider).getNotifications();
});
