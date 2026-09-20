import '../jago_intent_and_context.dart';

enum MessageSender { user, bot }

class ChatMessageModel {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<String>? suggestions;
  final JagoStructuredResponse? structuredResponse;
  final List<JagoAction>? actions;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.suggestions,
    this.structuredResponse,
    this.actions,
  });

  factory ChatMessageModel.user(String text) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessageModel.bot(
    String text, {
    List<String>? suggestions,
    JagoStructuredResponse? structuredResponse,
    List<JagoAction>? actions,
  }) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
      suggestions: suggestions,
      structuredResponse: structuredResponse,
      actions: actions,
    );
  }
}
