import 'package:bikepacking/features/maplibre/domain/entities/offline_region_list_item.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

OfflineRegionListItem createOfflineRegionListItem(String regionId, String minLat, String maxLat,
String minLon, String maxLon, String routeName){
  return OfflineRegionListItem(
      downloadedId: int.parse(regionId),
      isDownloading: false,
      offlineRegionDefinition: OfflineRegionDefinition(
          bounds: LatLngBounds(
              southwest: LatLng(
                  double.parse(minLat), double.parse(minLon)),
              northeast: LatLng(
                  double.parse(maxLat), double.parse(maxLon))),
          mapStyleUrl:
              //'https://tiles.stadiamaps.com/styles/outdoors.json?api_key=5ff0622d-7374-4d5e-9e17-274be21bdac0',
              'https://api.maptiler.com/maps/streets/style.json?key=TsGpFIpUcx6qiUpVLjDh',
          minZoom: 10,
          maxZoom: 16),
      name: routeName,
      estimatedTiles: 0,
    );
}