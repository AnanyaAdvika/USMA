import 'jago_intent_and_context.dart';
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

  ComprehensiveStudentContext toComprehensive() {
    return ComprehensiveStudentContext(
      studentName: studentName,
      activeSchemeTitle: activeSchemeTitle,
      applicationStatus: applicationStatus,
      deficiencies: pendingActions,
      languageCode: languageCode,
    );
  }
}

abstract class JagoChatbot {
  Future<ChatMessageModel> answer({
    required String query,
    required JagoStudentContext context,
  });

  Future<ChatMessageModel> answerWithComprehensiveContext({
    required String query,
    required ComprehensiveStudentContext context,
  });
}
