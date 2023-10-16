import 'package:equatable/equatable.dart';

abstract class MaplibreEvent extends Equatable {
  const MaplibreEvent();

  @override
  List<Object> get props => [];
}

class DownloadOfflineMap extends MaplibreEvent {
  final double minLat;
  final double maxLat;
  final double minLon;
  final double maxLon;
  final String routeName;

  const DownloadOfflineMap({
    required this.minLat,
    required this.maxLat,
    required this.minLon,
    required this.maxLon,
    required this.routeName,
  });
}
