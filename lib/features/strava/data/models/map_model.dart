import 'package:bikepacking/features/strava/domain/enities/map_class.dart';

class MapModel extends MapClass {
  const MapModel({
    super.id,
    super.summaryPolyline,
    super.resourceState,
  });

  factory MapModel.fromJson(Map<String, dynamic> json) {
    return MapModel(
      id: json['id'],
      summaryPolyline: json['summary_polyline'],
      resourceState: json['resource_state'],
    );
  }
}
