import 'package:bikepacking/features/bikepacking/presentation/pages/bikepacking_list_page.dart';
import 'package:bikepacking/features/bikepacking/presentation/pages/bikepacking_page.dart';
import 'package:bikepacking/features/bikepacking/presentation/pages/currency_converter_page.dart';
import 'package:bikepacking/features/bikepacking/presentation/pages/location_sharing_page.dart';
import 'package:bikepacking/features/bikepacking/presentation/pages/notebook_page.dart';
import 'package:bikepacking/features/bikepacking/presentation/pages/vpn_page.dart';
import 'package:bikepacking/features/maplibre/presentation/pages/maplibre_downloaded_maps.dart';
import 'package:bikepacking/features/maplibre/presentation/pages/maplibre_map_page.dart';
import 'package:bikepacking/features/maplibre/presentation/pages/maplibre_offline_page.dart';
import 'package:bikepacking/features/maplibre/presentation/pages/maplibre_offline_region_map.dart';
import 'package:bikepacking/features/shared/device_gpx_files_page.dart';
import 'package:bikepacking/features/shared/google_maps_to_gpx_page.dart';
import 'package:bikepacking/features/strava/domain/enities/route.dart';
import 'package:bikepacking/features/strava/presentation/pages/route_details.dart';
import 'package:bikepacking/features/strava/presentation/pages/strava_offline_map_download_page.dart';
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
  GoRoute(
      path:
          "/stravaOfflineMapDownloadPage/:routeId/:routeName/:summaryPolyline",
      name: "stravaOfflineMapDownloadPage",
      builder: (BuildContext context, GoRouterState state) {
        final routeId = int.parse(state.pathParameters['routeId']!);
        final routeName = state.pathParameters['routeName']!;
        final summaryPolyline = state.pathParameters['summaryPolyline']!;
        return StravaOfflineMapDownloadPage(
          routeId: routeId,
          routeName: routeName,
          summaryPolyline: summaryPolyline,
        );
      }),
  GoRoute(
      path: "/maplibreMap",
      name: "maplibreMap",
      builder: (BuildContext context, GoRouterState state) {
        return MaplibreMapPage();
      }),
  GoRoute(
      path: "/maplibreOffline",
      builder: (BuildContext context, GoRouterState state) {
        return MaplibreOfflinePage();
      }),
  GoRoute(
      path:
          "/maplibreOfflineRegionMap/:regionId/:minLat/:minLon/:maxLat/:maxLon/:routeName/:summaryPolyline/:gpxContent",
      name: "maplibreOfflineRegionMap",
      builder: (BuildContext context, GoRouterState state) {
        final regionId = state.pathParameters['regionId']!;
        final minLat = state.pathParameters['minLat']!;
        final maxLat = state.pathParameters['maxLat']!;
        final minLon = state.pathParameters['minLon']!;
        final maxLon = state.pathParameters['maxLon']!;
        final routeName = state.pathParameters['routeName']!;
        final summaryPolyline = state.pathParameters['summaryPolyline'];
        final gpxContent = state.pathParameters['gpxContent'];
        return MaplibreOfflineRegionMap(
            regionId: regionId,
            minLat: minLat,
            minLon: minLon,
            maxLat: maxLat,
            maxLon: maxLon,
            routeName: routeName,
            summaryPolyline: summaryPolyline,
            gpxContent: gpxContent);
      }),

      GoRoute(
      path: "/maplibreDownloadedMaps",
      builder: (BuildContext context, GoRouterState state) {
        return MaplibreDownloadedMaps();
      }),
  GoRoute(
      path: "/deviceGpxFiles",
      builder: (BuildContext context, GoRouterState state) {
        return DeviceGpxFilesPage();
      }),
  GoRoute(
      path: "/googleMapsToGpxPage",
      builder: (BuildContext context, GoRouterState state) {
        return GoogleMapsToGpxPage();
      }),
  GoRoute(
      path: "/bikepackingPage",
      builder: (BuildContext context, GoRouterState state) {
        return BikepackingPage();
      }),
  GoRoute(
      path: "/bikepackingListPage",
      builder: (BuildContext context, GoRouterState state) {
        return BikepackingListPage();
      }),
  GoRoute(
      path: "/currencyConverterPage",
      builder: (BuildContext context, GoRouterState state) {
        return CurrencyConverterPage();
      }),
      GoRoute(
      path: "/notebookPage",
      builder: (BuildContext context, GoRouterState state) {
        return NotebookPage();
      }),
      GoRoute(
      path: "/locationSharingPage",
      builder: (BuildContext context, GoRouterState state) {
        return LocationSharingPage();
      }),
      GoRoute(
      path: "/vpnPage",
      builder: (BuildContext context, GoRouterState state) {
        return VpnPage();
      })
]);

void clearNavigationStack(context, String path) {
  final router = GoRouter.of(context);
  router.replace(path);
}
