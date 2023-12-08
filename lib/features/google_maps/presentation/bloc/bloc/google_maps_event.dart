part of 'google_maps_bloc.dart';

abstract class GoogleMapsEvent extends Equatable {
  const GoogleMapsEvent();

  @override
  List<Object> get props => [];
}

class GetRouting extends GoogleMapsEvent {
  final String startLat;
  final String startLon;
  final String endLat;
  final String endLon;
  final String alternative;

  const GetRouting({required this.startLat, required this.startLon, required this.endLat, required this.endLon, required this.alternative});

  @override
  List<Object> get props => [startLat, startLon, endLat, endLon];
}

class GetElevation extends GoogleMapsEvent{
  final String encodedPolylines;

  const GetElevation({required this.encodedPolylines});

  @override
  List<Object> get props => [encodedPolylines];
}
