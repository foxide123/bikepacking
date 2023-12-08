

import 'package:bikepacking/features/google_maps/domain/entities/elevation_class.dart';

class ElevationDAO extends ElevationClass {
  const ElevationDAO({required super.elevation, required super.lat, required super.lon, required super.resolution});

  factory ElevationDAO.fromJSON(Map<String, dynamic> map) {
    return ElevationDAO(
        elevation: (map['elevation'] as num).toDouble(),
      lat: (map['location']['lat'] as num).toDouble(),
      lon: (map['location']['lng'] as num).toDouble(),
      resolution: (map['resolution'] as num).toDouble(),
    );
  }
}
