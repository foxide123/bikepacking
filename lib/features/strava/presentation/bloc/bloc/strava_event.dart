part of 'strava_bloc.dart';

abstract class StravaEvent extends Equatable{
  const StravaEvent();

  @override
  List<Object> get props => [];
}

class AuthenticateUser extends StravaEvent{

  const AuthenticateUser();

  @override
  List<Object> get props => [];
}

class ExchangeCodeForTokens extends StravaEvent{
  final String scope;
  final String code;
  const ExchangeCodeForTokens({required this.scope, required this.code});

  @override
  List<Object> get props =>[scope, code];
}

class GetProfile extends StravaEvent{
  const GetProfile();

  @override
  List<Object> get props =>[];
}

class GetRoutes extends StravaEvent{
  final int athleteId;

  const GetRoutes({required this.athleteId});

  @override
  List<Object> get props =>[];
}

class DownloadRoute extends StravaEvent{
  final int id;

  const DownloadRoute({required this.id});

  @override
  List<Object> get props =>[id];
}