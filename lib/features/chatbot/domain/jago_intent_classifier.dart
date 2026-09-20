// ============================================================
// USMA — JAGO Scholarship Assistance System
// jago_intent_classifier.dart
//
// Rule-based and keyword-driven intent classification
// Supports English and Hindi queries
// ============================================================

import 'jago_intent_and_context.dart';

class JagoIntentClassifier {
  /// Classifies query into one of the 12 canonical JAGO intents
  static JagoIntent classify(String query) {
    final lower = query.trim().toLowerCase();

    // 1. GRIEVANCE
    if (lower.contains('grievance') ||
        lower.contains('complaint') ||
        lower.contains('complain') ||
        lower.contains('शिकायत') ||
        lower.contains('समस्या दर्ज') ||
        lower.contains('helpdesk') ||
        lower.contains('raise issue')) {
      return JagoIntent.grievance;
    }

    // 2. PAYMENT & DBT
    if (lower.contains('payment') ||
        lower.contains('dbt') ||
        lower.contains('disburs') ||
        lower.contains('money') ||
        lower.contains('credit') ||
        lower.contains('bank account') ||
        lower.contains('installments') ||
        lower.contains('भुगतान') ||
        lower.contains('पैसा') ||
        lower.contains('रुपया') ||
        lower.contains('खाते में') ||
        lower.contains('when was my last payment') ||
        lower.contains('why haven\'t i received')) {
      return JagoIntent.payment;
    }

    // 3. SANCTION
    if (lower.contains('sanction') ||
        lower.contains('स्वीकृत') ||
        lower.contains('मंजूर') ||
        lower.contains('sanction order') ||
        lower.contains('has my scholarship been sanctioned')) {
      return JagoIntent.sanction;
    }

    // 4. DEFICIENCY
    if (lower.contains('deficiency') ||
        lower.contains('defect') ||
        lower.contains('objection') ||
        lower.contains('कमियां') ||
        lower.contains('त्रुटि') ||
        lower.contains('clarification sought')) {
      return JagoIntent.deficiency;
    }

    // 5. DOCUMENTS
    if (lower.contains('document') ||
        lower.contains('certificate') ||
        lower.contains('income cert') ||
        lower.contains('caste cert') ||
        lower.contains('dastavej') ||
        lower.contains('दस्तावेज़') ||
        lower.contains('प्रमाण पत्र') ||
        lower.contains('mark sheet') ||
        lower.contains('marksheet') ||
        lower.contains('bonafide') ||
        lower.contains('what documents do i need') ||
        lower.contains('which document is missing') ||
        lower.contains('expired')) {
      return JagoIntent.documents;
    }

    // 6. VERIFICATION
    if (lower.contains('verification') ||
        lower.contains('verify') ||
        lower.contains('institute verify') ||
        lower.contains('nodal') ||
        lower.contains('सत्यापन') ||
        lower.contains('जांच') ||
        lower.contains('mismatch') ||
        lower.contains('spelling')) {
      return JagoIntent.verification;
    }

    // 7. ELIGIBILITY
    if (lower.contains('eligib') ||
        lower.contains('qualif') ||
        lower.contains('पात्र') ||
        lower.contains('योग्यता') ||
        lower.contains('am i eligible') ||
        lower.contains('why am i not eligible') ||
        lower.contains('criteria') ||
        lower.contains('ceiling') ||
        lower.contains('income limit')) {
      return JagoIntent.eligibility;
    }

    // 8. APPLICATION STATUS
    if (lower.contains('status') ||
        lower.contains('track') ||
        lower.contains('pending') ||
        lower.contains('progress') ||
        lower.contains('स्थिति') ||
        lower.contains('स्टेटस') ||
        lower.contains('ट्रैक') ||
        lower.contains('लंबित') ||
        lower.contains('why is my application pending') ||
        lower.contains('where is my application')) {
      return JagoIntent.applicationStatus;
    }

    // 9. DEADLINE
    if (lower.contains('deadline') ||
        lower.contains('last date') ||
        lower.contains('closing date') ||
        lower.contains('अंतिम तिथि') ||
        lower.contains('आखिरी तारीख')) {
      return JagoIntent.deadline;
    }

    // 10. HOW TO APPLY
    if (lower.contains('how to apply') ||
        lower.contains('apply process') ||
        lower.contains('आवेदन कैसे') ||
        lower.contains('apply कैसे') ||
        lower.contains('registration process')) {
      return JagoIntent.howToApply;
    }

    // 11. SCHEME INFORMATION
    if (lower.contains('scheme') ||
        lower.contains('post-matric') ||
        lower.contains('pre-matric') ||
        lower.contains('top class') ||
        lower.contains('nfst') ||
        lower.contains('nos') ||
        lower.contains('योजना') ||
        lower.contains('स्कॉलरशिप') ||
        lower.contains('fellowship') ||
        lower.contains('which scholarship')) {
      return JagoIntent.schemeInformation;
    }

    // 12. GENERAL HELP (Fallback)
    return JagoIntent.generalHelp;
  }
}
