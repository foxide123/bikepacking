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
    stravaLogic.exchangeCodeForTokens(event.scope, event.code);
  }
}
