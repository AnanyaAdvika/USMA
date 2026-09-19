import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/tokens.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final languageProvider = StateProvider<String>((ref) => 'English');

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const List<String> _languages = [
    'English',
    'हिन्दी (Hindi)',
    'ਓਡੀਆ (Odia)',
    'ᱥᱟᱱᱛᱟᱲᱤ (Santhali)',
    'తెలుగు (Telugu)',
    'বাংলা (Bengali)',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Text('Accessibility & Language', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language_rounded, color: AppColors.primary),
              title: const Text('App Display Language'),
              subtitle: Text(currentLang),
              trailing: DropdownButton<String>(
                value: currentLang,
                underline: const SizedBox.shrink(),
                items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (val) {
                  if (val != null) ref.read(languageProvider.notifier).state = val;
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
              title: const Text('Dark Mode'),
              subtitle: const Text('Reduce glare in low-light conditions'),
              value: currentTheme == ThemeMode.dark,
              onChanged: (isDark) {
                ref.read(themeModeProvider.notifier).state = isDark ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const Text('About Ministry Portal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: AppSpacing.sm),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: AppColors.textSecondary),
                  title: Text('Application Version'),
                  subtitle: Text('USMA v1.0.0+1 (Ministry Production Build)'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.gavel_rounded, color: AppColors.textSecondary),
                  title: Text('Terms & Ministry Guidelines'),
                  subtitle: Text('Ministry of Tribal Affairs • Government of India'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
