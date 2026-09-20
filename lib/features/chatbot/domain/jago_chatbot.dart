import 'models/chat_message_model.dart';

class JagoStudentContext {
  final String studentName;
  final String? activeSchemeTitle;
  final String? applicationStatus;
  final List<String> pendingActions;
  final String languageCode;

  const JagoStudentContext({
    required this.studentName,
    this.activeSchemeTitle,
    this.applicationStatus,
    this.pendingActions = const [],
    this.languageCode = 'en',
  });
}

abstract class JagoChatbot {
  Future<ChatMessageModel> answer({
    required String query,
    required JagoStudentContext context,
  });
}
