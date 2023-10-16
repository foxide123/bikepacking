import 'package:bikepacking/features/maplibre/data/data_sources/maplibre_local_data_source.dart';
import 'package:bikepacking/features/maplibre/data/data_sources/maplibre_remote_data_source.dart';
import 'package:bikepacking/features/maplibre/domain/repository/i_maplibre_repository.dart';

class MaplibreRepository implements IMaplibreRepository{
  final MaplibreLocalDataSource localDataSource;
  final MaplibreRemoteDataSource remoteDataSource;

  MaplibreRepository({required this.localDataSource, required this.remoteDataSource});

  download(){}

}