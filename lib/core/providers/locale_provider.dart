import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jahitin_mobile/core/constants/storage_keys.dart';
import 'package:jahitin_mobile/core/services/storage_service.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    return const Locale('en', 'US');
  }

  void setLocale(Locale newLocale) {
    state = newLocale;
    final storage = ref.read(storageServiceProvider);
    final langCode = newLocale.languageCode == 'id' || newLocale.languageCode == 'in'
        ? StorageLanguage.id
        : StorageLanguage.en;
    storage.setLanguage(langCode);
  }

  void updateFromLanguageCode(String langCode) {
    if (langCode == StorageLanguage.id || langCode == 'in') {
      state = const Locale('id', 'ID');
    } else {
      state = const Locale('en', 'US');
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
