import 'package:maplibre_gl/maplibre_gl.dart';

class OfflineRegionListItem {
  OfflineRegionListItem({
    required this.offlineRegionDefinition,
    required this.downloadedId,
    required this.isDownloading,
    required this.name,
    required this.estimatedTiles,
  });

  final OfflineRegionDefinition offlineRegionDefinition;
  final int? downloadedId;
  final bool isDownloading;
  final String name;
  final int estimatedTiles;

  OfflineRegionListItem copyWith({
    int? downloadedId,
    bool? isDownloading,
  }) =>
      OfflineRegionListItem(
        offlineRegionDefinition: offlineRegionDefinition,
        name: name,
        estimatedTiles: estimatedTiles,
        downloadedId: downloadedId,
        isDownloading: isDownloading ?? this.isDownloading,
      );

  bool get isDownloaded => downloadedId != null;
}