import 'package:maplibre_gl/maplibre_gl.dart';

Future<Symbol> addPolylineToMap(
    MaplibreMapController mapController, List<LatLng> polylinesLatLng) async {
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

  return Future.value(symbols![0]);
}
