import 'dart:io' show Directory;

import 'package:cw_core/cw_core.dart';
import '/router/app_router.dart';
import '/services/API/response_codes.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

import '../l10n/generated/app_localization.dart' show Language, AppLocalization;
import '../themes/app_theme.dart';
import '../themes/theme_handler.dart';
import 'package:flutter/foundation.dart'
    show ChangeNotifier, kDebugMode, kIsWeb;

/// [AppConfiguration] will have an hold on all kinds of configurations for the app
/// which will include theme, language, the environment of the app
/// if an app has a setting option this is the best place to handle all the app settings
/// and to maybe store all these settings/configurations locally
class AppConfiguration extends ChangeNotifier {
  static final AppConfiguration i = AppConfiguration._i();

  factory AppConfiguration() => i;

  AppConfiguration._i();

  String currentThemeName = '';
  String currentLanguageCode = '';

  String appConfigBoxName = 'local_app_config_box';
  String appConfigThemeKey = 'local_app_theme_config_name';
  String appConfigLanguageKey = 'local_app_language_config_name';

  Future<void> initializeApp() async {
    // initialize theme
    await ThemeHandler().initializeTheme();

    // initialize go router
    AppRouter().init();

    // code scout init
    CodeScout.init(
      terimalLoggingConfigutation: CodeScoutLoggingConfiguration(
        analyticsLogs: true,
        crashLogs: true,
        devLogs: true,
        devTraces: true,
        errorLogs: true,
        isDebugMode: kDebugMode,
        networkCall: true,
      ),
    );

    // initialize HiveMind
    String? path;
    if (!kIsWeb) {
      Directory directory = await getApplicationDocumentsDirectory();
      path = directory.path;
    }
    HiveMind.initialize(path: path);

    // HttpEngine initialization
    HttpEngine.init(httpEngineResponseCode: AppServerResponseCodes());

    // initialize persisted data
    await _checkForPersistedSettings();
  }

  Future<void> _checkForPersistedSettings() async {
    String? persistedTheme = await HiveMind.getFromBox<String>(
      key: appConfigThemeKey,
      boxName: appConfigBoxName,
    );

    AppThemes? persistedThemeInstance =
        ThemeHandler().getStaticThemeInstance(persistedTheme);

    if (persistedThemeInstance != null) {
      ThemeHandler.i.updateTheme(persistedThemeInstance);
    }

    String? persistedLangugae = await HiveMind.getFromBox<String>(
      key: appConfigLanguageKey,
      boxName: appConfigBoxName,
    );

    if (persistedLangugae != null) {
      AppLocalization.updateLanguage(
        Language.getLanguageFromCode(code: persistedLangugae),
      );
    }
  }

  void changeTheme(AppThemes theme) {
    // updates the theme using the theme handler
    ThemeHandler.i.updateTheme(theme);

    // persist the theme changes
    HiveMind.addToBox<String>(
      key: appConfigThemeKey,
      value: theme.themeName,
      boxName: appConfigBoxName,
    );

    // update app config instance for state management understanding
    currentThemeName = theme.themeName;

    // update the app state
    notifyListeners();
  }

  void changeLanguage(Language language) {
    // update the app language using AppLocalization class
    AppLocalization.updateLanguage(language);

    // get the updated language code
    currentLanguageCode = language.getCode();

    HiveMind.addToBox<String>(
      key: appConfigLanguageKey,
      value: currentLanguageCode,
      boxName: appConfigBoxName,
    );

    // update the app state
    notifyListeners();
  }
}
