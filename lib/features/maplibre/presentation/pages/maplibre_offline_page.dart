import 'package:bikepacking/features/maplibre/domain/entities/offline_region_list_item.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MaplibreOfflinePage extends StatefulWidget {
  const MaplibreOfflinePage({super.key});

  @override
  State<MaplibreOfflinePage> createState() => _MaplibreOfflinePageState();
}

class _MaplibreOfflinePageState extends State<MaplibreOfflinePage> {
  final List<OfflineRegionListItem> _items = [];

  final bounds = LatLngBounds(
    southwest: const LatLng(55.817631, 9.778315),
    northeast: const LatLng(55.925179, 9.991465),
  );

  late final regionDefinition;
  double downloadProgress = 0;

  late OfflineRegionListItem regionToDownload;
  late int indexToDownload;
  late int downloadedRegionId;

  @override
  void initState() {
    regionDefinition = OfflineRegionDefinition(
        bounds: bounds, mapStyleUrl: _mapStyleUrl(), minZoom: 6, maxZoom: 14);
    regionToDownload = OfflineRegionListItem(
      offlineRegionDefinition: regionDefinition,
      downloadedId: null,
      isDownloading: false,
      name: "Horsens",
      estimatedTiles: 3580,
    );
    _updateListOfRegions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                indexToDownload = 0;

                _download();
              },
              child: Text("Download"),
            ),
            ElevatedButton(
              onPressed: () {

              },
              child: Text("Open"),
            ),
            Text(downloadProgress.toString()),
          ],
        ));
  }

  _mapStyleUrl() {
    return "https://api.maptiler.com/maps/streets/style.json?key=TsGpFIpUcx6qiUpVLjDh";
    //return "https://tiles.stadiamaps.com/styles/alidade_smooth_dark.json?api_key=5ff0622d-7374-4d5e-9e17-274be21bdac0";
  }

  _updateListOfRegions() async {
    List<OfflineRegion> offlineRegions = await getListOfRegions();
    print("LIST OF REGIONS ${offlineRegions[5]}");
  }

  _download() async {
    final region = await downloadOfflineRegion(regionDefinition,
        metadata: {
          'name': 'Horsens',
        },
        onEvent: _onDownloadEvent);
    downloadedRegionId = region.id;
  }

  void _onDownloadEvent(DownloadRegionStatus status) {
    if (status is Success) {
      setState(() {
        if (_items.isNotEmpty) {
          _items.removeAt(indexToDownload);
        }
        _items.insert(
            indexToDownload,
            regionToDownload.copyWith(
              isDownloading: false,
              downloadedId: downloadedRegionId,
            ));
        downloadProgress = 100;
      });

      // Update your UI, display a StackBar notification, etc.
    } else if (status is Error) {
      setState(() {
        // Update some state variables in the widget to indicate the download failed,
        // reset progress indicators, etc.
      });

      // Update your UI, display a StackBar notification, etc.
    } else if (status is InProgress) {
      setState(() {
        // Update state, such as a download progress indicator. The reported values are
        // in the range 0-100, so you'll need to divide by 100 to use with many standard
        // progress widgets.
        downloadProgress = status.progress / 100;
      });
    }
  }
}