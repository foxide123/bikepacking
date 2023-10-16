import 'package:bikepacking/core/dependency_injection/dependency_injection.dart';
import 'package:bikepacking/features/maplibre/data/data_sources/maplibre_local_data_source.dart';
import 'package:bikepacking/features/maplibre/data/data_sources/maplibre_remote_data_source.dart';
import 'package:bikepacking/features/maplibre/data/repository/maplibre_repository.dart';
import 'package:bikepacking/features/maplibre/domain/repository/i_maplibre_repository.dart';
import 'package:bikepacking/features/maplibre/domain/usecases/maplibre_logic.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_bloc.dart';
import 'package:get_it/get_it.dart';

final slMaplibre = GetIt.instance;

Future<void> initMaplibreDI() async {
  slMaplibre.registerFactory(() => MaplibreBloc(maplibreLogic: slMaplibre()));

  //logic
  slMaplibre.registerLazySingleton(() => MaplibreLogic(slMaplibre()));

  //repository
  slMaplibre.registerLazySingleton(
    () => MaplibreRepository(
      localDataSource: slMaplibre(),
      remoteDataSource: slMaplibre(),
    ),
  );
  //data sources
  slMaplibre.registerLazySingleton(() => MaplibreLocalDataSource(sharedPreferences: slMaplibre()));
  slMaplibre.registerLazySingleton(() => MaplibreRemoteDataSource(client: slMaplibre()));
}
