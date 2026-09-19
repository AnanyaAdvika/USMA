class DisbursementModel {
  final String id;
  final String applicationId;
  final String schemeTitle;
  final double amount;
  final String utrNumber;
  final String pfmsStatus; // 'SUCCESS', 'PENDING_BANK', 'PROCESSING', 'FAILED'
  final String bankName;
  final String accountLast4;
  final DateTime disbursementDate;
  final String academicInstallment; // e.g. "Installment 1 of 2"

  const DisbursementModel({
    required this.id,
    required this.applicationId,
    required this.schemeTitle,
    required this.amount,
    required this.utrNumber,
    required this.pfmsStatus,
    required this.bankName,
    required this.accountLast4,
    required this.disbursementDate,
    required this.academicInstallment,
  });

  factory DisbursementModel.fromMap(Map<String, dynamic> map, String docId) {
    return DisbursementModel(
      id: docId,
      applicationId: map['applicationId'] ?? '',
      schemeTitle: map['schemeTitle'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      utrNumber: map['utrNumber'] ?? '',
      pfmsStatus: map['pfmsStatus'] ?? 'PROCESSING',
      bankName: map['bankName'] ?? 'State Bank of India',
      accountLast4: map['accountLast4'] ?? 'XXXX',
      disbursementDate: map['disbursementDate'] != null
          ? DateTime.tryParse(map['disbursementDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      academicInstallment: map['academicInstallment'] ?? 'Installment 1',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'applicationId': applicationId,
      'schemeTitle': schemeTitle,
      'amount': amount,
      'utrNumber': utrNumber,
      'pfmsStatus': pfmsStatus,
      'bankName': bankName,
      'accountLast4': accountLast4,
      'disbursementDate': disbursementDate.toIso8601String(),
      'academicInstallment': academicInstallment,
    };
  }
}
