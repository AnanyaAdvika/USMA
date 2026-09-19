class DocumentModel {
  final String id;
  final String userId;
  final String title;
  final String type; // 'CASTE_CERTIFICATE', 'INCOME_CERTIFICATE', 'AADHAAR', 'FEE_RECEIPT', 'MARKSHEET', 'DOMICILE'
  final String source; // 'DIGILOCKER', 'MANUAL_UPLOAD', 'STATE_EDISTRICT'
  final String fileUrl;
  final String? uri; // DigiLocker URI if applicable
  final String verificationStatus; // 'VERIFIED', 'PENDING', 'REJECTED'
  final DateTime issuedDate;
  final DateTime uploadedAt;
  final int? sizeBytes;

  const DocumentModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    this.source = 'DIGILOCKER',
    required this.fileUrl,
    this.uri,
    this.verificationStatus = 'VERIFIED',
    required this.issuedDate,
    required this.uploadedAt,
    this.sizeBytes,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map, String docId) {
    return DocumentModel(
      id: docId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? 'OTHER',
      source: map['source'] ?? 'MANUAL_UPLOAD',
      fileUrl: map['fileUrl'] ?? '',
      uri: map['uri'],
      verificationStatus: map['verificationStatus'] ?? 'PENDING',
      issuedDate: map['issuedDate'] != null
          ? DateTime.tryParse(map['issuedDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.tryParse(map['uploadedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      sizeBytes: map['sizeBytes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'type': type,
      'source': source,
      'fileUrl': fileUrl,
      'uri': uri,
      'verificationStatus': verificationStatus,
      'issuedDate': issuedDate.toIso8601String(),
      'uploadedAt': uploadedAt.toIso8601String(),
      'sizeBytes': sizeBytes,
    };
  }
}
