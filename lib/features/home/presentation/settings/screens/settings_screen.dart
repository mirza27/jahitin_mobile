import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/localization/app_localizations_ext.dart';
import '../../../../../core/providers/locale_provider.dart';
import '../../../../splash/screens/splash_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          context.tr('settings'),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, context.tr('language')),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildLanguageTile(
                  context: context,
                  ref: ref,
                  title: context.tr('language_indonesia'),
                  locale: const Locale('id', 'ID'),
                  currentLocale: currentLocale,
                ),
                const Divider(height: 1, color: AppColors.divider),
                _buildLanguageTile(
                  context: context,
                  ref: ref,
                  title: context.tr('language_english'),
                  locale: const Locale('en', 'US'),
                  currentLocale: currentLocale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required Locale locale,
    required Locale currentLocale,
  }) {
    final isSelected = currentLocale.languageCode == locale.languageCode;

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary, size: 22)
          : const Icon(Icons.circle_outlined, color: AppColors.textHint, size: 22),
      onTap: () {
        if (!isSelected) {
          _showLanguageChangeDialog(context, ref, locale);
        }
      },
    );
  }

  void _showLanguageChangeDialog(
    BuildContext context,
    WidgetRef ref,
    Locale newLocale,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            context.tr('language_change_title'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            context.tr('language_change_body'),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                context.tr('language_change_cancel'),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(localeProvider.notifier).setLocale(newLocale);
                // Navigasi ke SplashScreen untuk memuat ulang aplikasi
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const SplashScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                context.tr('language_change_confirm'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
