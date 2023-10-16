import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

final bounds = LatLngBounds(
  southwest: const LatLng(40.69, -74.03),
  northeast: const LatLng(40.84, -73.86),
);
final regionDefinition = OfflineRegionDefinition(
  bounds: bounds,
  mapStyleUrl:
      "https://tiles.stadiamaps.com/styles/outdoors.json?api_key=5ff0622d-7374-4d5e-9e17-274be21bdac0",
  minZoom: 6,
  maxZoom: 14,
);

class MaplibreMapPage extends StatefulWidget {

  const MaplibreMapPage({
    super.key});

  @override
  State<MaplibreMapPage> createState() => _MaplibreMapPageState();
}

class _MaplibreMapPageState extends State<MaplibreMapPage> {
  String styleUrl = "https://tiles.stadiamaps.com/styles/outdoors.json";
  String apiKey = "5ff0622d-7374-4d5e-9e17-274be21bdac0";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MaplibreMap(
          styleString: "$styleUrl?api_key=$apiKey",
          myLocationEnabled: true,
          initialCameraPosition:
              const CameraPosition(target: LatLng(55.869312, 9.888437), zoom: 10),
          trackCameraPosition: true,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: ElevatedButton(child: Text("Offline"),
          onPressed: (){
            GoRouter.of(context).push("/maplibreOffline");
          },),
        )
      ],
    );
  }
}
