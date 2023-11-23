import 'package:equatable/equatable.dart';

class CoordinatesClass extends Equatable{
  final double lat;
  final double lon;

  const CoordinatesClass({required this.lat, required this.lon});

  const CoordinatesClass.empty() :
    this(
      lat: 0,
      lon: 0,
    );
  
  @override
  List<Object?> get props => [lat,lon];
}