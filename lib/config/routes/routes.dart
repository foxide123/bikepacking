import 'package:bikepacking/features/strava/domain/enities/route.dart';
import 'package:bikepacking/features/strava/presentation/pages/route_details.dart';
import 'package:bikepacking/home_page.dart';
import 'package:bikepacking/main.dart';
import 'package:bikepacking/features/strava/presentation/pages/oauth_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter router = GoRouter(initialLocation: "/", routes: <GoRoute>[
  GoRoute(
      path: "/:code/:scope",
      name: "oauth",
      builder: (BuildContext context, GoRouterState state) {
        print("IN OAUTH ROUTE");
        final code = state.pathParameters['code']!.toString();
        final scope = state.pathParameters['scope']!.toString();
        return OAuthPage(code: code, scope: scope);
      }),
  GoRoute(
      path: "/",
      builder: (BuildContext context, GoRouterState state) {
        print("IN STREETVIEW ROUTE");
        return HomePage();
      }),
  GoRoute(
      path: "/routeDetails",
      name: "routeDetails",
      builder: (BuildContext context, GoRouterState state) {
        RouteClass routeClass = state.extra as RouteClass;
        return RouteDetails(object: routeClass);
      }),
]);

void clearNavigationStack(context, String path) {
  final router = GoRouter.of(context);
  router.replace(path);
}
