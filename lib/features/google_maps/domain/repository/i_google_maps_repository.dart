import 'package:bikepacking/core/errors/failure.dart';
import 'package:bikepacking/features/google_maps/domain/entities/coordinates_class.dart';
import 'package:bikepacking/features/google_maps/domain/entities/elevation_class.dart';
import 'package:dart_either/dart_either.dart';

abstract class IGoogleMapsRepository{
  Future<Either<Failure, List<CoordinatesClass>>> getRouting(String startLat, String startLon, String endLat, String endLon);
  Future<Either<Failure, List<ElevationClass>>> getElevation(String encodedPolyline);
}