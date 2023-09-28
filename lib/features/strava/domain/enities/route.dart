import 'package:bikepacking/features/strava/domain/enities/athlete.dart';
import 'package:bikepacking/features/strava/domain/enities/map_class.dart';
import 'package:bikepacking/features/strava/domain/enities/map_urls.dart';
import 'package:equatable/equatable.dart';

class RouteClass extends Equatable{
    final Athlete? athlete;
    final String? description;
    final double? distance;
    final double? elevationGain;
    final int? id;
    final String? idStr;
    final MapClass? map;
    final MapUrls? mapUrls;
    final String? name;
    final bool? private;
    final int? resourceState;
    final bool? starred;
    final int? subType;
    final String? createdAt;
    final String? updatedAt;
    final int? timestamp;
    final int? type;
    final int? estimatedMovingTime;

    const RouteClass({
        this.athlete,
        this.description,
        this.distance,
        this.elevationGain,
        this.id,
        this.idStr,
        this.map,
        this.mapUrls,
        this.name,
        this.private,
        this.resourceState,
        this.starred,
        this.subType,
        this.createdAt,
        this.updatedAt,
        this.timestamp,
        this.type,
        this.estimatedMovingTime,
    });
      List<Object?> get props => [id];
}
