import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:xml/xml.dart';

List<LatLng> gpxToCoordinates(String gpxContent){
  final document = XmlDocument.parse(gpxContent!);
    final trkpts = document.findAllElements('trkpt');

    return trkpts.map((trkpt) {
      final lat = double.parse(trkpt.getAttribute('lat')!);
      final lon = double.parse(trkpt.getAttribute('lon')!);
      return LatLng(lat, lon);
    }).toList();
}