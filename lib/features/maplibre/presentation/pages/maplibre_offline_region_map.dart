import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:bikepacking/core/create_offline_region.dart';
import 'package:bikepacking/core/gpx/gpx_to_coordinates.dart';
import 'package:bikepacking/core/gpx/gpx_distance_calculator.dart';
import 'package:bikepacking/core/gpx/gpx_to_coordinates.dart';
import 'package:bikepacking/core/gpx/polyline_encoder.dart';
import 'package:bikepacking/features/google_maps/domain/entities/chart_data.dart';
import 'package:bikepacking/features/google_maps/domain/entities/elevation_class.dart';
import 'package:bikepacking/features/google_maps/presentation/bloc/bloc/google_maps_bloc.dart';
import 'package:bikepacking/features/maplibre/domain/entities/offline_region_list_item.dart';
import 'package:bikepacking/features/maplibre/presentation/helper_functions/offline_region_map/add_polyline_to_map.dart';
import 'package:bikepacking/features/maplibre/presentation/helper_functions/offline_region_map/adjust_map_rotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:xml/xml.dart';
import 'package:geolocator_platform_interface/src/models/position.dart'
    as Geolocation_Position;

class MaplibreOfflineRegionMap extends StatefulWidget {
  final String regionId;
  final String minLat;
  final String minLon;
  final String maxLat;
  final String maxLon;
  final String routeName;
  final String? summaryPolyline;
  final String? gpxContent;

  const MaplibreOfflineRegionMap(
      {required this.regionId,
      required this.minLat,
      required this.minLon,
      required this.maxLat,
      required this.maxLon,
      required this.routeName,
      this.summaryPolyline,
      this.gpxContent,
      super.key});

  @override
  State<MaplibreOfflineRegionMap> createState() =>
      _MaplibreOfflineRegionMapState();
}

class _MaplibreOfflineRegionMapState extends State<MaplibreOfflineRegionMap> {
  late OfflineRegionListItem item;
  MaplibreMapController? mapController;
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylinesLatLng = [];

  bool _hasPermissions = false;

  double? compassDirection;
  late Symbol addedSymbol;

  double distance = 0;

  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;

  List<ChartData> chartData = [];

  ChartSeriesController? _chartSeriesController;

  bool canUserRotateMap = true;

  StreamSubscription<CompassEvent>? compassSubscription;
  StreamSubscription<Geolocation_Position.Position>? speedSubscription;

  bool hideBottomPart = false;

