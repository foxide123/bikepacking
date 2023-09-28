part of 'strava_bloc.dart';

abstract class StravaState extends Equatable{
  const StravaState();

  @override
  List<Object> get props=> [];
}

final class StravaInitial extends StravaState {}

class AccessTokenRetrieved extends StravaState{
  final String token;

  const AccessTokenRetrieved(this.token);

  @override
  List<Object> get props =>[token];
}

class ProfileRetrieved extends StravaState{
  final Athlete athlete;

  const ProfileRetrieved(this.athlete);
  
  @override
  List<Object> get props =>[athlete];
}

class RoutesRetrieved extends StravaState{
  final List<dynamic> routes;

  const RoutesRetrieved(this.routes);

  @override
  List<Object> get props =>[];
}
