enum MessageSender { user, bot }

class ChatMessageModel {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<String>? suggestions;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.suggestions,
  });

  factory ChatMessageModel.user(String text) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessageModel.bot(String text, {List<String>? suggestions}) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
      suggestions: suggestions,
    );
  }
}
