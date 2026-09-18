import 'package:flutter/material.dart';
import 'app_localizations.dart';

extension LocalizationExtension on BuildContext {
  String tr(String key, {Map<String, String>? params}) {
    return AppLocalizations.of(this).translate(key, params: params);
  }
}
