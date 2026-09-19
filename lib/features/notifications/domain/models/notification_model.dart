class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'APPLICATION_UPDATE', 'DISBURSEMENT', 'SCHEME_DEADLINE', 'DOCUMENT_VERIFIED'
  final DateTime timestamp;
  final bool isRead;
  final String? relatedId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.relatedId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'GENERAL',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      relatedId: map['relatedId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'relatedId': relatedId,
    };
  }
}
