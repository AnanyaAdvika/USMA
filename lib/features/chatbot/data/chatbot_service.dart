import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failures.dart';
import '../../applications/data/applications_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/context_aware_scholarship_assistant.dart';
import '../domain/jago_chatbot.dart';
import '../domain/jago_intent_and_context.dart';
import '../domain/models/chat_message_model.dart';

class FaqEntry {
  final String question;
  final String answer;
  final List<String> keywords;

  const FaqEntry({
    required this.question,
    required this.answer,
    required this.keywords,
  });
}

class MockJagoChatbot implements JagoChatbot {
  MockJagoChatbot({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  List<FaqEntry>? _faq;

  Future<List<FaqEntry>> _loadFaq() async {
    if (_faq != null) return _faq!;
    try {
      final raw = await _bundle.loadString('assets/faq/faq.json');
      final list = json.decode(raw);
      if (list is! List) {
        throw const ParseFailure('FAQ file must be a JSON list.');
      }
      _faq = list.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        return FaqEntry(
          question: map['question']?.toString() ?? '',
          answer: map['answer']?.toString() ?? '',
          keywords: List<String>.from(map['keywords'] ?? const []),
        );
      }).toList();
      return _faq!;
    } on Failure {
      rethrow;
    } on FormatException catch (e) {
      throw ParseFailure('FAQ JSON is invalid: ${e.message}');
    }
  }

  @override
  Future<ChatMessageModel> answer({
    required String query,
    required JagoStudentContext context,
  }) async {
    return answerWithComprehensiveContext(
      query: query,
      context: context.toComprehensive(),
    );
  }

  @override
  Future<ChatMessageModel> answerWithComprehensiveContext({
    required String query,
    required ComprehensiveStudentContext context,
  }) async {
    // 1. Process via Context-Aware Scholarship Assistant Engine
    final structuredResponse = ContextAwareScholarshipAssistant.process(
      query: query,
      context: context,
    );

    // 2. If general help fallback triggered, check if exact FAQ match exists in official FAQ database
    if (structuredResponse.intent == JagoIntent.generalHelp) {
      final faq = await _loadFaq();
      final lower = query.toLowerCase();

      FaqEntry? best;
      var bestScore = 0;
      for (final entry in faq) {
        var score = 0;
        for (final key in entry.keywords) {
          if (lower.contains(key.toLowerCase())) score += 2;
        }
        if (lower.contains(entry.question.toLowerCase().split(' ').first)) {
          score += 1;
        }
        if (score > bestScore) {
          bestScore = score;
          best = entry;
        }
      }

      if (best != null && bestScore >= 2) {
        return ChatMessageModel.bot(
          '${best.answer}\n\n🏛️ Source: Ministry of Tribal Affairs (tribal.nic.in)',
          suggestions: const [
            'Check Eligibility',
            'Track Application',
            'Check Documents',
            'Track Payment',
          ],
          structuredResponse: JagoStructuredResponse(
            intent: JagoIntent.schemeInformation,
            answer: best.answer,
            reason: 'Official statutory MoTA FAQ database record matched.',
            currentStatus: 'Verified MoTA Information',
            requiredAction: 'Review official guidelines on portal.',
            source: JagoSource.motaPortal,
            actions: const [
              JagoAction(label: 'View Schemes', route: '/schemes'),
            ],
            suggestions: const [
              'Check Eligibility',
              'Track Application',
            ],
          ),
          actions: const [
            JagoAction(label: 'View Schemes', route: '/schemes'),
          ],
        );
      }
    }

    // 3. Return canonical structured response
    final formatted = structuredResponse.toFormattedText();
    return ChatMessageModel.bot(
      formatted,
      suggestions: structuredResponse.suggestions.isNotEmpty
          ? structuredResponse.suggestions
          : const [
              'Check Eligibility',
              'Track Application',
              'Check Documents',
              'Track Payment',
            ],
      structuredResponse: structuredResponse,
      actions: structuredResponse.actions,
    );
  }
}

class LiveJagoChatbot implements JagoChatbot {
  @override
  Future<ChatMessageModel> answer({
    required String query,
    required JagoStudentContext context,
  }) async {
    throw const IntegrationFailure(
      'JAGO is not a public client API. Connect it through the USMA backend — this app does not invent a government chatbot endpoint.',
    );
  }

