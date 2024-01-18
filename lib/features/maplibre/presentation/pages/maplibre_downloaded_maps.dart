import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MaplibreDownloadedMaps extends StatefulWidget {
  const MaplibreDownloadedMaps({super.key});

  @override
  State<MaplibreDownloadedMaps> createState() => _MaplibreDownloadedMapsState();
}

class _MaplibreDownloadedMapsState extends State<MaplibreDownloadedMaps> {
  MaplibreMapController? mapController;
  Circle? _selectedCircle;

  LatLng? currentDraggableFeaturePosition;
  List<List<double>> draggableCirclesCoord = [];
  List<List<double>>? newlyAddedFillCoord;
  LatLng? northEast;
  LatLng? southWest;

  @override
  void initState() {
    super.initState();
  }

  var fillLayerProperties = const FillLayerProperties(
    fillColor: 'rgba(255, 0, 0, 0)', // Completely transparent fill
    fillOpacity: 0, // You can also use 0 opacity
  );

  var lineLayerProperties = const LineLayerProperties(
    lineColor: '#ff0000', // Red border, for example
    lineWidth: 2.0, // Width of the border
  );

  var circleLayerProperties = const CircleLayerProperties(circleRadius: 10);

  Map<String, dynamic> fills = {
    "type": "FeatureCollection",
    "features": <Map<String, dynamic>>[]
  };

  Map<String, dynamic> newFill = {
    "type": "FeatureCollection",
    "features": <Map<String, dynamic>>[]
  };

  late LatLng circleCoordNorthEast;
  late LatLng circleCoordSouthWest;

  Future<void> getListOfDownloadedRegions() async {
    List<OfflineRegion> offlineRegions = await getListOfRegions();
    int id = 1;
    for (var region in offlineRegions) {
      String regionName = region.metadata['name'];
      LatLngBounds regionBounds = region.definition.bounds;
      LatLng northEast = regionBounds.northeast;
      LatLng southWest = regionBounds.southwest;
      LatLng northWest = LatLng(northEast.latitude, southWest.longitude);
      LatLng southEast = LatLng(southWest.latitude, northEast.longitude);

      List<List<double>> polygonCoordinates = [
        [northWest.longitude, northWest.latitude],
        [northEast.longitude, northEast.latitude],
        [southEast.longitude, southEast.latitude],
        [southWest.longitude, southWest.latitude],
        [northWest.longitude, northWest.latitude]
      ];

      if (polygonCoordinates.isNotEmpty) {
        print(polygonCoordinates);
        Map<String, dynamic> newFeature = {
          "type": "Feature",
          "id": id,
          "properties": <String, dynamic>{'id': id},
          "geometry": {
            "type": "Polygon",
            "coordinates": [polygonCoordinates],
          }
        };
        (fills["features"] as List<Map<String, dynamic>>).add(newFeature!);
        id++;
      }
    }
    await paintPolygonWithBorder(fills, "region");
  }

  Future<void> paintPolygonWithBorder(
      Map<String, dynamic> fills, String regionName) async {
    try {
      if (mapController != null) {
        await mapController!
            .addSource(regionName, GeojsonSourceProperties(data: fills));

        await mapController!.addFillLayer(
            regionName, '${regionName}_fillId', fillLayerProperties);

        await mapController!.addLineLayer(
            regionName, '${regionName}_lineId', lineLayerProperties);
      }
    } catch (e) {
      print("EXCEPTION $e");
    }
  }

