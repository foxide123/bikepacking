import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:bikepacking/features/maplibre/domain/entities/offline_region_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
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
              'https://tiles.stadiamaps.com/styles/outdoors.json?api_key=5ff0622d-7374-4d5e-9e17-274be21bdac0',
          minZoom: 10,
          maxZoom: 18),
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
            geometry: polylinesLatLng[polylinesLatLng.length-1],
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
          zoom: 16, // maintain current zoom
          bearing: adjustedRotation+180, // set bearing to the direction the marker is facing
        ),
      ),
    );
  }else{
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
    ByteData byteDataFinishLine = await rootBundle.load("assets/flag-checkered-solid.png");
    Uint8List uint8List = byteData.buffer.asUint8List();
    Uint8List uint8ListFinishLine = byteDataFinishLine.buffer.asUint8List();
    mapController?.addImage('arrow-icon', uint8List);
    mapController?.addImage('flag-checkered', uint8ListFinishLine);
  }

  double adjustedCompassDirection(double? direction) {
    if (direction == null) return 0.0;
    return direction >= 0 ? direction : 360 + direction;
  }

 void updateMarkerDirection(double? direction){
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          MaplibreMap(
            trackCameraPosition: true,
            myLocationEnabled: true,
            onCameraIdle: () async{
              print("on camera idle");
              if(mapController !=null){
                print('mapController is not null');
              }
              if (mapController?.cameraPosition != null) {
                print('Camera Position after camera movement stops: ${mapController!.cameraPosition!.bearing}');
              }else{
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
                  ElevatedButton(onPressed: (){
                    adjustMapRotation(mapController!.cameraPosition!.bearing);
                  }, child: Text("Center"))
            ],
          ),
              
        ],
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
