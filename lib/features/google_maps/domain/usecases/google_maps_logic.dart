import 'package:bikepacking/features/google_maps/domain/repository/i_google_maps_repository.dart';

class GoogleMapsLogic{
  const GoogleMapsLogic(this._repository);

  final IGoogleMapsRepository _repository;

  getRouting(String startLat, String startLon, String endLat, String endLon) async {
   return _repository.getRouting(startLat, startLon, endLat, endLon);
  }
}