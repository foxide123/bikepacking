import 'package:bikepacking/features/strava/data/models/athlete_model.dart';
import 'package:bikepacking/features/strava/data/models/map_model.dart';
import 'package:bikepacking/features/strava/data/models/map_urls_model.dart';
import 'package:bikepacking/features/strava/domain/enities/athlete.dart';
import 'package:bikepacking/features/strava/domain/enities/map_class.dart';
import 'package:bikepacking/features/strava/domain/enities/map_urls.dart';
import 'package:bikepacking/features/strava/domain/enities/route.dart';

class RouteModel extends RouteClass {
  const RouteModel({
    super.athlete,
    super.description,
    super.distance,
    super.elevationGain,
    super.id,
    super.idStr,
    super.map,
    super.mapUrls,
    super.name,
    super.private,
    super.resourceState,
    super.starred,
    super.subType,
    super.createdAt,
    super.updatedAt,
    super.timestamp,
    super.type,
    super.estimatedMovingTime,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      athlete: AthleteModel.fromJson(json['athlete'] as Map<String, dynamic>),
      description: json['description'],
      distance: json['distance'],
      elevationGain: json['elevation_gain'],
      id: json['id'],
      idStr: json['id_str'],
      map: MapModel.fromJson(json['map']),
      mapUrls: MapUrlsModel.fromJson(json['map_urls']),
      name: json['name'],
      private: json['private'],
      resourceState: json['resource_state'],
      starred: json['starred'],
      subType: json['sub_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      timestamp: json['timestamp'],
      type: json['type'],
      estimatedMovingTime: json['estimated_moving_time'],
    );
  }
}