  void addNewFill() async {
    LatLng target = mapController!.cameraPosition!.target;
    List<double> northEast = [target.latitude + 0.5, target.longitude + 0.5];
    List<double> southWest = [target.latitude - 0.5, target.longitude - 0.5];
    List<double> northWest = [target.latitude + 0.5, target.longitude - 0.5];
    List<double> southEast = [target.latitude - 0.5, target.longitude + 0.5];

    int featureId = 150;

    List<List<double>> coordinates = [
      [northWest[1], northWest[0]],
      [northEast[1], northEast[0]],
      [southEast[1], southEast[0]],
      [southWest[1], southWest[0]],
      [northWest[1], northWest[0]]
    ];

    newlyAddedFillCoord = coordinates;

    List<List<double>> corners = [
      //[northWest[1], northWest[0]],
      [northEast[1], northEast[0]],
      //[southEast[1], southEast[0]],
      [southWest[1], southWest[0]],
      // [northWest[1], northWest[0]]
    ];

    circleCoordNorthEast = LatLng(northEast[0], northEast[1]);
    circleCoordSouthWest = LatLng(southWest[0], southWest[1]);

    for (int i = 0; i < 2; i++) {
      Circle circle = await mapController!.addCircle(
        CircleOptions(
          draggable: true,
          circleRadius: 20,
          geometry: LatLng(corners[i][1], corners[i][0]),
        ),
      );
      draggableCirclesCoord.add([circle.options.geometry!.latitude, circle.options.geometry!.longitude]);
    }

    Map<String, dynamic> newFeature = {
      "type": "Feature",
      "id": 160,
      "properties": <String, dynamic>{'id': 160},
      "geometry": {
        "type": "Polygon",
        "coordinates": [coordinates],
      }
    };
    setState(() {
      (newFill["features"] as List<Map<String, dynamic>>).add(newFeature);
    });

    await mapController!.addGeoJsonSource('newRegion', newFill);

    await mapController!.addLineLayer('newRegion', 'newRegion_lineLayer',
        LineLayerProperties(lineColor: '#ff0000', lineWidth: 2));
  }

