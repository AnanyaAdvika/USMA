import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/tokens.dart';
import '../data/chatbot_service.dart';
import '../domain/models/chat_message_model.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _inputController.text.trim();
    if (text.isEmpty) return;

    if (presetText == null) _inputController.clear();

    ref.read(chatMessagesProvider.notifier).sendMessage(text);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
            ),
            SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MoTA Saathi AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Multilingual Scholarship Assistant', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: messages.length,
              itemBuilder: (context, idx) {
                final msg = messages[idx];
                final isUser = msg.sender == MessageSender.user;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser) ...[
                            const CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              radius: 14,
                              child: Icon(Icons.smart_toy, size: 14, color: Colors.black),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                              decoration: BoxDecoration(
                                color: isUser ? AppColors.primary : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(
                                  color: isUser ? Colors.white : AppColors.textPrimary,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isUser && msg.suggestions != null && msg.suggestions!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: 4,
                          children: msg.suggestions!
                              .map(
                                (sug) => ActionChip(
                                  label: Text(sug, style: const TextStyle(fontSize: 11)),
                                  onPressed: () => _sendMessage(sug),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Ask MoTA Saathi (English, हिन्दी, ਓਡੀਆ)...',
                      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  onPressed: () => _sendMessage(),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
