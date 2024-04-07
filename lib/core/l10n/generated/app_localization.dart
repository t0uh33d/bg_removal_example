import 'package:bg_removal_app/core/l10n/app_strings.dart';

abstract class AppLocalization {
  static void updateLanguage(Language language) {}
}

enum Language {
  defaultLanguage;

  // getCode stub
  String getCode() => AppStrings().defaultLanguageCode;

  static Language getLanguageFromCode({required String code}) {
    return Language.defaultLanguage;
  }
}
