import 'dart:io';

import 'package:bikepacking/core/gpx/max_min_extract.dart';
import 'package:bikepacking/features/maplibre/domain/entities/offline_region_list_item.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_bloc.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_event.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_state.dart';
import 'package:bikepacking/features/strava/presentation/bloc/bloc/strava_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:path_provider/path_provider.dart';

final fakeOfflineRegion = OfflineRegion(
    id: -1,
    definition: OfflineRegionDefinition(
        bounds: LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0)),
        mapStyleUrl: '',
        minZoom: 0,
        maxZoom: 0),
    metadata: {});

class StravaOfflineMapDownloadPage extends StatefulWidget {
  final int routeId;
  final String routeName;
  final String summaryPolyline;

  const StravaOfflineMapDownloadPage(
      {required this.routeId,
      required this.routeName,
      required this.summaryPolyline,
      super.key});

  @override
  State<StravaOfflineMapDownloadPage> createState() =>
      _StravaOfflineMapDownloadPageState();
}

class _StravaOfflineMapDownloadPageState
    extends State<StravaOfflineMapDownloadPage> {
  String progress = '';
  double minLat = 0;
  double minLon = 0;
  double maxLat = 0;
  double maxLon = 0;

  String routeContents = '';

  @override
  void initState() {
    _downloadRoute();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MaplibreBloc, MaplibreState>(
      listener: (context, state) {
        if (state is DownloadInProgressState) {
          progress = 'download in progress';
        }
        if (state is DownloadSuccessState) {
          progress = 'download success state for regionId: ${state.regionId}';
          GoRouter.of(context)
              .pushNamed('maplibreOfflineRegionMap', pathParameters: {
            'regionId': state.regionId.toString(),
            'minLat': minLat.toString(),
            'maxLat': maxLat.toString(),
            'minLon': minLon.toString(),
            'maxLon': maxLon.toString(),
            'routeName': widget.routeName,
            'summaryPolyline': widget.summaryPolyline,
          });
        }
        if (state is DownloadErrorState) {
          progress = state.errorMessage;
        }
      },
      builder: (context, state) {
        return BlocConsumer<StravaBloc, StravaState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(),
              body: Column(
                children: [
                  Text("PROGRESS: "),
                  Text(progress),
                ],
              ),
            );
          },
          listener: (BuildContext context, StravaState state) {
            if (state is DownloadRouteSuccessState) {
              print("DOWNLOAD ROUTE SUCCESS STATE");
              routeContents = state.routeContents;
              _downloadOfflineRegion();
            }
          },
        );
      },
    );
  }

  _downloadRoute() async {
    BlocProvider.of<StravaBloc>(context)
        .add(DownloadRoute(id: widget.routeId, routeName: widget.routeName));
  }

  _downloadOfflineRegion() async {
    Map<String, double> coordinates = await extractBounds(routeContents);
      minLat = coordinates['minLat']!;
      maxLat = coordinates['maxLat']!;
      minLon = coordinates['minLon']!;
      maxLon = coordinates['maxLon']!;

     List<OfflineRegion> offlineRegions = await getListOfRegions();
    final offlineRegion = offlineRegions.firstWhere(
       (offlineRegion) => offlineRegion.metadata['name'] == widget.routeName,
        orElse: () => fakeOfflineRegion);
    if (offlineRegion.id == -1) {
      print("OFFLINE REGION IS -1");
      BlocProvider.of<MaplibreBloc>(context).add(
        DownloadOfflineMap(
            minLat: coordinates['minLat']!,
            maxLat: coordinates['maxLat']!,
            minLon: coordinates['minLon']!,
            maxLon: coordinates['maxLon']!,
            routeName: widget.routeName,
            mapType: "outdoor"),
      );
    }
    else{
      print("OFFLINE REGION IS ${offlineRegion.id}");
      GoRouter.of(context)
              .pushNamed('maplibreOfflineRegionMap', pathParameters: {
            'regionId': offlineRegion.id.toString(),
            'minLat': minLat.toString(),
            'maxLat': maxLat.toString(),
            'minLon': minLon.toString(),
            'maxLon': maxLon.toString(),
            'routeName': widget.routeName,
            'summaryPolyline': widget.summaryPolyline,
          });
    }
    
  }
}
