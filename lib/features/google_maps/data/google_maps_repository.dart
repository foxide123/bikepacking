import 'package:bikepacking/core/errors/failure.dart';
import 'package:bikepacking/features/google_maps/data/data_sources/google_maps_local_data_source.dart';
import 'package:bikepacking/features/google_maps/data/data_sources/google_maps_remote_data_source.dart';
import 'package:bikepacking/features/google_maps/domain/entities/coordinates_class.dart';
import 'package:bikepacking/features/google_maps/domain/entities/elevation_class.dart';
import 'package:bikepacking/features/google_maps/domain/repository/i_google_maps_repository.dart';
import 'package:dart_either/dart_either.dart';

class GoogleMapsRepository implements IGoogleMapsRepository{

  final GoogleMapsLocalDataSource localDataSource;
  final GoogleMapsRemoteDataSource remoteDataSource;

  GoogleMapsRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<CoordinatesClass>>> getRouting(String startLat, String startLon, String endLat, String endLon) {
    return remoteDataSource.getRouting(startLat, startLon, endLat, endLon);
  }
  
  @override
  Future<Either<Failure, List<ElevationClass>>> getElevation(String encodedPolyline) {
    return remoteDataSource.getElevation(encodedPolyline);
  }

}