import 'package:bikepacking/config/routes/routes.dart';
import 'package:bikepacking/core/dependency_injection.dart' as di;
import 'package:bikepacking/core/dependency_injection.dart';
import 'package:bikepacking/features/strava/presentation/bloc/bloc/strava_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:timezone/data/latest.dart" as tz;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await di.init();
  runApp(
    MultiProvider(
      providers:[
        BlocProvider<StravaBloc>(create: (context)=>sl<StravaBloc>())
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
