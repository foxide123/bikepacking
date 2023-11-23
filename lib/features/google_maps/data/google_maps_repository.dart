import 'package:bikepacking/features/google_maps/data/data_sources/google_maps_local_data_source.dart';
import 'package:bikepacking/features/google_maps/data/data_sources/google_maps_remote_data_source.dart';
import 'package:bikepacking/features/google_maps/domain/repository/i_google_maps_repository.dart';

class GoogleMapsRepository implements IGoogleMapsRepository{

  final GoogleMapsLocalDataSource localDataSource;
  final GoogleMapsRemoteDataSource remoteDataSource;

  GoogleMapsRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  getRouting(String startLat, String startLon, String endLat, String endLon) {
    return remoteDataSource.getRouting(startLat, startLon, endLat, endLon);
  }

}