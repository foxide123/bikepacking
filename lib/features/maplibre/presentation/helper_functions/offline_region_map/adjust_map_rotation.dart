import 'package:maplibre_gl/maplibre_gl.dart';

void adjustMapRotation(double? direction, MaplibreMapController mapController, List<LatLng> polylinesLatLng) {
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
          target: mapController!.cameraPosition!.target,
          zoom: mapController!.cameraPosition!.zoom,
          tilt: mapController!.cameraPosition!.tilt,
          bearing: direction, // Set map bearing to compass direction
        ),
      ),
    );
    } else {
      print("adjustMapRotation - null");
    }
  }