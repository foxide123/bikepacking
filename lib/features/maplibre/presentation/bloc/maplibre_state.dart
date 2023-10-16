import 'package:equatable/equatable.dart';

abstract class MaplibreState extends Equatable{
  const MaplibreState();
  
  @override
  List<Object> get props=>[];
}

final class OsmInitial extends MaplibreState {}

final class DownloadSuccessState extends MaplibreState{
  final int regionId;
  
  const DownloadSuccessState(this.regionId);

  @override
  List<Object> get props=>[regionId];
}

final class DownloadInProgressState extends MaplibreState{

  const DownloadInProgressState();

  @override
  List<Object> get props=>[];
}

final class DownloadErrorState extends MaplibreState{

  final String errorMessage;

  const DownloadErrorState(this.errorMessage);

  @override
  List<Object> get props=>[];
}