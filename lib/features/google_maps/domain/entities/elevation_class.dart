import 'package:equatable/equatable.dart';

class ElevationClass extends Equatable {
  final double elevation;
  final double lat;
  final double lon;
  final double resolution;

  const ElevationClass({
    required this.elevation,
    required this.lat,
    required this.lon,
    required this.resolution,
  });

  const ElevationClass.empty()
      : this(
          elevation: 0,
          lat: 0,
          lon: 0,
          resolution: 0,
        );

  @override
  List<Object?> get props => [lat, lon];
}
