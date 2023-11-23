import 'package:bikepacking/features/maplibre/data/repository/maplibre_repository.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

typedef DownloadEventCallback = void Function(DownloadRegionStatus status);

class MaplibreLogic{
  final MaplibreRepository _repository;

  const MaplibreLogic(this._repository);

  downloadOfflineMap(double minLat, double maxLat, double minLon, double maxLon, String routeName) async{
    OfflineRegionDefinition offlineRegionDefinition = OfflineRegionDefinition(
      bounds: LatLngBounds(southwest: LatLng(minLat, minLon), northeast: LatLng(maxLat, maxLon)),
      mapStyleUrl: "https://tiles.stadiamaps.com/styles/alidade_smooth_dark.json?api_key=5ff0622d-7374-4d5e-9e17-274be21bdac0", 
      minZoom: 6, 
      maxZoom: 10);
    final region = await downloadOfflineRegion(offlineRegionDefinition,
        metadata: {
          'name': routeName,
        });
    return region.id;
  }
}