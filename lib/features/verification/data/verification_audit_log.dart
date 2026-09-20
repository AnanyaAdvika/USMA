// ============================================================
// USMA — Verification Audit Log
// verification_audit_log.dart
//
// STATUS: REAL IMPLEMENTATION (domain model + in-memory store)
//
// Every verification request generates an immutable audit
// entry. In production this must be persisted to Firestore
// (with restricted read rules) or a government-approved
// secure log store.
//
// SECURITY:
//   • No Aadhaar numbers or full bank account numbers in logs.
//   • No debug prints of sensitive fields.
//   • Role-based read access enforced in firestore.rules.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/integration_provider.dart';

// ─────────────────────────────────────────────────────────────
// Immutable audit entry
// ─────────────────────────────────────────────────────────────
class VerificationAuditEntry {
  final String verificationId;

  /// Opaque student token — never a real Aadhaar or NID.
  final String studentToken;

  final GovernmentSystem source;
  final DateTime timestamp;
  final IntegrationStatus status;

  /// Field names checked (not values — minimum data principle).
  final List<String> fieldsChecked;

  /// Field names that mismatched (not source values).
  final List<String> mismatchedFieldNames;

  final bool reviewRequired;
  final bool isSimulated;

  const VerificationAuditEntry({
    required this.verificationId,
    required this.studentToken,
    required this.source,
    required this.timestamp,
    required this.status,
    required this.fieldsChecked,
    this.mismatchedFieldNames = const [],
    required this.reviewRequired,
    required this.isSimulated,
  });

  factory VerificationAuditEntry.fromResponse({
    required String verificationId,
    required String studentToken,
    required IntegrationResponse response,
  }) {
    return VerificationAuditEntry(
      verificationId: verificationId,
      studentToken: studentToken,
      source: response.sourceSystem,
      timestamp: response.timestamp,
      status: response.status,
      fieldsChecked: response.verifiedFields +
          response.mismatchedFields.keys.toList(),
      mismatchedFieldNames: response.mismatchedFields.keys.toList(),
      reviewRequired: response.requiresManualReview,
      isSimulated: response.isSimulated,
    );
  }

  Map<String, dynamic> toMap() => {
        'verificationId': verificationId,
        'studentToken': studentToken,
        'source': source.displayName,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'fieldsChecked': fieldsChecked,
        'mismatchedFieldNames': mismatchedFieldNames,
        'reviewRequired': reviewRequired,
        'isSimulated': isSimulated,
      };
}

// ─────────────────────────────────────────────────────────────
// In-memory audit log (replace with Firestore write in prod)
// ─────────────────────────────────────────────────────────────
class VerificationAuditLog extends StateNotifier<List<VerificationAuditEntry>> {
  VerificationAuditLog() : super(const []);

  void record(VerificationAuditEntry entry) {
    // No debug prints — sensitive operation
    state = [...state, entry];
  }

  List<VerificationAuditEntry> entriesForStudent(String studentToken) =>
      state.where((e) => e.studentToken == studentToken).toList();

  List<VerificationAuditEntry> get pendingReviews =>
      state.where((e) => e.reviewRequired).toList();
}

final verificationAuditLogProvider =
    StateNotifierProvider<VerificationAuditLog, List<VerificationAuditEntry>>(
        (ref) => VerificationAuditLog());
