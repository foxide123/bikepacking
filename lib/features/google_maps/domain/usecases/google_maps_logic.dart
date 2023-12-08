import 'package:bikepacking/core/errors/failure.dart';
import 'package:bikepacking/features/google_maps/domain/entities/coordinates_class.dart';
import 'package:bikepacking/features/google_maps/domain/entities/elevation_class.dart';
import 'package:bikepacking/features/google_maps/domain/repository/i_google_maps_repository.dart';
import 'package:dart_either/dart_either.dart';

class GoogleMapsLogic{
  const GoogleMapsLogic(this._repository);

  final IGoogleMapsRepository _repository;

  Future<Either<Failure, List<CoordinatesClass>>> getRouting(String startLat, String startLon, String endLat, String endLon) async {
   return _repository.getRouting(startLat, startLon, endLat, endLon);
  }

  Future<Either<Failure, List<ElevationClass>>> getElevation(String encodedPolyline) async{
    return _repository.getElevation(encodedPolyline);
  }
}