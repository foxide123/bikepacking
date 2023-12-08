import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:bikepacking/core/max_min_extract.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_bloc.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_event.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_state.dart';
import 'package:bikepacking/features/shared/gpx_file_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;

class DeviceGpxFilesPage extends StatefulWidget {
  const DeviceGpxFilesPage({super.key});

  @override
  State<DeviceGpxFilesPage> createState() => _DeviceGpxFilesPageState();
}

class _DeviceGpxFilesPageState extends State<DeviceGpxFilesPage> {
  Directory? downloadsDirectory;
  Iterable<FileSystemEntity> downloadFiles = [];
  Iterable<FileSystemEntity> filePickerFiles = [];
  List<String> fileNames = [];
  Map<String, String> mapOfFiles = HashMap();
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
    downloadFiles = allFiles.where((file) => file.path.endsWith('.gpx'));
    filePickerFiles =
        (Directory('/data/user/0/com.example.bikepacking/cache/file_picker/')
            .listSync()
            .where((file) => file.path.endsWith('.gpx')));
    String fileName;
    if(downloadFiles.isNotEmpty){
       downloadFiles.forEach((file) => {
          fileName = p.basename(file.path),
          setState(() {
            fileNames.add(fileName);
            mapOfFiles.addAll({fileName: file.path});
          })
        });
    }
    if(filePickerFiles.isNotEmpty){
      filePickerFiles.forEach((file) => {
          fileName = p.basename(file.path),
          setState(() {
            fileNames.add(fileName);
            mapOfFiles.addAll({fileName: file.path});
          })
        });
    }

    // gpxFile = files.firstWhere((file) => file.path.contains('maps_horsens'),
    //    orElse: () => File(''));

    //readFileContent();
    //print(files);
    //print("GPX FILE: $gpxFile");
  }

  void readFileContent(String filePath) async {
    final file = File(filePath);
    try {
      content = await file.readAsString();
      print("FILE CONTENT: $content");
    } catch (e) {
      print("Error reading file: $e");
    }

    _downloadOfflineRegion(p.basename(filePath));
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

  _downloadOfflineRegion(String fileName) async {
    Map<String, double> coordinates = await extractBounds(content!);
    minLat = coordinates['minLat']!;
    maxLat = coordinates['maxLat']!;
    minLon = coordinates['minLon']!;
    maxLon = coordinates['maxLon']!;

    List<OfflineRegion> offlineRegions = await getListOfRegions();
    final offlineRegion = offlineRegions.firstWhere(
        (offlineRegion) => offlineRegion.metadata['name'] == fileName,
        orElse: () => fakeOfflineRegion);
    if (offlineRegion.id == -1) {
      print("OFFLINE REGION IS -1");
      BlocProvider.of<MaplibreBloc>(context).add(
        DownloadOfflineMap(
            minLat: coordinates['minLat']!,
            maxLat: coordinates['maxLat']!,
            minLon: coordinates['minLon']!,
            maxLon: coordinates['maxLon']!,
            routeName: fileName),
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

  void pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Allow multiple file selection
    );

    if (result != null) {
      // Process the list of files
      for (var file in result.files) {
        if (file.extension == "gpx") {
          print(file.name);
          print(file.path);
          setState(() {
            fileNames.add(file.name);
            mapOfFiles.addAll({file.name: file.path!});
          });
        } else {
          print("Wrong format!");
        }
      }
    } else {
      // User canceled the picker
      print("User canceled the picker");
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
              fileNames.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: fileNames.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                color: Colors.blue,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GestureDetector(
                                    child:
                                        GpxFileWidget(name: fileNames[index]),
                                    onTap: () {
                                      if (mapOfFiles
                                          .containsKey(fileNames[index]))
                                        readFileContent(
                                            mapOfFiles[fileNames[index]]!);
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                    )
                  : Container(
                      child: GestureDetector(
                          child: Text("Choose file"), onTap: () => pickFiles()),
                    ),
              //Text(content),
            ],
          );
        },
      ),
    );
  }
}