  @override
  void initState() {
    item = createOfflineRegionListItem(widget.regionId, widget.minLat,
        widget.maxLat, widget.minLon, widget.maxLon, widget.routeName);

    _fetchPermissionStatus();

    if (widget.summaryPolyline != 'empty') {
      print("in if(widget.summaryPolyline != empty)");
      late List<PointLatLng> polylines =
          polylinePoints.decodePolyline(widget.summaryPolyline!);
      polylines.forEach((polyline) =>
          polylinesLatLng.add(LatLng(polyline.latitude, polyline.longitude)));
    }
    if (widget.gpxContent != 'empty') {
      print("in if(widget.gpxContet != null)");
      extractCoordinatesFromGPX();
    }

    _tooltipBehavior = TooltipBehavior(enable: true, header: 'elevation');
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      //enablePinching: true,
      //zoomMode: ZoomMode.y,
    );
    super.initState();
  }

  @override
  void dispose() {
    //mapController?.dispose();
    compassSubscription?.cancel();
    super.dispose();
  }

  /*void calculateSpeed() {
    speedSubscription = Geolocator.getPositionStream().listen((position) {
      var speedInMps = position.speed.toStringAsPrecision(2);
      print(speedInMps);
    });
  }*/

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermissions = (status == PermissionStatus.granted);
        });
      }
    });
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        child: Text("Request Permission"),
        onPressed: () {
          Permission.locationWhenInUse.request().then((value) {
            _fetchPermissionStatus();
          });
        },
      ),
    );
  }

  void addPolyline() async {
    try {
      if (mapController != null && polylinesLatLng.isNotEmpty && mounted) {
        addedSymbol = await addPolylineToMap(mapController!, polylinesLatLng);
      }

      updateMarkerPosition();
    } catch (e) {
      print("EXCEPTION $e");
    }
  }

  void extractCoordinatesFromGPX() async {
    polylinesLatLng = gpxToCoordinates(widget.gpxContent!);

    setState(() {
      distance = calculateGpxDistance(polylinesLatLng);
    });

    String encodedPolyline = '';
    if (polylinesLatLng.length > 500) {
      List<LatLng> tempList = [];
      List<LatLng> tempList2 = [];
      for (int i = 0; i < polylinesLatLng.length; i++) {
        if (i == 0) tempList.add(polylinesLatLng[i]);
        if (i >= polylinesLatLng.length - 2) {
          tempList.add(polylinesLatLng[i]);
          continue;
        }
        if (i % 50 == 0) {
          tempList.add(polylinesLatLng[i]);
        }
      }
      if (tempList.length > 500) {
        for (int i = 0; i < tempList.length; i++) {
          if (i == 0) tempList2.add(tempList[i]);
          if (i % 10 == 0) {
            tempList2.add(tempList[i]);
          }
        }
      }
      if (tempList2.isNotEmpty) {
        encodedPolyline = encodePolyline(tempList2);
      } else {
        encodedPolyline = encodePolyline(tempList);
      }
    } else {
      encodedPolyline = encodePolyline(polylinesLatLng);
    }

    getElevation(encodedPolyline);
  }

  List<double> calculateDistances(List<ElevationClass> elevationData) {
    List<double> distances = [0.0];
    double totalDistance = 0.0;

    for (int i = 1; i < elevationData.length; i++) {
      var prevPoint =
          LatLng(elevationData[i - 1].lat, elevationData[i - 1].lon);
      var currentPoint = LatLng(elevationData[i].lat, elevationData[i].lon);
      totalDistance += haversineDistance(
          [prevPoint.latitude, prevPoint.longitude],
          [currentPoint.latitude, currentPoint.longitude]);
      distances.add(totalDistance);
    }
    for (int i = 0; i < elevationData.length; i++) {
      setState(() {
        chartData.add(ChartData(
            distance: distances[i], elevation: elevationData[i].elevation));
      });
    }
    print("ChartData: $chartData");
    return distances;
  }

  void updateMarkerPosition() {
    compassSubscription = FlutterCompass.events!.listen((CompassEvent event) {
      print(event.heading);
      event.headingForCameraMode;
      compassDirection = event.heading;
      updateMarkerDirection(compassDirection);
    });
  }

  void _onMapCreated(MaplibreMapController controller) {
    if (mounted) {
      setState(() {
        mapController = controller;
      });
    }
  }

  void _onStyleLoaded() async {
    ByteData byteData = await rootBundle.load("assets/up-long-solid.png");
    ByteData byteDataFinishLine =
        await rootBundle.load("assets/flag-checkered-solid.png");
    Uint8List uint8List = byteData.buffer.asUint8List();
    Uint8List uint8ListFinishLine = byteDataFinishLine.buffer.asUint8List();
    mapController?.addImage('arrow-icon', uint8List);
    mapController?.addImage('flag-checkered', uint8ListFinishLine);
  }

  double adjustedCompassDirection(double? direction) {
    if (direction == null) return 0.0;
    return direction >= 0 ? direction : 360 + direction;
  }

  void updateMarkerDirection(double? compassDirection) {
    if (mapController != null &&
        compassDirection != null &&
        addedSymbol != null &&
        mounted) {
      double mapBearing = mapController!.cameraPosition!.bearing;
      double adjustedRotation = compassDirection - mapBearing;

      // Adjust to keep the value between 0 to 360
      if (adjustedRotation >= 360) {
        adjustedRotation -= 360;
      } else if (adjustedRotation < 0) {
        adjustedRotation += 360;
      }
      if (!canUserRotateMap) {
        adjustMapRotation(compassDirection, mapController!, polylinesLatLng);
      }
      mapController?.updateSymbol(
        addedSymbol,
        SymbolOptions(
          iconRotate: adjustedRotation,
        ),
      );
    }
  }

  void getElevation(String encodedPolyline) {
    BlocProvider.of<GoogleMapsBloc>(context)
        .add(GetElevation(encodedPolylines: encodedPolyline));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GoogleMapsBloc, GoogleMapsState>(
      listener: (context, state) {
        if (state is ElevationRetrieved) {
          print("elevationList: ${state.elevationList}");
          print(
              "calculatedDistances: ${calculateDistances(state.elevationList)}");
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            MaplibreMap(
              // onMapClick: (point, coordinates) => ,
              trackCameraPosition: true,
              myLocationEnabled: true,
              onStyleLoadedCallback: _onStyleLoaded,
              onCameraIdle: () async {
                print("on camera idle");
                if (mapController != null) {
                  print('mapController is not null');
                }
                if (mapController?.cameraPosition != null &&
                    mapController != null &&
                    mounted) {
                  print(
                      'Camera Position after camera movement stops: ${mapController!.cameraPosition!.bearing}');
                } else {
                  print('position null');
                }
              },
              onCameraTrackingChanged: (trackingMode) {},
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: item.offlineRegionDefinition.minZoom,
              ),
              compassEnabled: true,
              minMaxZoomPreference: MinMaxZoomPreference(
                item.offlineRegionDefinition.minZoom,
                item.offlineRegionDefinition.maxZoom,
              ),
              styleString: item.offlineRegionDefinition.mapStyleUrl,
              cameraTargetBounds: CameraTargetBounds(
                item.offlineRegionDefinition.bounds,
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      addPolyline();
                    },
                    child: Text("Add polyline")),
                FloatingActionButton.extended(
                    backgroundColor:
                        canUserRotateMap ? Colors.blue : Colors.orange,
                    label: Text(
                      "Auto Center",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      setState(() {
                        canUserRotateMap = !canUserRotateMap;
                      });
                      if (mapController != null && mounted) {
                        adjustMapRotation(
                            mapController!.cameraPosition!.bearing,
                            mapController!,
                            polylinesLatLng);
                      }
                    },
                    elevation: canUserRotateMap ? 6.0 : 18.0),
                /* ElevatedButton(
                    onPressed: () {
                      canUserRotateMap = !canUserRotateMap;
                      adjustMapRotation(mapController!.cameraPosition!.bearing, mapController!, polylinesLatLng);
                    },
                    child: Text("Auto Center"))*/
              ],
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: hideBottomPart ? 80 : 220,
                color: Theme.of(context).primaryColor,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Text("Total:"),
                              Text(
                                distance.toStringAsFixed(2) + "km",
                              ),
                            ],
                          ),
                          width: MediaQuery.of(context).size.width / 2 - 10,
                        ),
                        GestureDetector(
                          child: hideBottomPart
                              ? Icon(FontAwesomeIcons.arrowUp)
                              : Icon(FontAwesomeIcons.arrowDown),
                          onTap: () => {
                            setState(() {
                              hideBottomPart = !hideBottomPart;
                            })
                          },
                        ),
                        Container(
                          child: Column(
                            children: [
                              Text("Trip distance:"),
                              Text("1km"),
                            ],
                          ),
                          width: MediaQuery.of(context).size.width / 2 - 20,
                        )
                      ],
                    ),
                    chartData.isNotEmpty && !hideBottomPart
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: 170,
                            child: SfCartesianChart(
                              zoomPanBehavior: _zoomPanBehavior,
                              tooltipBehavior: _tooltipBehavior,
                              primaryXAxis: NumericAxis(
                                rangePadding: ChartRangePadding.round,
                                labelAlignment: LabelAlignment.end,
                                autoScrollingDelta: 5,
                                interval: 10,
                                autoScrollingMode: AutoScrollingMode.end,
                                visibleMinimum: 0,
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                ),
                                visibleMaximum:
                                    chartData.isNotEmpty ? distance : 2,
                                interactiveTooltip: const InteractiveTooltip(
                                    // Displays the x-axis tooltip
                                    enable: true,
                                    borderColor: Colors.red,
                                    borderWidth: 2),
                              ),
                              primaryYAxis: NumericAxis(
                                // minimum: 0.0,
                                //maximum: 100.0,
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                ),
                                decimalPlaces: 0,
                                labelAlignment: LabelAlignment.center,
                              ),
                              series: <ChartSeries>[
                                // Renders spline chart
                                //Use SplineAreaSeries if you want to color area below spline
                                SplineAreaSeries<ChartData, double>(
                                    onRendererCreated:
                                        (ChartSeriesController controller) {
                                      _chartSeriesController = controller;
                                    },
                                    color:
                                        const Color.fromARGB(255, 34, 132, 37),
                                    dataSource: chartData,
                                    //enableTooltip: true,
                                    splineType: SplineType.natural,
                                    cardinalSplineTension: 0.5,
                                    //markerSettings: const MarkerSettings(
                                    //  isVisible: true,
                                    /// shape: DataMarkerType.diamond,
                                    // borderColor: Colors.black,
                                    //),
                                    xValueMapper: (ChartData data, _) =>
                                        data.distance,
                                    yValueMapper: (ChartData data, _) =>
                                        data.elevation),
                                //animationDuration: 1000
                              ],
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LatLng get _center {
    final bounds = item.offlineRegionDefinition.bounds;
    final lat = (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    final lng = (bounds.southwest.longitude + bounds.northeast.longitude) / 2;
    return LatLng(lat, lng);
  }
}
