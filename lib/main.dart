import 'package:bikepacking/config/routes/routes.dart';
import 'package:bikepacking/core/dependency_injection/dependency_injection.dart' as di;
import 'package:bikepacking/core/dependency_injection/google_maps_dependency_injection.dart';
import 'package:bikepacking/core/dependency_injection/maplibre_dependency_injection.dart' as osmDI;
import 'package:bikepacking/core/dependency_injection/dependency_injection.dart';
import 'package:bikepacking/core/dependency_injection/maplibre_dependency_injection.dart';
import 'package:bikepacking/core/strava_local_notifications.dart';
import 'package:bikepacking/features/google_maps/presentation/bloc/bloc/google_maps_bloc.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_bloc.dart';
import 'package:bikepacking/features/strava/presentation/bloc/bloc/strava_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:timezone/data/latest.dart" as tz;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initDI();
  await initMaplibreDI();
  await initGoogleMapsDI();
  tz.initializeTimeZones();
  await NotificationService().initNotification();
  runApp(
    MultiProvider(
      providers:[
        BlocProvider<StravaBloc>(create: (context)=>sl<StravaBloc>()),
        BlocProvider<MaplibreBloc>(create: (context)=>sl<MaplibreBloc>()),
        BlocProvider<GoogleMapsBloc>(create: (context)=>sl<GoogleMapsBloc>()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}
