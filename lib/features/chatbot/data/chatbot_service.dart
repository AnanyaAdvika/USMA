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

    final milestone = _milestoneAlert(context);
    if (lower.contains('status') ||
        lower.contains('milestone') ||
        lower.contains('स्थिति') ||
        lower.contains('alert')) {
      return ChatMessageModel.bot(
        '${AppConfig.simulatedLabel} JAGO\n$milestone',
        suggestions: const [
          'What documents do I need?',
          'Can I hold two scholarships?',
        ],
      );
    }

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

    final preface = [
      '${AppConfig.simulatedLabel} JAGO for ${context.studentName}',
      if (context.activeSchemeTitle != null)
        'Active scheme: ${context.activeSchemeTitle} (${context.applicationStatus ?? 'n/a'}).',
      if (context.pendingActions.isNotEmpty)
        'Pending: ${context.pendingActions.join('; ')}',
    ].join('\n');

    if (best == null || bestScore == 0) {
      return ChatMessageModel.bot(
        '$preface\nI do not have a matching FAQ. Ask about schemes, documents, DBT, or deficiency.',
        suggestions: const [
          'Which scholarships can I apply for?',
          'What documents are required?',
          'Application status',
        ],
      );
    }

    return ChatMessageModel.bot(
      '$preface\n\n${best.answer}',
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
        'Scheme: ${context.activeSchemeTitle ?? 'none'}. '
        'Stage: ${context.applicationStatus ?? 'none'}. $pending';
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
