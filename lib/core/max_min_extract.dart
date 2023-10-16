import 'package:xml/xml.dart';

Future<Map<String, double>> extractBounds(String gpxContents) async {
  try{
    final document = XmlDocument.parse(gpxContents);
    final trkpts = document.findAllElements('trkpt');

  double maxLat = double.negativeInfinity;
  double minLat = double.infinity;
  double maxLon = double.negativeInfinity;
  double minLon = double.infinity;

  for (var trkpt in trkpts) {
    final lat = double.parse(trkpt.getAttribute('lat')!);
    final lon = double.parse(trkpt.getAttribute('lon')!);

    if (lat > maxLat) maxLat = lat;
    if (lat < minLat) minLat = lat;
    if (lon > maxLon) maxLon = lon;
    if (lon < minLon) minLon = lon;
  }

  return {
    'maxLat': maxLat,
    'minLat': minLat,
    'maxLon': maxLon,
    'minLon': minLon,
  };
  }catch(e){
    print("EXCEPTION PARSING gpxContents: $e");
    return {};
  }
}