import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en', 'US'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString;
    try {
      jsonString = await rootBundle.loadString(
        'assets/translations/${locale.languageCode}.json',
      );
    } catch (_) {
      jsonString = await rootBundle.loadString('assets/translations/en.json');
    }

    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key, {Map<String, String>? params}) {
    String text = _localizedStrings[key] ?? key;
    if (params != null && params.isNotEmpty) {
      params.forEach((paramKey, paramValue) {
        text = text.replaceAll('{$paramKey}', paramValue);
      });
    }
    return text;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'id', 'in'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final normalizedLanguageCode =
        (locale.languageCode == 'in') ? 'id' : locale.languageCode;
    final appLocalizations = AppLocalizations(Locale(normalizedLanguageCode));
    await appLocalizations.load();
    return appLocalizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
