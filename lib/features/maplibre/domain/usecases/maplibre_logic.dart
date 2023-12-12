import 'package:bikepacking/features/maplibre/data/repository/maplibre_repository.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

typedef DownloadEventCallback = void Function(DownloadRegionStatus status);

class MaplibreLogic {
  final MaplibreRepository _repository;

  const MaplibreLogic(this._repository);

  downloadOfflineMap(double minLat, double maxLat, double minLon, double maxLon,
      String routeName, String mapType) async {
    assert(minLat <= maxLat, 'minLat should be less than or equal to maxLat');
    assert(minLon <= maxLon, 'minLon should be less than or equal to maxLon');

    String mapStyleUrl =
        "https://api.maptiler.com/maps/streets/style.json?key=TsGpFIpUcx6qiUpVLjDh";
    String type = "streets";

    if (mapType == "outdoor") {
      mapStyleUrl =
          "https://api.maptiler.com/maps/outdoor/style.json?key=TsGpFIpUcx6qiUpVLjDh";
    } else if (mapType == "satellite") {
      mapStyleUrl =
          "https://api.maptiler.com/maps/satellite/style.json?key=TsGpFIpUcx6qiUpVLjDh";
    }
    OfflineRegionDefinition offlineRegionDefinition = OfflineRegionDefinition(
      bounds: LatLngBounds(
          southwest: LatLng(minLat, minLon), northeast: LatLng(maxLat, maxLon)),
      mapStyleUrl: mapStyleUrl,
      //mapStyleUrl: "https://tiles.stadiamaps.com/styles/alidade_smooth_dark.json?api_key=5ff0622d-7374-4d5e-9e17-274be21bdac0",
      minZoom: 6,
      maxZoom: 10,
    );
    final region =
        await downloadOfflineRegion(offlineRegionDefinition, metadata: {
      'name': routeName,
    });
    return region.id;
  }
}
