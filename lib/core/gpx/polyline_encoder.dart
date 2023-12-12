import 'dart:math';

import 'package:maplibre_gl/maplibre_gl.dart';

String encodePolyline(List<LatLng> coordinates) {
  String encodedString = '';
  int prevLat = 0;
  int prevLng = 0;

  for (final coordinate in coordinates) {
    int lat = (coordinate.latitude * 1e5).round();
    int lng = (coordinate.longitude * 1e5).round();

    int dLat = lat - prevLat;
    int dLng = lng - prevLng;

    encodedString += _encode(dLat) + _encode(dLng);

    prevLat = lat;
    prevLng = lng;
  }

  return encodedString;
}

String _encode(int value) {
  value = value < 0 ? ~(value << 1) : (value << 1);
  String encoded = '';
  while (value >= 0x20) {
    encoded += String.fromCharCode((0x20 | (value & 0x1f)) + 63);
    value >>= 5;
  }
  encoded += String.fromCharCode(value + 63);
  return encoded;
}
