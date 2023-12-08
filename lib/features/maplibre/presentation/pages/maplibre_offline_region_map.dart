import 'dart:math';
import 'dart:typed_data';

import 'package:bikepacking/core/gpx_distance_calculator.dart';
import 'package:bikepacking/core/polyline_encoder.dart';
import 'package:bikepacking/features/google_maps/domain/entities/chart_data.dart';
import 'package:bikepacking/features/google_maps/domain/entities/elevation_class.dart';
import 'package:bikepacking/features/google_maps/presentation/bloc/bloc/google_maps_bloc.dart';
import 'package:bikepacking/features/maplibre/domain/entities/offline_region_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:xml/xml.dart';

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

  @override
  void initState() {
    item = OfflineRegionListItem(
      downloadedId: int.parse(widget.regionId),
      isDownloading: false,
      offlineRegionDefinition: OfflineRegionDefinition(
          bounds: LatLngBounds(
              southwest: LatLng(
                  double.parse(widget.minLat), double.parse(widget.minLon)),
              northeast: LatLng(
                  double.parse(widget.maxLat), double.parse(widget.maxLon))),
          mapStyleUrl:
              //'https://tiles.stadiamaps.com/styles/outdoors.json?api_key=5ff0622d-7374-4d5e-9e17-274be21bdac0',
              'https://api.maptiler.com/maps/streets/style.json?key=TsGpFIpUcx6qiUpVLjDh',
          minZoom: 10,
          maxZoom: 16),
      name: widget.routeName,
      estimatedTiles: 0,
    );

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
      if (mapController != null && polylinesLatLng.isNotEmpty) {
        mapController?.addLine(
          LineOptions(
            geometry: polylinesLatLng,
            lineColor: "#ff0000",
            lineWidth: 5.0,
            lineOpacity: 0.5,
          ),
        );
        List<Symbol>? symbols = await mapController?.addSymbols([
          SymbolOptions(
            geometry: polylinesLatLng[0],
            iconImage: 'arrow-icon',
            iconSize: 0.2,
          ),
          SymbolOptions(
            geometry: polylinesLatLng[polylinesLatLng.length - 1],
            iconImage: 'flag-checkered',
            iconSize: 0.2,
          )
        ]);
        addedSymbol = symbols![0];
      }

      updateMarkerPosition();
    } catch (e) {
      print("EXCEPTION $e");
    }
  }

  void adjustMapRotation(double? direction) {
    if (mapController != null && direction != null) {
      double mapBearing = mapController!.cameraPosition!.bearing;
      double adjustedRotation = direction - mapBearing;

      // Adjust to keep the value between 0 to 360
      if (adjustedRotation >= 360) {
        adjustedRotation -= 360;
      } else if (adjustedRotation < 0) {
        adjustedRotation += 360;
      }

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: polylinesLatLng[0], // maintain current target/center
            zoom: 10, // maintain current zoom
            bearing: adjustedRotation +
                180, // set bearing to the direction the marker is facing
          ),
        ),
      );
    } else {
      print("adjustMapRotation - null");
    }
  }

  void extractCoordinatesFromGPX() async {
    final document = XmlDocument.parse(widget.gpxContent!);
    final trkpts = document.findAllElements('trkpt');

    polylinesLatLng = trkpts.map((trkpt) {
      final lat = double.parse(trkpt.getAttribute('lat')!);
      final lon = double.parse(trkpt.getAttribute('lon')!);
      return LatLng(lat, lon);
    }).toList();

    setState(() {
      distance = trackDistance(polylinesLatLng);
    });
    // Split the list into chunks of 500 and encode each chunk.
    String encodedPolyline = '';
    if (polylinesLatLng.length > 500) {
      List<LatLng> tempList = [];
      for (int i = 0; i < polylinesLatLng.length; i++) {
        if (i == 0) tempList.add(polylinesLatLng[i]);
        if (i == polylinesLatLng.length - 1) {
          tempList.add(polylinesLatLng[i - 1]);
          continue;
        }
        if (i % 50 == 0) {
          tempList.add(polylinesLatLng[i]);
        }
      }
      encodedPolyline = encodePolyline(tempList);
      /* int numOfChunks = (polylinesLatLng.length / 500).ceil();
      for (int i = 0; i < numOfChunks; i++) {
        // Calculate the start and end indices for the sublist
        int start = 500 * i;
        int end = min(
            start + 500,
            polylinesLatLng
                .length); // Ensure we don't go past the end of the list
        // Encode the chunk and add it to the list of encoded polylines
        encodedPolylines
            .add(encodePolyline(polylinesLatLng.sublist(start, end)));
      }*/
    } else {
      // If the list is smaller than 500, just encode the entire list
      encodedPolyline = encodePolyline(polylinesLatLng);
    }

      getElevation(
          encodedPolyline); // getElevation should accept a List<String>
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
    FlutterCompass.events!.listen((CompassEvent event) {
      print(event.heading);
      event.headingForCameraMode;
      compassDirection = event.heading;
      updateMarkerDirection(compassDirection);
    });
  }

  void _onMapCreated(MaplibreMapController controller) async {
    setState(() {
      mapController = controller;
    });

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

  void updateMarkerDirection(double? direction) {
    if (mapController != null && direction != null && addedSymbol != null) {
      double mapBearing = mapController!.cameraPosition!.bearing;
      double adjustedRotation = direction - mapBearing;

      // Adjust to keep the value between 0 to 360
      if (adjustedRotation >= 360) {
        adjustedRotation -= 360;
      } else if (adjustedRotation < 0) {
        adjustedRotation += 360;
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
              trackCameraPosition: true,
              myLocationEnabled: true,
              onCameraIdle: () async {
                print("on camera idle");
                if (mapController != null) {
                  print('mapController is not null');
                }
                if (mapController?.cameraPosition != null) {
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
                ElevatedButton(
                    onPressed: () {
                      adjustMapRotation(mapController!.cameraPosition!.bearing);
                    },
                    child: Text("Center"))
              ],
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: 200,
                color: Colors.blue,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Text(distance.toString()),
                    chartData.isNotEmpty
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: 180,
                            child: SfCartesianChart(
                              zoomPanBehavior: _zoomPanBehavior,
                              tooltipBehavior: _tooltipBehavior,
                              primaryXAxis: NumericAxis(
                                rangePadding: ChartRangePadding.round,
                                labelAlignment: LabelAlignment.end,
                                autoScrollingDelta: 5,
                                interval: 10,
                                autoScrollingMode: AutoScrollingMode.end,
                                interactiveTooltip: const InteractiveTooltip(
                                    // Displays the x-axis tooltip
                                    enable: true,
                                    borderColor: Colors.red,
                                    borderWidth: 2),
                              ),
                              primaryYAxis: NumericAxis(
                                // minimum: 0.0,
                                //maximum: 100.0,
                                decimalPlaces: 0,
                                labelAlignment: LabelAlignment.center,
                              ),
                              series: <ChartSeries>[
                                // Renders spline chart
                                //Use SplineAreaSeries if you want to color area below spline
                                SplineSeries<ChartData, double>(
                                    onRendererCreated:
                                        (ChartSeriesController controller) {
                                      _chartSeriesController = controller;
                                    },
                                    //color - provide color for area
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
