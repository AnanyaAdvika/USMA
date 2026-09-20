// ============================================================
// USMA — JAGO Scholarship Assistance System
// chatbot_screen.dart
//
// Context-Aware UI displaying:
// - Structured Answer / Reason / Status / Required Action / Source
// - Actionable Quick Buttons ([View Application], [Check Documents], etc.)
// - Draft Grievance Card with explicit submit safety guard
// - Voice-Ready Mock Dictation bar
// - Language Switcher (English, हिन्दी, ਓଡିଆ)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/tokens.dart';
import '../data/chatbot_service.dart';
import '../domain/jago_intent_and_context.dart';
import '../domain/jago_localization.dart';
import '../domain/models/chat_message_model.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  String _selectedLanguage = JagoLocalization.langEnglish;
  bool _isListeningVoice = false;

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

  void _simulateVoiceInput() {
    setState(() => _isListeningVoice = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.mic, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _selectedLanguage == JagoLocalization.langHindi
                  ? 'आवाज़ रिकॉर्डिंग सक्रिय... (डेमो)'
                  : 'Voice Dictation Active... (Speech-to-Text Demo)',
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isListeningVoice = false);
        _sendMessage('Why haven\'t I received my scholarship?');
      }
    });
  }

  void _handleAction(JagoAction action) async {
    if (action.isExternal) {
      final uri = Uri.parse(action.route);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      context.push(action.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 16,
              child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    JagoLocalization.get('app_title', lang: _selectedLanguage),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    JagoLocalization.get('subtitle', lang: _selectedLanguage),
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Language selector
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLanguage,
              icon: const Icon(Icons.language, size: 20, color: AppColors.primary),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(fontSize: 12))),
                DropdownMenuItem(value: 'hi', child: Text('हिन्दी', style: TextStyle(fontSize: 12))),
                DropdownMenuItem(value: 'or', child: Text('ଓଡ଼ିଆ', style: TextStyle(fontSize: 12))),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedLanguage = val);
              },
            ),
          ),
          IconButton(
            tooltip: 'Restart Conversation',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(chatMessagesProvider.notifier).clearChat();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Demo Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
            color: Colors.amber.shade100,
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.amber.shade900),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    JagoLocalization.get('disclaimer', lang: _selectedLanguage),
                    style: TextStyle(fontSize: 10, color: Colors.amber.shade900, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Quick Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
            color: AppColors.surfaceVariant.withValues(alpha: 0.5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickChip(
                    label: JagoLocalization.get('check_eligibility', lang: _selectedLanguage),
                    icon: Icons.fact_check_outlined,
                    onTap: () => _sendMessage('Am I eligible for Post-Matric?'),
                  ),
                  _QuickChip(
                    label: JagoLocalization.get('track_application', lang: _selectedLanguage),
                    icon: Icons.track_changes_outlined,
                    onTap: () => _sendMessage('Why is my application pending?'),
                  ),
                  _QuickChip(
                    label: JagoLocalization.get('check_documents', lang: _selectedLanguage),
                    icon: Icons.description_outlined,
                    onTap: () => _sendMessage('What documents are missing?'),
                  ),
                  _QuickChip(
                    label: JagoLocalization.get('track_payment', lang: _selectedLanguage),
                    icon: Icons.currency_rupee,
                    onTap: () => _sendMessage('When was my last payment?'),
                  ),
                  _QuickChip(
                    label: JagoLocalization.get('view_schemes', lang: _selectedLanguage),
                    icon: Icons.account_balance_outlined,
                    onTap: () => _sendMessage('Which official scholarship schemes are covered under MoTA?'),
                  ),
                  _QuickChip(
                    label: JagoLocalization.get('raise_grievance', lang: _selectedLanguage),
                    icon: Icons.report_problem_outlined,
                    onTap: () => _sendMessage('How do I raise a grievance?'),
                  ),
                ],
              ),
            ),
          ),

          // Chat message list
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
                                border: isUser
                                    ? null
                                    : Border.all(color: Colors.grey.shade300, width: 0.8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: isUser ? Colors.white : AppColors.textPrimary,
                                      fontSize: 13.5,
                                      height: 1.45,
                                    ),
                                  ),

                                  // Grievance Draft Card if applicable
                                  if (!isUser && msg.structuredResponse?.isGrievanceDraft == true) ...[
                                    const SizedBox(height: AppSpacing.sm),
                                    _GrievanceDraftCard(
                                      draft: msg.structuredResponse!.grievanceDraft!,
                                      lang: _selectedLanguage,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Actionable Response Buttons (Rule #3: [View Application], [Contact Institute], etc.)
                      if (!isUser && msg.actions != null && msg.actions!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 36.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: msg.actions!.map((act) {
                              return ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: const Size(0, 30),
                                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                icon: Icon(
                                  act.isExternal ? Icons.open_in_new : Icons.arrow_forward,
                                  size: 13,
                                ),
                                label: Text(act.label),
                                onPressed: () => _handleAction(act),
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      // Suggestion Chips
                      if (!isUser && msg.suggestions != null && msg.suggestions!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Padding(
                          padding: const EdgeInsets.only(left: 36.0),
                          child: Wrap(
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
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Input Bar with Voice Support
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.surface,
            child: Row(
              children: [
                // Voice button
                IconButton(
                  tooltip: JagoLocalization.get('voice_hint', lang: _selectedLanguage),
                  icon: Icon(
                    _isListeningVoice ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isListeningVoice ? Colors.red : AppColors.primary,
                  ),
                  onPressed: _simulateVoiceInput,
                ),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: JagoLocalization.get('input_hint', lang: _selectedLanguage),
                      hintStyle: const TextStyle(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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

class _QuickChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: ActionChip(
        avatar: Icon(icon, size: 14, color: AppColors.primary),
        label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        onPressed: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

class _GrievanceDraftCard extends StatelessWidget {
  final Map<String, dynamic> draft;
  final String lang;

  const _GrievanceDraftCard({
    required this.draft,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, size: 16, color: Colors.orange.shade800),
              const SizedBox(width: 4),
              Text(
                JagoLocalization.get('draft_summary', lang: lang),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
              ),
            ],
          ),
          const Divider(height: 12),
          _GrievanceRow(label: JagoLocalization.get('category', lang: lang), value: draft['category'] ?? ''),
          _GrievanceRow(label: JagoLocalization.get('scheme', lang: lang), value: draft['scheme'] ?? ''),
          _GrievanceRow(label: 'App ID', value: draft['applicationId'] ?? ''),
          _GrievanceRow(label: JagoLocalization.get('description', lang: lang), value: draft['description'] ?? ''),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              JagoLocalization.get('submit_disabled', lang: lang),
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrievanceRow extends StatelessWidget {
  final String label;
  final String value;

  const _GrievanceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text('$label:', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
