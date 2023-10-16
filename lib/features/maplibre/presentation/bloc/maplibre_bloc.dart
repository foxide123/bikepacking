import 'package:bikepacking/features/maplibre/domain/usecases/maplibre_logic.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_event.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_state.dart';
import 'package:bikepacking/features/strava/presentation/bloc/bloc/strava_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class MaplibreBloc extends Bloc<MaplibreEvent, MaplibreState> {
  final MaplibreLogic maplibreLogic;

  MaplibreBloc({required this.maplibreLogic}) : super(OsmInitial()) {
    on<DownloadOfflineMap>(_onDownloadOfflineMap);
  }

  void _onDownloadOfflineMap(
    DownloadOfflineMap event,
    Emitter<MaplibreState> emit,
  ) async {
    try {
      print("In _onDownloadOfflineMap");
      emit(DownloadInProgressState());
      int regionId = await maplibreLogic.downloadOfflineMap(event.minLat,
          event.maxLat, event.minLon, event.maxLon, event.routeName);
      emit(DownloadSuccessState(regionId));
    } catch (error) {
      emit(DownloadErrorState(error.toString()));
    }
  }
}