  @override
  Future<ChatMessageModel> answerWithComprehensiveContext({
    required String query,
    required ComprehensiveStudentContext context,
  }) async {
    throw const IntegrationFailure(
      'JAGO is not a public client API. Connect it through the USMA backend — this app does not invent a government chatbot endpoint.',
    );
  }
}

final jagoChatbotProvider = Provider<JagoChatbot>((ref) {
  if (AppConfig.isDemo) return MockJagoChatbot();
  return LiveJagoChatbot();
});

class ChatbotNotifier extends StateNotifier<List<ChatMessageModel>> {
  ChatbotNotifier(this._bot, this._context)
      : super([
          ChatMessageModel.bot(
            AppConfig.isDemo
                ? '${AppConfig.simulatedLabel} JAGO Context-Aware Assistant for ${_context.studentName}.\n\nI answer queries using your verified profile data and official Ministry of Tribal Affairs (MoTA) guidelines.'
                : 'JAGO is available only through the live USMA backend.',
            suggestions: const [
              'Am I eligible for Post-Matric?',
              'What documents are missing?',
              'Why is my application pending?',
              'Has my scholarship been sanctioned?',
              'When was my last payment?',
              'How do I raise a grievance?',
            ],
          ),
        ]);

  final JagoChatbot _bot;
  final ComprehensiveStudentContext _context;

  Future<void> sendMessage(String text) async {
    state = [...state, ChatMessageModel.user(text)];
    try {
      final reply = await _bot.answerWithComprehensiveContext(
        query: text,
        context: _context,
      );
      state = [...state, reply];
    } on Failure catch (failure) {
      state = [...state, ChatMessageModel.bot(failure.message)];
    }
  }

  void clearChat() {
    state = [
      ChatMessageModel.bot(
        '${AppConfig.simulatedLabel} JAGO conversation reset for ${_context.studentName}.',
        suggestions: const [
          'Am I eligible for Post-Matric?',
          'What documents are missing?',
          'Track Application',
          'Track Payment',
        ],
      ),
    ];
  }
}

final comprehensiveStudentContextProvider = Provider<ComprehensiveStudentContext>((ref) {
  final user = ref.watch(currentUserProvider);
  final apps = ref.watch(userApplicationsProvider).asData?.value ?? const [];
  final active = apps.where((a) => a.isActive).toList();

  final activeApp = active.isNotEmpty ? active.first : null;

  return ComprehensiveStudentContext(
    studentName: user?.name ?? 'Rahul Kumar',
    studentId: user?.id ?? 'ST-2026-8819',
    socialCategory: (user?.isScheduledTribe ?? true) ? 'ST' : 'GENERAL',
    isPvtg: false,
    annualFamilyIncome: user?.familyAnnualIncome ?? 180000.0,
    educationLevel: user?.educationLevel ?? 'Higher Education / Degree',
    currentCourse: 'B.Tech Computer Science',
    institutionName: activeApp?.instituteName ?? 'Govt. College of Engineering, Keonjhar',
    activeSchemeId: activeApp?.schemeId ?? 'post_matric_st',
    activeSchemeTitle: activeApp?.schemeTitle ?? 'Post-Matric Scholarship for ST Students (PMS-ST)',
    applicationStatus: activeApp?.status ?? 'submitted',
    verificationStatus: activeApp?.manualReviewRequired == true
        ? 'MISMATCH_DETECTED'
        : 'INSTITUTE_PENDING',
    missingDocuments: const [],
    deficiencies: activeApp != null ? activeApp.deficiencies : const [],
    paymentStatus: 'SUCCESS',
    lastDisbursedAmount: 42500.0,
    lastPaymentUtr: 'SIM-SBIN002938192026',
    lastPaymentDate: DateTime(2026, 3, 18),
    sanctionOrderNumber: 'MOTA/2026/ST-8821',
    sanctionedAmount: 85000.0,
    sanctionDate: DateTime(2026, 3, 15),
    languageCode: 'en',
    isSimulatedData: true,
  );
});

final chatMessagesProvider =
    StateNotifierProvider<ChatbotNotifier, List<ChatMessageModel>>((ref) {
  final context = ref.watch(comprehensiveStudentContextProvider);
  final bot = ref.watch(jagoChatbotProvider);
  return ChatbotNotifier(bot, context);
});
