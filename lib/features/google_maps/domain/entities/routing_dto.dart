import 'package:equatable/equatable.dart';

class RoutingDto extends Equatable {
  final String startLat;
  final String startLon;
  final String endLat;
  final String endLon;
  final String? alternative;

  const RoutingDto(
      {required this.startLat,
      required this.startLon,
      required this.endLat,
      required this.endLon,
      this.alternative});

  const RoutingDto.empty()
      : this(startLat: '', startLon: '', endLat: '', endLon: '');

  @override
  List<Object?> get props => [startLat, startLon, endLat, endLon, alternative];
}
