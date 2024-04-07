import 'dart:async';

import 'package:flutter_wiretap/flutter_wiretap.dart';

import 'router/app_router.dart';
import 'services/crashlytics/crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ChangeNotifierProvider, Consumer;

import 'core/configuration/app_configuration.dart';
// import 'core/l10n/generated/app_localization.dart';
import 'core/themes/theme_handler.dart';
// import 'core/l10n/app_strings.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await AppConfiguration.i.initializeApp();

      runApp(const MyApp());
    },
    Crashlytics().traceError,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AppConfiguration(),
      child: Consumer<AppConfiguration>(
        builder: (context, config, _) {
          return MaterialApp.router(
            title: 'Background removal app',
            builder: (context, child) {
              // comment the below to disable wiretap
              return Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (context) {
                      Wiretap.initialize(
                        context: context,
                        freshContextFetcher: () =>
                            AppRouter.navigatorKey.currentContext!,
                      );
                      return child ?? const SizedBox();
                    },
                  )
                ],
              );
            },
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: ThemeHandler.currentTheme.primaryColor,
              ),
              useMaterial3: true,
              fontFamily: ThemeHandler.currentTheme.fontFamily,
            ),
            routerConfig: AppRouter().goRouter,
            // uncomment below lines when the multilingual feature is enabled
            // localizationsDelegates: AppLocalization.localizationsDelegates,
            // supportedLocales: AppLocalization.supportedLocales,
            // locale: AppLocalization.currentLanguage,
          );
        },
      ),
    );
  }
}
