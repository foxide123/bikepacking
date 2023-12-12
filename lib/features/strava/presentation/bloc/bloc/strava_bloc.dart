import 'package:bikepacking/features/strava/data/models/route_model.dart';
import 'package:bikepacking/features/strava/domain/enities/athlete.dart';
import 'package:bikepacking/features/strava/domain/enities/route.dart';
import 'package:bikepacking/features/strava/domain/usecases/strava_logic.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'strava_event.dart';
part 'strava_state.dart';

class StravaBloc extends Bloc<StravaEvent, StravaState> {
  final StravaLogic stravaLogic;
  
  StravaBloc({required this.stravaLogic}) : super(StravaInitial()) {
    on<AuthenticateUser>(_onAuthenticateUser);
    on<ExchangeCodeForTokens>(_onExchangeCodeForTokens);
    on<GetProfile>(_onGetProfile);
    on<GetRoutes>(_onGetRoutes);
    on<DownloadRoute>(_onDownloadRoute);
  }

  void _onAuthenticateUser(
    AuthenticateUser event,
    Emitter<StravaState> emit,
  ) async {
    final token = await stravaLogic.authenticateUser();
    if(token != "" && token.isNotEmpty){
      emit(AccessTokenRetrieved(token));
    }
  }

  void _onExchangeCodeForTokens(
    ExchangeCodeForTokens event,
    Emitter<StravaState> emit,
  ) async {
    final token = await stravaLogic.exchangeCodeForTokens(event.scope, event.code);
    if(token != "" && token.isNotEmpty){
      emit(AccessTokenRetrieved(token));
    }
  }

  void _onGetProfile(
    GetProfile event,
    Emitter<StravaState> emit,
  ) async{
    final profile = await stravaLogic.getProfile();
    if(profile != null){
      print("STRAVA_BLOC: ${profile.id}");
      emit(ProfileRetrieved(profile));
    }else{
      print("PROFILE IS NULL");
    }
  }

  void _onGetRoutes(
    GetRoutes event,
    Emitter<StravaState> emit,
  )async{
    final routes = await stravaLogic.getRoutes(event.athleteId);
    routes.fold(
      ifLeft: (response){
        print(response);
      },
     ifRight: (routes){
      print("ROUTES in strava_bloc: $routes");
      emit(RoutesRetrieved(routes));
     });
  }

  void _onDownloadRoute(
    DownloadRoute event,
    Emitter<StravaState> emit,
  )async{
    try{
      String routeContents = await stravaLogic.downloadRoute(event.id, event.routeName);
      emit(DownloadRouteSuccessState(routeContents));
    }catch(e){
      print(e);
    }
  }

}
