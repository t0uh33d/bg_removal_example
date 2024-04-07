import 'generated/app_localization.dart';
import 'package:flutter/material.dart' show BuildContext, Localizations;

class AppStrings {
  static final AppStrings _appStrings = AppStrings._i();

  AppStrings._i();

  factory AppStrings() => _appStrings;

  // Static method to be used with LocalizationsDelegate
  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization)!;
  }

  static AppStrings ofUntranslated(BuildContext context) {
    return _appStrings;
  }

  // default language data
  String defaultLanugageName = 'English';

  String defaultLanguageCode = 'en';

  // define app strings from here

}