  /* void addNewPolygon() async {
    LatLng target = mapController!.cameraPosition!.target;
    List<double> northEast = [target.latitude + 0.5, target.longitude + 0.5];
    List<double> southWest = [target.latitude - 0.5, target.longitude - 0.5];
    List<double> northWest = [target.latitude + 0.5, target.longitude - 0.5];
    List<double> southEast = [target.latitude - 0.5, target.longitude + 0.5];

    int featureId = 150;

    List<List<double>> coordinates = [
      [northWest[1], northWest[0]],
      [northEast[1], northEast[0]],
      [southEast[1], southEast[0]],
      [southWest[1], southWest[0]],
      [northWest[1], northWest[0]]
    ];

    Map<String, dynamic> newFeature = {
      "type": "Feature",
      "id": featureId,
      "properties": <String, dynamic>{'id': featureId},
      "geometry": {
        "type": "Polygon",
        "coordinates": [coordinates],
      }
    };

    (newFill["features"] as List<Map<String, dynamic>>).add(newFeature);

    for (int i = 0; i < 4; i++) {
      Map<String, dynamic> newCircleFeature = {
        "type": "Feature",
        "id": featureId + i + 1,
        "properties": <String, dynamic>{'id': featureId + i + 1},
        "geometry": {
          "type": "Point",
          "coordinates": [coordinates[i][1], coordinates[i][0]],
        }
      };

      setState(() {
        (newFill["features"] as List<Map<String, dynamic>>)
            .add(newCircleFeature);
      });
    }

    await mapController!.addGeoJsonSource('newRegion', newFill);

    await mapController!.addCircleLayer(
        'newRegion',
        'newRegion_circleLayer',
        CircleLayerProperties(
            circleRadius: 10, circleColor: 'rgba(255, 255, 255, 50)'));

    await mapController!.addLineLayer('newRegion', 'newRegion_lineLayer',
        LineLayerProperties(lineColor: '#ff0000', lineWidth: 2));

    await mapController!.addFillLayer('newRegion', 'newRegion_fillLayer',
        FillLayerProperties(fillColor: 'rgba(255, 0, 0, 0)'));

    /*mapController!.setGeoJsonFeature('newRegion', {
      "type": "Feature",
      "id": 150,
      "properties": <String, dynamic>{'id': 150},
      "geometry": {
        "type": "Polygon",
        "coordinates": [newCoordinates],
      }
    });*/
  }*/

  void _onMapCreated(MaplibreMapController controller) {
    if (mounted) {
      setState(() {
        mapController = controller;
        mapController!.onFeatureTapped.add(onFeatureTap);
        mapController!.onFeatureDrag.add(onFeatureDrag);
        //mapController!.onCircleTapped.add(_onCircleTapped);
      });
    }
  }

  void onFeatureTap(dynamic featureId, Point<double> point, LatLng latLng) {
    if (featureId != null) {
      Map<String, dynamic>? tappedFeature = _findFeatureById(featureId);
      print("Tapped feature: $tappedFeature");
      if (tappedFeature != null) {
        List<dynamic> featureCoordinates =
            tappedFeature['geometry']['coordinates'][0];
        print("feature coordinates: $featureCoordinates");
        List<double> extremeCoordinates =
            findExtremePoints(featureCoordinates as List<List<double>>);
        print("extreme coordinates: $extremeCoordinates");
        mapController!.setCameraBounds(
          west: extremeCoordinates[0],
          south: extremeCoordinates[1],
          east: extremeCoordinates[2],
          north: extremeCoordinates[3],
          padding: 25,
        );

        final snackBar = SnackBar(
          content: Text(
            'Tapped feature with id $featureId at coordinates: $featureCoordinates',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).primaryColor,
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  void onFeatureDrag(dynamic featureId,
      {required LatLng current,
      required LatLng delta,
      required DragEventType eventType,
      required LatLng origin,
      required Point<double> point}) {
    if (featureId != null) {
      print("Current position of draggable feature: $current");
      print("Origin: $origin");
      print("delta: $delta");
      print("Point: $point");
      print("FEATURE ID: $featureId");
      

      currentDraggableFeaturePosition = current;
      if (newlyAddedFillCoord != null) {
        //only if northEast is null
        northEast??= LatLng(newlyAddedFillCoord![1][0], newlyAddedFillCoord![1][1]);
        southWest??=
            LatLng(newlyAddedFillCoord![3][0], newlyAddedFillCoord![3][1]);

        print("Newly added fill coord: ${newlyAddedFillCoord![1][1]}");
        print("origin latitude: ${origin.latitude}");

        if(draggableCirclesCoord.length == 2){
          if((current.latitude - draggableCirclesCoord![0][0]) < (current.latitude - draggableCirclesCoord[1][0])){
            northEast = LatLng(current.longitude, current.latitude);
            draggableCirclesCoord[0][0] = current.latitude;
            draggableCirclesCoord[0][1] = current.longitude;
          }

        }

        List<List<double>> coordinates = [
          [newlyAddedFillCoord![0][0], newlyAddedFillCoord![0][1]],
          [northEast!.latitude, northEast!.longitude],
          [newlyAddedFillCoord![2][0], newlyAddedFillCoord![2][1]],
          [southWest!.latitude, southWest!.longitude],
          [newlyAddedFillCoord![4][0], newlyAddedFillCoord![4][1]],
        ];

        newlyAddedFillCoord = coordinates;

        mapController!.setGeoJsonFeature('newRegion', {
        "type": "Feature",
        "id": 160,
        "properties": <String, dynamic>{'id': 160},
        "geometry": {
          "type": "Polygon",
          "coordinates": [coordinates],
        }
      });
      }

      print("eventType: $eventType");
      double latDiff = current.latitude - current.latitude;
      double lonDiff = current.longitude - current.longitude;

      /*   for (var i = 0; i < circles.length; i++) {
        var currentCircle = circles[i];
        var newLatLng = LatLng(
          currentCircle.options.geometry!.latitude + latDiff,
          currentCircle.options.geometry!.longitude + lonDiff,
        );

        CircleOptions newCircleOptions = CircleOptions(
          geometry: newLatLng,
          circleRadius: currentCircle.options.circleRadius,
          circleColor: currentCircle.options.circleColor,
        );
        mapController!.updateCircle(currentCircle, newCircleOptions);
        circles[i].options = newCircleOptions;
      } */
    }
  }

  Map<String, dynamic>? _findFeatureById(dynamic featureId) {
    print("featureId: $featureId");
    for (var feature in fills['features']) {
      var featureIdInt = int.tryParse(featureId.toString());
      var currentFeatureIdInt = int.tryParse(feature['id'].toString());
      print(currentFeatureIdInt);
      if (featureIdInt == currentFeatureIdInt) {
        print("Found feature");
        return feature;
      }
    }
    for (var feature in newFill['features']) {
      var featureIdInt = int.tryParse(featureId.toString());
      var currentFeatureIdInt = int.tryParse(feature['id'].toString());
      print(currentFeatureIdInt);
      if (featureIdInt == currentFeatureIdInt) {
        print("Found feature");
        return feature;
      }
    }
    return null;
  }

  /*void _onCircleTapped(Circle circle) {
    if (_selectedCircle != null) {
      _updateSelectedCircle(
        const CircleOptions(circleRadius: 60),
      );
    }
    setState(() {
      _selectedCircle = circle;
    });
    _updateSelectedCircle(
      const CircleOptions(
        circleRadius: 30,
      ),
    );
  }

  void _updateSelectedCircle(CircleOptions changes) {
    mapController!.updateCircle(_selectedCircle!, changes);
  }
*/
  List<double> findExtremePoints(List<List<double>> coordinates) {
    double northernmost = coordinates[0][1]; // latitude
    double southernmost = coordinates[0][1]; // latitude
    double easternmost = coordinates[0][0]; // longitude
    double westernmost = coordinates[0][0]; // longitude

    for (var coord in coordinates) {
      double longitude = coord[0];
      double latitude = coord[1];

      if (latitude > northernmost) {
        northernmost = latitude;
      }
      if (latitude < southernmost) {
        southernmost = latitude;
      }
      if (longitude > easternmost) {
        easternmost = longitude;
      }
      if (longitude < westernmost) {
        westernmost = longitude;
      }
    }

    return [westernmost, southernmost, easternmost, northernmost];
  }

  void _onStyleLoadedCallback() async {
    await getListOfDownloadedRegions();
    if (mapController != null) {
      final ByteData bytes = await rootBundle.load("assets/marker_circle.png");
      final Uint8List list = bytes.buffer.asUint8List();
      mapController!.addImage("marker_circle", list);
    }
  }

  double _currentSliderValue = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          MaplibreMap(
            trackCameraPosition: true,
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoadedCallback,
            styleString:
                'https://api.maptiler.com/maps/streets/style.json?key=TsGpFIpUcx6qiUpVLjDh',
            initialCameraPosition: CameraPosition(
              target: LatLng(53.892708, 9.827990),
              zoom: 5,
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            width: 60,
            height: 60,
            child: GestureDetector(
              child: Column(
                children: [
                  Container(
                    child: Icon(FontAwesomeIcons.plus,
                        size: 40, color: Colors.blue),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  /*Container(child: 
                  Icon(FontAwesomeIcons.check),),
                  Container(
                    child: Icon(FontAwesomeIcons.ban),
                  )*/
                ],
              ),
              onTap: () => {
                if (mapController != null) {addNewFill()}
              },
            ),
          ),
          Positioned(
            bottom: 100,
            left: 30,
            child: Slider(
              max: 100,
              divisions: 5,
              value: _currentSliderValue,
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 30,
            child: Row(children: [
              Container(
                child: Icon(FontAwesomeIcons.plus),
                decoration: BoxDecoration(color: Colors.white),
                width: 60,
                height: 80,
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                child: Icon(FontAwesomeIcons.minus),
                decoration: BoxDecoration(color: Colors.white),
                width: 60,
                height: 80,
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                child: Icon(FontAwesomeIcons.trash),
                decoration: BoxDecoration(color: Colors.white),
                width: 60,
                height: 80,
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                child: Column(
                  children: [
                    Icon(FontAwesomeIcons.map),
                    Text(
                      "Open selected map",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
                decoration: BoxDecoration(color: Colors.white),
                width: 100,
              ),
            ]),
          )
          /*Positioned(top: 50, right: 50,
           child: TextButton(
          onPressed: () async {
            if(mapController != null){
              await mapController!.setCameraBounds(
              west: 5.98865807458,
              south: 47.3024876979,
              east: 15.0169958839,
              north: 54.983104153,
              padding: 25,
            );
            }
          },
          child: const Text('Set bounds to Germany'),
        ),),*/
        ],
      ),
    );
  }
}
