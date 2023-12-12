import 'package:bikepacking/features/google_maps/domain/entities/coordinates_class.dart';
import 'package:bikepacking/features/google_maps/domain/entities/elevation_class.dart';
import 'package:bikepacking/features/google_maps/domain/usecases/google_maps_logic.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'google_maps_event.dart';
part 'google_maps_state.dart';

class GoogleMapsBloc extends Bloc<GoogleMapsEvent, GoogleMapsState> {
  final GoogleMapsLogic googleMapsLogic;
  GoogleMapsBloc({required this.googleMapsLogic}) : super(GoogleMapsInitial()) {
    on<GoogleMapsEvent>((event, emit) {});
    on<GetRouting>(_onGetRouting);
    on<GetElevation>(_onGetElevation);
  }

  void _onGetRouting(
    GetRouting event,
    Emitter<GoogleMapsState> emit,
  ) async {
    final response = await googleMapsLogic.getRouting(
        event.startLat, event.startLon, event.endLat, event.endLon);
    response.fold(
        ifLeft: (value) => print(value),
        ifRight: (listOfCoordinates) =>
            emit(RoutingRetrieved(listOfCoordinates)));
  }

  void _onGetElevation(
    GetElevation event,
    Emitter<GoogleMapsState> emit,
  ) async {
    final response = await googleMapsLogic.getElevation(event.encodedPolylines);
    response.fold(
      ifLeft: (value) => print(value),
      ifRight: (listOfElevation) => {
        emit(ElevationRetrieved(listOfElevation)),
        print("ElevationRetrieved state called")
      },
    );
  }
}
