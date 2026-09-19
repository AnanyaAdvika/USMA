import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../domain/models/chat_message_model.dart';

// =========================================================================
// ⚠️ GEMINI API KEY CONFIGURATION ⚠️
// Pass via --dart-define=GEMINI_API_KEY=your_key at build/run time,
// or provide a local uncommitted configuration.
// =========================================================================
const String geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);

class ChatbotService {
  late GenerativeModel _model;
  late ChatSession _chat;
  String _faqContext = '';
  bool _isInitialized = false;

  ChatbotService() {
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      // Load FAQ JSON to provide context to Gemini
      final jsonString = await rootBundle.loadString('assets/faq/faq.json');
      final list = json.decode(jsonString) as List<dynamic>;
      
      _faqContext = list.map((e) => 'Q: ${e['question']}\nA: ${e['answer']}').join('\n\n');

      final systemInstruction = '''
You are MoTA Saathi, an intelligent and friendly AI assistant for the Ministry of Tribal Affairs (MoTA) scholarship platform called USMA.
Your goal is to guide Scheduled Tribe (ST) students in India regarding scholarships.
You must be polite, encouraging, and clear.
Use the following FAQ data as your source of truth for any scholarship details. Do NOT make up information about schemes.
If the user asks a question not covered by the context, guide them to contact the MoTA helpline.

FAQ CONTEXT:
$_faqContext
''';

      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: geminiApiKey,
        systemInstruction: Content.system(systemInstruction),
      );
      
      _chat = _model.startChat();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing Gemini model: $e');
    }
  }

  Future<ChatMessageModel> answerQuestion(String query) async {
    if (geminiApiKey == 'YOUR_API_KEY_HERE' || geminiApiKey.isEmpty) {
      return ChatMessageModel.bot(
        '⚠️ **API Key Missing!**\n\nPlease add your Gemini API key in `lib/features/chatbot/data/chatbot_service.dart` to enable intelligent conversations.',
      );
    }

    if (!_isInitialized) {
      await _initializeModel();
    }

    try {
      final response = await _chat.sendMessage(Content.text(query));
      final replyText = response.text ?? 'I apologize, but I am unable to process that request right now.';
      
      // Determine some default suggestions based on the query, to keep the UI interactive
      List<String> suggestions = [];
      final lower = query.toLowerCase();
      if (lower.contains('income') || lower.contains('eligibility')) {
        suggestions = ['What documents are required?', 'How to apply?'];
      } else if (lower.contains('document') || lower.contains('certificate')) {
        suggestions = ['How to upload?', 'Income certificate limits'];
      } else {
        suggestions = ['Check my eligibility', 'Track application status', 'List of schemes'];
      }

      return ChatMessageModel.bot(replyText, suggestions: suggestions);
    } catch (e) {
      return ChatMessageModel.bot(
        'Sorry, I am having trouble connecting to my AI brain right now. Please check your internet connection or try again later.',
      );
    }
  }

  void resetChatSession() {
    if (_isInitialized) {
      _chat = _model.startChat();
    }
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
            'Johar & Namaste! 🙏 I am MoTA Saathi, your AI assistant powered by Gemini. I can answer any questions about Ministry of Tribal Affairs scholarships based on our official dataset. How can I help you today?',
            suggestions: [
              'Which scholarships can I apply for?',
              'What documents do I need?',
              'How does DBT PFMS payment work?',
              'Income criteria for scholarships',
            ],
          ),
        ]);

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessageModel.user(text);
    state = [...state, userMsg];

    final botReply = await _service.answerQuestion(text);
    state = [...state, botReply];
  }

  void clearChat() {
    _service.resetChatSession();
    state = [
      ChatMessageModel.bot(
        'Johar & Namaste! 🙏 I am MoTA Saathi, your AI assistant powered by Gemini. I can answer any questions about Ministry of Tribal Affairs scholarships based on our official dataset. How can I help you today?',
        suggestions: [
          'Which scholarships can I apply for?',
          'What documents do I need?',
          'How does DBT PFMS payment work?',
          'Income criteria for scholarships',
        ],
      ),
    ];
  }
}

final chatMessagesProvider = StateNotifierProvider<ChatbotNotifier, List<ChatMessageModel>>((ref) {
  return ChatbotNotifier(ref.watch(chatbotServiceProvider));
});
