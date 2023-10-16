import 'package:bikepacking/features/maplibre/data/repository/maplibre_repository.dart';
import 'package:bikepacking/features/maplibre/domain/repository/i_maplibre_repository.dart';
import 'package:bikepacking/features/strava/data/data_sources/strava_local_data_source.dart';
import 'package:bikepacking/features/strava/data/data_sources/strava_remote_data_source.dart';
import 'package:bikepacking/features/strava/data/repository/strava_repository.dart';
import 'package:bikepacking/features/strava/domain/repository/i_strava_repository.dart';
import 'package:bikepacking/features/strava/domain/usecases/strava_logic.dart';
import 'package:bikepacking/features/strava/presentation/bloc/bloc/strava_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> initDI() async {
  sl.registerFactory(() => StravaBloc(stravaLogic: sl()));

  //logic
  sl.registerLazySingleton(() => StravaLogic(sl()));

  //repository
  sl.registerLazySingleton<IStravaRepository>(
    () => StravaRepository(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );
  //data sources
  sl.registerLazySingleton(() => StravaLocalDataSource(sharedPreferences: sl()));
  sl.registerLazySingleton(() => StravaRemoteDataSource(client: sl()));

  //external
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(()=>http.Client());
  
}
