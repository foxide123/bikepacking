import 'dart:math';

import 'package:maplibre_gl/maplibre_gl.dart';

double haversineDistance(List<double> pointA, List<double> pointB) {
  var deltaLat = _toRadians(pointB[0] - pointA[0]);
  var deltaLong = _toRadians(pointB[1] - pointA[1]);
  var a = pow(sin(deltaLat / 2), 2) +
      cos(_toRadians(pointA[0])) *
          cos(_toRadians(pointB[0])) *
          pow(sin(deltaLong / 2), 2);
  var greatCircleDistance = 2 * atan2(sqrt(a), sqrt(1 - a));
  return 6371.0 * greatCircleDistance; // Radius of the Earth in miles
}

double _toRadians(double degree) {
  return degree * pi / 180;
}

double trackDistance(List<LatLng> polylinesLatLng) {
  if (polylinesLatLng.isEmpty) return 0.0;

  double totalDistance = 0.0;
  for (int i = 0; i < polylinesLatLng.length - 1; i++) {
    totalDistance += haversineDistance(
        [polylinesLatLng[i].latitude, polylinesLatLng[i].longitude],
        [polylinesLatLng[i + 1].latitude, polylinesLatLng[i + 1].longitude]);
  }

  return totalDistance;
}
