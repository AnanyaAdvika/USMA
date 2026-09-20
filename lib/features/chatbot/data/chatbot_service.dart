import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failures.dart';
import '../../applications/data/applications_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/jago_chatbot.dart';
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
    final faq = await _loadFaq();
    final lower = query.toLowerCase();

    // 1. Contextual Student Questions
    if (lower.contains('eligible') && (lower.contains('post-matric') || lower.contains('post matric') || lower.contains('am i'))) {
      return ChatMessageModel.bot(
        'Based on your profile, you are eligible for Post-Matric Scholarship for ST Students (PMS-ST). Your family annual income is within the ₹2,50,000 ceiling and you are enrolled in a recognized Post-Matric course.\n\nSource: Ministry of Tribal Affairs (tribal.nic.in)',
        suggestions: const [
          'What documents are missing?',
          'How much money was disbursed?',
          'Application status',
        ],
      );
    }

    if (lower.contains('document') && (lower.contains('missing') || lower.contains('need') || lower.contains('require'))) {
      if (context.pendingActions.isNotEmpty) {
        return ChatMessageModel.bot(
          'Action Required on your profile:\n• ${context.pendingActions.join('\n• ')}\n\nPlease visit the DigiLocker Document Vault to resolve these items before the deadline.\n\nSource: Ministry of Tribal Affairs',
          suggestions: const [
            'How do I upload to DigiLocker?',
            'Application status',
            'When was my scholarship sanctioned?',
          ],
        );
      } else {
        return ChatMessageModel.bot(
          'All your core documents (Aadhaar, ST Certificate, Income Certificate, Marksheet) are verified with zero pending deficiencies!\n\nSource: Ministry of Tribal Affairs',
          suggestions: const [
            'When was my scholarship sanctioned?',
            'How much money was disbursed?',
          ],
        );
      }
    }

    if (lower.contains('sanction') || lower.contains('when') && lower.contains('sanctioned')) {
      return ChatMessageModel.bot(
        'Your scholarship application (${context.activeSchemeTitle ?? "Post-Matric ST"}) was officially sanctioned on 18th March 2026 for ₹85,000 under MoTA Sanction Order #MOTA/2026/ST-8821.\n\nSource: Ministry of Tribal Affairs (tribal.nic.in)',
        suggestions: const [
          'How much money was disbursed?',
          'Why is my application pending?',
        ],
      );
    }

    if (lower.contains('disburs') || lower.contains('money') || lower.contains('paid') || lower.contains('how much')) {
      return ChatMessageModel.bot(
        'Direct Benefit Transfer (DBT) Status:\n• Installment 1: ₹42,500 successfully credited (UTR: SIM-SBIN002938192026).\n• Installment 2: ₹42,500 processing queued on PFMS.\n\nSource: Ministry of Tribal Affairs (PFMS DBT)',
        suggestions: const [
          'What should I do about my income certificate?',
          'Application status',
        ],
      );
    }

    if (lower.contains('income certificate') || lower.contains('certificate')) {
      return ChatMessageModel.bot(
        'Your Annual Income Certificate has a name abbreviation variance ("Sunita M." vs "Sunita Marandi"). It has been routed for manual officer review and does not block your payment.\n\nSource: Ministry of Tribal Affairs',
        suggestions: const [
          'Application status',
          'Which scholarship applies to my current education level?',
        ],
      );
    }

    if (lower.contains('which scholarship') || lower.contains('education level')) {
      return ChatMessageModel.bot(
        'For your current education level (College / Higher Education), the following MoTA schemes apply:\n1. Post-Matric Scholarship for ST Students (PMS-ST)\n2. Top Class Scholarship (if in one of 265 notified premier institutes like IIT/NIT)\n\nSource: Ministry of Tribal Affairs',
        suggestions: const [
          'Am I eligible for Post-Matric scholarship?',
          'What documents are missing?',
        ],
      );
    }

    final milestone = _milestoneAlert(context);
    if (lower.contains('status') ||
        lower.contains('milestone') ||
        lower.contains('स्थिति') ||
        lower.contains('pending') ||
        lower.contains('why is my application pending')) {
      return ChatMessageModel.bot(
        '${AppConfig.simulatedLabel} JAGO Status Update:\n$milestone\n\nYour application is in the Sanctioned stage and awaiting final PFMS DBT clearance.\n\nSource: Ministry of Tribal Affairs',
        suggestions: const [
          'What documents are missing?',
          'How much money was disbursed?',
        ],
      );
    }

    // 2. FAQ Keyword search
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

    if (best == null || bestScore == 0) {
      return ChatMessageModel.bot(
        "I don't have verified information for this question. Please check the official Ministry of Tribal Affairs source (https://tribal.nic.in/ScholarshiP.aspx) or contact the helpline at 0120-6619540.",
        suggestions: const [
          'Am I eligible for Post-Matric scholarship?',
          'What documents are missing?',
          'When was my scholarship sanctioned?',
          'How much money was disbursed?',
        ],
      );
    }

    return ChatMessageModel.bot(
      '${best.answer}\n\nSource: Ministry of Tribal Affairs (tribal.nic.in)',
      suggestions: const [
        'Application status',
        'Can I hold two scholarships?',
        'How does DigiLocker work?',
      ],
    );
  }

  String _milestoneAlert(JagoStudentContext context) {
    final pending = context.pendingActions.isEmpty
        ? 'No open deficiencies.'
        : 'Pending actions: ${context.pendingActions.join('; ')}';
    return 'Hello ${context.studentName}. '
        'Scheme: ${context.activeSchemeTitle ?? 'Post-Matric ST'}. '
        'Stage: ${context.applicationStatus ?? 'Sanctioned'}. $pending';
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
                ? '${AppConfig.simulatedLabel} JAGO: student-specific help for ${_context.studentName}. Ask about schemes, tracking, documents, or DBT.'
                : 'JAGO is available only through the live USMA backend.',
            suggestions: const [
              'Application status',
              'Which scholarships can I apply for?',
              'What documents do I need?',
              'Can I hold two scholarships?',
            ],
          ),
        ]);

  final JagoChatbot _bot;
  final JagoStudentContext _context;

  Future<void> sendMessage(String text) async {
    state = [...state, ChatMessageModel.user(text)];
    try {
      final reply = await _bot.answer(query: text, context: _context);
      state = [...state, reply];
    } on Failure catch (failure) {
      state = [...state, ChatMessageModel.bot(failure.message)];
    }
  }

  void clearChat() {
    state = [
      ChatMessageModel.bot(
        '${AppConfig.simulatedLabel} JAGO reset for ${_context.studentName}.',
        suggestions: const [
          'Application status',
          'What documents do I need?',
        ],
      ),
    ];
  }
}

final chatMessagesProvider =
    StateNotifierProvider<ChatbotNotifier, List<ChatMessageModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final apps = ref.watch(userApplicationsProvider).asData?.value ?? const [];
  final active = apps.where((a) => a.isActive).toList();
  final context = JagoStudentContext(
    studentName: user?.name ?? 'Student',
    activeSchemeTitle: active.isEmpty ? null : active.first.schemeTitle,
    applicationStatus: active.isEmpty ? null : active.first.status,
    pendingActions: [
      for (final app in active) ...app.deficiencies,
    ],
  );
  return ChatbotNotifier(ref.watch(jagoChatbotProvider), context);
});
