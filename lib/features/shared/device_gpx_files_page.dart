import 'dart:io';
import 'dart:math';

import 'package:bikepacking/core/max_min_extract.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_bloc.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_event.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

class DeviceGpxFilesPage extends StatefulWidget {
  const DeviceGpxFilesPage({super.key});

  @override
  State<DeviceGpxFilesPage> createState() => _DeviceGpxFilesPageState();
}

class _DeviceGpxFilesPageState extends State<DeviceGpxFilesPage> {
  Directory? downloadsDirectory;
  Iterable<FileSystemEntity> files = [];
  FileSystemEntity? gpxFile;
  String content = '';
  List<LatLng>? coordinates;
  double? minLat;
  double? maxLat;
  double? minLon;
  double? maxLon;

  final fakeOfflineRegion = OfflineRegion(
      id: -1,
      definition: OfflineRegionDefinition(
          bounds:
              LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0)),
          mapStyleUrl: '',
          minZoom: 0,
          maxZoom: 0),
      metadata: {});

  @override
  void initState() {
    getExternalDownloadsDirectory();
    super.initState();
  }

  Future<Directory?> getExternalDownloadsDirectory() async {
    Directory? externalDirectory = await getExternalStorageDirectory();
    print("EXTERNAL STORAGW: $externalDirectory");
    if (externalDirectory != null) {
      downloadsDirectory = Directory('/storage/emulated/0/Download');
      listOfFiles();
    }
  }

  void listOfFiles() {
    List<FileSystemEntity> allFiles = downloadsDirectory!.listSync();
    files = allFiles.where((file) => file.path.endsWith('.gpx'));
    gpxFile = files.firstWhere((file) => file.path.contains('maps_horsens'),
        orElse: () => File(''));

    readFileContent();
    print(files);
    print("GPX FILE: $gpxFile");
  }

  void readFileContent() async {
    final file = File(gpxFile!.path);
    try {
      content = await file.readAsString();
      print("FILE CONTENT: $content");
    } catch (e) {
      print("Error reading file: $e");
    }
    _downloadOfflineRegion();
  }

  Future<List<LatLng>> extractCoordinatesFromGPX(File gpxFile) async {
  final document = XmlDocument.parse(await gpxFile.readAsString());
  final trkpts = document.findAllElements('trkpt');

  return trkpts.map((trkpt) {
    final lat = double.parse(trkpt.getAttribute('lat')!);
    final lon = double.parse(trkpt.getAttribute('lon')!);
    return LatLng(lat, lon);
  }).toList();
}


  _downloadOfflineRegion() async {
    Map<String, double> coordinates = await extractBounds(content!);
    minLat = coordinates['minLat']!;
    maxLat = coordinates['maxLat']!;
    minLon = coordinates['minLon']!;
    maxLon = coordinates['maxLon']!;

    List<OfflineRegion> offlineRegions = await getListOfRegions();
    final offlineRegion = offlineRegions.firstWhere(
        (offlineRegion) => offlineRegion.metadata['name'] == 'maps_horsens.gpx',
        orElse: () => fakeOfflineRegion);
    if (offlineRegion.id == -1) {
      print("OFFLINE REGION IS -1");
      BlocProvider.of<MaplibreBloc>(context).add(
        DownloadOfflineMap(
            minLat: coordinates['minLat']!,
            maxLat: coordinates['maxLat']!,
            minLon: coordinates['minLon']!,
            maxLon: coordinates['maxLon']!,
            routeName: 'maps_horsens.gpx'),
      );
    } else {
      print("OFFLINE REGION IS ${offlineRegion.id}");
      GoRouter.of(context)
          .pushNamed('maplibreOfflineRegionMap', pathParameters: {
        'regionId': offlineRegion.id.toString(),
        'minLat': minLat.toString(),
        'maxLat': maxLat.toString(),
        'minLon': minLon.toString(),
        'maxLon': maxLon.toString(),
        'routeName': 'maps_horsens.gpx',
        'summaryPolyline': 'empty',
        'gpxContent': content,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<MaplibreBloc, MaplibreState>(
        listener: (context, state) {
          if (state is DownloadSuccessState) {
          GoRouter.of(context)
              .pushNamed('maplibreOfflineRegionMap', pathParameters: {
            'regionId': state.regionId.toString(),
            'minLat': minLat.toString(),
            'maxLat': maxLat.toString(),
            'minLon': minLon.toString(),
            'maxLon': maxLon.toString(),
            'routeName': 'maps_horsens.gpx',
            'summaryPolyline': 'empty',
            'gpxContent': content
          });
        }
        },
        builder: (context, state) {
          return Column(
            children: [
              Text("Device gpx files page"),
              Text(content),
            ],
          );
        },
      ),
    );
  }
}
