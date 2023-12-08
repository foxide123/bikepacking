part of 'google_maps_bloc.dart';

abstract class GoogleMapsState extends Equatable {
  const GoogleMapsState();
  
  @override
  List<Object> get props => [];
}

final class GoogleMapsInitial extends GoogleMapsState {}

class ProfileRetrieved extends GoogleMapsState{
  final  athlete;

  const ProfileRetrieved(this.athlete);
  
  @override
  List<Object> get props =>[athlete];
}


class RoutingRetrieved extends GoogleMapsState{
  final List<CoordinatesClass> responseList;

  const RoutingRetrieved(this.responseList);
}

class ElevationRetrieved extends GoogleMapsState{
  final List<ElevationClass> elevationList;

  const ElevationRetrieved(this.elevationList);
}