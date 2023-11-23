import 'package:bikepacking/core/dependency_injection/dependency_injection.dart';
import 'package:bikepacking/features/google_maps/data/data_sources/google_maps_local_data_source.dart';
import 'package:bikepacking/features/google_maps/data/data_sources/google_maps_remote_data_source.dart';
import 'package:bikepacking/features/google_maps/data/google_maps_repository.dart';
import 'package:bikepacking/features/google_maps/domain/repository/i_google_maps_repository.dart';
import 'package:bikepacking/features/google_maps/domain/usecases/google_maps_logic.dart';
import 'package:bikepacking/features/google_maps/presentation/bloc/bloc/google_maps_bloc.dart';
import 'package:bikepacking/features/maplibre/data/data_sources/maplibre_local_data_source.dart';
import 'package:bikepacking/features/maplibre/data/data_sources/maplibre_remote_data_source.dart';
import 'package:bikepacking/features/maplibre/data/repository/maplibre_repository.dart';
import 'package:bikepacking/features/maplibre/domain/repository/i_maplibre_repository.dart';
import 'package:bikepacking/features/maplibre/domain/usecases/maplibre_logic.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_bloc.dart';
import 'package:get_it/get_it.dart';

final slGoogleMaps = GetIt.instance;

Future<void> initGoogleMapsDI() async {
  slGoogleMaps.registerFactory(() => GoogleMapsBloc(googleMapsLogic: slGoogleMaps()));

  //logic
  slGoogleMaps.registerLazySingleton(() => GoogleMapsLogic(slGoogleMaps()));

  //repository
  slGoogleMaps.registerLazySingleton<IGoogleMapsRepository>(
    () => GoogleMapsRepository(
      localDataSource: slGoogleMaps(),
      remoteDataSource: slGoogleMaps(),
    ),
  );
  //data sources
  slGoogleMaps.registerLazySingleton(() => GoogleMapsLocalDataSource(sharedPreferences: slGoogleMaps()));
  slGoogleMaps.registerLazySingleton(() => GoogleMapsRemoteDataSource(client: slGoogleMaps()));
}
