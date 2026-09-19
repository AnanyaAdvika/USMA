import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/chat_message_model.dart';

class ChatbotService {
  List<Map<String, dynamic>> _faqs = [];

  ChatbotService() {
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    try {
      final jsonString = await rootBundle.loadString('assets/faq/faq.json');
      final list = json.decode(jsonString) as List<dynamic>;
      _faqs = list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {}
  }

  Future<ChatMessageModel> answerQuestion(String query) async {
    if (_faqs.isEmpty) {
      await _loadFaqs();
    }

    final lower = query.toLowerCase().trim();

    // Greeting
    if (lower.contains('hi') || lower.contains('hello') || lower.contains('namaste') || lower.contains('johar')) {
      return ChatMessageModel.bot(
        'Johar & Namaste! 🙏 I am MoTA Saathi, your AI assistant for Ministry of Tribal Affairs scholarships. How can I help you today?',
        suggestions: [
          'Which scholarships can I apply for?',
          'How does DBT payment work?',
          'What documents do I need from DigiLocker?',
          'Check my application status',
        ],
      );
    }

    // Match FAQ
    for (final faq in _faqs) {
      final keywords = List<String>.from(faq['keywords'] ?? []);
      final question = (faq['question'] as String? ?? '').toLowerCase();
      
      bool matched = false;
      if (question.contains(lower) || lower.contains(question)) {
        matched = true;
      } else {
        int hitCount = 0;
        for (final kw in keywords) {
          if (lower.contains(kw.toLowerCase())) {
            hitCount++;
          }
        }
        if (hitCount >= 2 || (keywords.length == 1 && hitCount == 1)) {
          matched = true;
        }
      }

      if (matched) {
        return ChatMessageModel.bot(
          faq['answer'] as String? ?? '',
          suggestions: [
            'Can I apply for more than one scholarship?',
            'What is DigiLocker integration?',
            'How is money disbursed via PFMS?',
          ],
        );
      }
    }

    // Default intelligent response
    return ChatMessageModel.bot(
      'Regarding "$query": MoTA scholarships (PMS-ST, Pre-Matric, Top Class, NFST, and NOS) require an ST certificate and income eligibility under ₹2.5 Lakhs (or ₹6 Lakhs for Top Class/NFST). For specific status checks, please visit the Applications or Disbursements tab.',
      suggestions: [
        'What documents do I need?',
        'How do I link DigiLocker?',
        'Check DBT payment status',
      ],
    );
  }
}

final chatbotServiceProvider = Provider<ChatbotService>((ref) {
  return ChatbotService();
});

class ChatbotNotifier extends StateNotifier<List<ChatMessageModel>> {
  final ChatbotService _service;

  ChatbotNotifier(this._service)
      : super([
          ChatMessageModel.bot(
            'Johar! I am MoTA Saathi, your scholarship assistant. How can I assist you today?',
            suggestions: [
              'What scholarships does MoTA offer?',
              'What documents do I need?',
              'How to check DBT PFMS status?',
            ],
          ),
        ]);

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessageModel.user(text);
    state = [...state, userMsg];

    final botReply = await _service.answerQuestion(text);
    state = [...state, botReply];
  }
}

final chatMessagesProvider = StateNotifierProvider<ChatbotNotifier, List<ChatMessageModel>>((ref) {
  return ChatbotNotifier(ref.watch(chatbotServiceProvider));
});
