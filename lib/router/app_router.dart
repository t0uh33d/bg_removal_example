import 'app_middleware.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final AppRouter _appRouter = AppRouter._internal();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  late GoRouter goRouter;

  factory AppRouter() {
    return _appRouter;
  }
  AppRouter._internal();

  List<RouteBase> get _routes {
    return <RouteBase>[
      // GoRoute(
      //   path: '/',
      //   builder: (BuildContext context, GoRouterState state) {
      //      your initial route goes here
      //   },
      // ),
    ];
  }

  void init() {
    goRouter = GoRouter(
      initialLocation: '/',
      routes: _routes,
      navigatorKey: navigatorKey,
      redirect: AppMiddleware.bind,
    );
    // GoRouter.optionURLReflectsImperativeAPIs = true;
  }
}
