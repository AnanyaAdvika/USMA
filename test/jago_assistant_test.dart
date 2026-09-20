// ============================================================
// USMA — JAGO Scholarship Assistance System
// jago_assistant_test.dart
//
// Comprehensive Unit & Integration Tests covering:
// 1. Intent Detection across 12 canonical intents
// 2. Context Retrieval & State Evaluation
// 3. Actionable Structured Responses (Answer -> Reason -> Status -> Action -> Source)
// 4. Ineligible Income Criterion & Document Queries
// 5. Payment & Sanction Queries
// 6. Unsupported Information Fallback (Zero Hallucination)
// 7. Hindi Query Intent Detection & Multilingual Support
// 8. Grievance Draft Generation without Auto-Submission
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:usma/features/chatbot/domain/context_aware_scholarship_assistant.dart';
import 'package:usma/features/chatbot/domain/jago_intent_and_context.dart';
import 'package:usma/features/chatbot/domain/jago_intent_classifier.dart';
import 'package:usma/features/chatbot/domain/jago_localization.dart';

void main() {
  group('1. JAGO Intent Classifier Tests', () {
    test('Detects ELIGIBILITY intent', () {
      expect(
        JagoIntentClassifier.classify('Am I eligible for Post-Matric?'),
        JagoIntent.eligibility,
      );
      expect(
        JagoIntentClassifier.classify('Why am I not eligible?'),
        JagoIntent.eligibility,
      );
    });

    test('Detects APPLICATION_STATUS intent', () {
      expect(
        JagoIntentClassifier.classify('Why is my application pending?'),
        JagoIntent.applicationStatus,
      );
      expect(
        JagoIntentClassifier.classify('Track my application status'),
        JagoIntent.applicationStatus,
      );
    });

    test('Detects DOCUMENTS intent', () {
      expect(
        JagoIntentClassifier.classify('What documents do I need?'),
        JagoIntent.documents,
      );
      expect(
        JagoIntentClassifier.classify('Which document is missing?'),
        JagoIntent.documents,
      );
      expect(
        JagoIntentClassifier.classify('My income certificate expired. What should I do?'),
        JagoIntent.documents,
      );
    });

    test('Detects DEFICIENCY intent', () {
      expect(
        JagoIntentClassifier.classify('What deficiency was raised on my profile?'),
        JagoIntent.deficiency,
      );
    });

    test('Detects VERIFICATION intent', () {
      expect(
        JagoIntentClassifier.classify('How does institute verification work?'),
        JagoIntent.verification,
      );
    });

    test('Detects PAYMENT intent', () {
      expect(
        JagoIntentClassifier.classify('Why haven\'t I received my scholarship?'),
        JagoIntent.payment,
      );
      expect(
        JagoIntentClassifier.classify('When was my last payment?'),
        JagoIntent.payment,
      );
    });

    test('Detects SANCTION intent', () {
      expect(
        JagoIntentClassifier.classify('Has my scholarship been sanctioned?'),
        JagoIntent.sanction,
      );
    });

    test('Detects DEADLINE intent', () {
      expect(
        JagoIntentClassifier.classify('What is the last date to apply?'),
        JagoIntent.deadline,
      );
    });

    test('Detects SCHEME_INFORMATION intent', () {
      expect(
        JagoIntentClassifier.classify('Tell me about Top Class Education scheme'),
        JagoIntent.schemeInformation,
      );
    });

    test('Detects GRIEVANCE intent', () {
      expect(
        JagoIntentClassifier.classify('How do I raise a grievance?'),
        JagoIntent.grievance,
      );
      expect(
        JagoIntentClassifier.classify('File a complaint regarding delayed payment'),
        JagoIntent.grievance,
      );
    });

    test('Detects HOW_TO_APPLY intent', () {
      expect(
        JagoIntentClassifier.classify('How to apply for scholarship?'),
        JagoIntent.howToApply,
      );
    });

    test('Detects Hindi queries correctly', () {
      expect(
        JagoIntentClassifier.classify('मेरी छात्रवृत्ति का स्टेटस क्या है?'),
        JagoIntent.applicationStatus,
      );
      expect(
        JagoIntentClassifier.classify('क्या मैं पात्र हूँ?'),
        JagoIntent.eligibility,
      );
      expect(
        JagoIntentClassifier.classify('शिकायत कैसे दर्ज करें?'),
        JagoIntent.grievance,
      );
      expect(
        JagoIntentClassifier.classify('खाते में पैसा कब आएगा?'),
        JagoIntent.payment,
      );
    });

    test('Falls back to GENERAL_HELP for unknown query', () {
      expect(
        JagoIntentClassifier.classify('What is the weather in Delhi today?'),
        JagoIntent.generalHelp,
      );
    });
  });

  group('2. Context-Aware Evaluation & Safety Tests', () {
    const studentWithActiveApp = ComprehensiveStudentContext(
      studentName: 'Rahul Kumar',
      studentId: 'ST-2026-8819',
      socialCategory: 'ST',
      annualFamilyIncome: 180000.0,
      educationLevel: 'Higher Education / College',
      activeSchemeId: 'post_matric_st',
      activeSchemeTitle: 'Post-Matric Scholarship for ST Students (PMS-ST)',
      institutionName: 'Govt. College of Engineering, Keonjhar',
      applicationStatus: 'submitted',
      verificationStatus: 'INSTITUTE_PENDING',
      paymentStatus: 'PROCESSING',
    );

    test('Returns actionable response with Institute check when pending at institute', () {
      final response = ContextAwareScholarshipAssistant.process(
        query: 'Why is my application pending?',
        context: studentWithActiveApp,
      );

      expect(response.intent, JagoIntent.applicationStatus);
      expect(response.currentStatus, contains('Waiting for Institute Verification'));
      expect(response.actions.any((a) => a.label == 'View Application'), isTrue);
      expect(response.source.portal, contains('tribal.nic.in'));
    });

    test('Evaluates ineligibility with detailed criteria breakdown', () {
      const highIncomeStudent = ComprehensiveStudentContext(
        studentName: 'Sunita Marandi',
        socialCategory: 'ST',
        annualFamilyIncome: 350000.0, // Exceeds 2.50L ceiling for PMS-ST
        educationLevel: 'Higher Education',
      );

      final response = ContextAwareScholarshipAssistant.process(
        query: 'Why am I not eligible?',
        context: highIncomeStudent,
      );

      expect(response.intent, JagoIntent.eligibility);
      expect(response.answer, contains('❌ Income criterion'));
      expect(response.answer, contains('✓ ST status'));
      expect(response.answer, contains('✓ Education level'));
      expect(response.actions.any((a) => a.label == 'Check Eligibility'), isTrue);
    });

    test('Documents query returns actual missing items if deficiencies exist', () {
      const studentWithDeficiency = ComprehensiveStudentContext(
        studentName: 'Amit Soren',
        activeSchemeTitle: 'Post-Matric ST',
        applicationStatus: 'deficiency_raised',
        deficiencies: ['Annual Income Certificate blurred / illegible'],
        missingDocuments: ['Bonafide Certificate 2026-27'],
      );

      final response = ContextAwareScholarshipAssistant.process(
        query: 'What documents are missing?',
        context: studentWithDeficiency,
      );

      expect(response.intent, JagoIntent.documents);
      expect(response.answer, contains('Annual Income Certificate blurred'));
      expect(response.answer, contains('Bonafide Certificate 2026-27'));
      expect(response.actions.any((a) => a.label == 'Check Documents'), isTrue);
    });

    test('Payment query reflects actual DBT disbursement record without inventing numbers', () {
      final paidStudent = ComprehensiveStudentContext(
        studentName: 'Rahul Kumar',
        activeSchemeTitle: 'Post-Matric ST',
        applicationStatus: 'disbursed',
        paymentStatus: 'SUCCESS',
        lastDisbursedAmount: 42500.0,
        lastPaymentUtr: 'SIM-SBIN002938192026',
        lastPaymentDate: DateTime(2026, 3, 18),
      );

      final response = ContextAwareScholarshipAssistant.process(
        query: 'When was my last payment?',
        context: paidStudent,
      );

      expect(response.intent, JagoIntent.payment);
      expect(response.answer, contains('₹42500'));
      expect(response.reason, contains('SIM-SBIN002938192026'));
      expect(response.toFormattedText(), contains('SIM-SBIN002938192026'));
      expect(response.source.portal, contains('dbttribal.gov.in'));
    });

    test('Unsupported question yields verified official disclaimer without hallucination', () {
      final response = ContextAwareScholarshipAssistant.process(
        query: 'Can you give me free train tickets to Mumbai?',
        context: studentWithActiveApp,
      );

      expect(response.intent, JagoIntent.generalHelp);
      expect(response.answer, contains('I do not have verified official information'));
      expect(response.answer, contains('0120-6619540'));
      expect(response.source.portal, contains('tribal.nic.in'));
    });

    test('Grievance draft is created without automatic submission', () {
      final response = ContextAwareScholarshipAssistant.process(
        query: 'Raise Grievance for delayed payment',
        context: studentWithActiveApp,
      );

      expect(response.intent, JagoIntent.grievance);
      expect(response.isGrievanceDraft, isTrue);
      expect(response.grievanceDraft, isNotNull);
      expect(response.grievanceDraft!['status'], 'DRAFT_ONLY_NOT_SUBMITTED');
      expect(response.actions.any((a) => a.isExternal), isTrue);
    });

    test('Voice text cleaner produces clean plaintext without markdown tokens', () {
      const markdown = '• Hello *Rahul*! Reason: Under verification. 🏛️ Source: tribal.nic.in';
      final cleanVoiceText = JagoLocalization.toVoiceSpeechText(markdown);
      expect(cleanVoiceText.contains('*'), isFalse);
      expect(cleanVoiceText.contains('•'), isFalse);
      expect(cleanVoiceText, contains('Hello Rahul'));
    });
  });
}
