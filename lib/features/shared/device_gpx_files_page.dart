import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:bikepacking/core/gpx/max_min_extract.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_bloc.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_event.dart';
import 'package:bikepacking/features/maplibre/presentation/bloc/maplibre_state.dart';
import 'package:bikepacking/features/shared/gpx_file_widget.dart';
import 'package:bikepacking/features/strava/domain/enities/athlete.dart';
import 'package:bikepacking/features/strava/presentation/bloc/bloc/strava_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;

class DeviceGpxFilesPage extends StatefulWidget {

  const DeviceGpxFilesPage({
    super.key});

  @override
  State<DeviceGpxFilesPage> createState() => _DeviceGpxFilesPageState();
}

class _DeviceGpxFilesPageState extends State<DeviceGpxFilesPage> {
  Directory? downloadsDirectory;
  Iterable<FileSystemEntity> downloadDirFiles = [];
  Iterable<FileSystemEntity> filePickerFiles = [];
  List<String> fileNames = [];
  List<String> donwloadedMaps = [];
  Map<String, String> mapOfFiles = HashMap();
  FileSystemEntity? gpxFile;
  String content = '';
  List<LatLng>? coordinates;
  double? minLat;
  double? maxLat;
  double? minLon;
  double? maxLon;

  String token = "";
  int athleteId = 0;
  late Athlete athlete;
  List<dynamic> stravaRoutes = [];

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
    if(downloadDirFiles.isEmpty){
      getExternalDownloadsDirectory();
    }
    super.initState();
  }

  Future<Directory?> getExternalDownloadsDirectory() async {
    Directory? externalDirectory = await getExternalStorageDirectory();
    print("EXTERNAL STORAGE: $externalDirectory");
    if (externalDirectory != null) {
      downloadsDirectory = Directory('/storage/emulated/0/Download');
      listOfFiles();
    }
  }

  void listOfFiles() async {
    List<FileSystemEntity> allFiles = downloadsDirectory!.listSync();
    downloadDirFiles = allFiles.where((file) => file.path.endsWith('.gpx'));
    filePickerFiles =
        (Directory('/data/user/0/com.example.bikepacking/cache/file_picker/')
            .listSync()
            .where((file) => file.path.endsWith('.gpx')));
    String fileName;
    List<OfflineRegion> offlineRegions = await getListOfRegions();

    if (downloadDirFiles.isNotEmpty) {
      downloadDirFiles.forEach((file) => {
            fileName = p.basename(file.path),
            setState(() {
              fileNames.add(fileName);
              mapOfFiles.addAll({fileName: file.path});
            }),
            if (offlineRegions
                .any((element) => element.metadata['name'] == fileName))
              {
                setState(() {
                  donwloadedMaps.add(fileName);
                })
              }
          });
    }
    if (filePickerFiles.isNotEmpty) {
      filePickerFiles.forEach((file) => {
            fileName = p.basename(file.path),
            setState(() {
              fileNames.add(fileName);
              mapOfFiles.addAll({fileName: file.path});
            }),
            if (offlineRegions
                .any((element) => element.metadata['name'] == fileName))
              {
                setState(() {
                  donwloadedMaps.add(fileName);
                })
              }
          });
    }
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

  Future<bool> displayDownloadConfirmationDialog() async {
    return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Download Map?'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Do you want to download the map for this route?'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(false); // User chooses not to download
                    },
                  ),
                  TextButton(
                    child: Text('Download'),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(true); // User confirms to download
                    },
                  ),
                ],
              );
            }) ??
        false;
  }

  _downloadOfflineRegion(String fileName) async {
    Map<String, double> coordinates = await extractBounds(content!);
    minLat = coordinates['minLat'];
    maxLat = coordinates['maxLat'];
    minLon = coordinates['minLon'];
    maxLon = coordinates['maxLon'];

    List<OfflineRegion> offlineRegions = await getListOfRegions();
    final offlineRegion = offlineRegions.firstWhere(
        (offlineRegion) => offlineRegion.metadata['name'] == fileName,
        orElse: () => fakeOfflineRegion);
    if (offlineRegion.id == -1) {
      bool confirmDownload = await displayDownloadConfirmationDialog();
      if (confirmDownload) {
        print("OFFLINE REGION IS -1");
        BlocProvider.of<MaplibreBloc>(context).add(
          DownloadOfflineMap(
              minLat: coordinates['minLat']!,
              maxLat: coordinates['maxLat']!,
              minLon: coordinates['minLon']!,
              maxLon: coordinates['maxLon']!,
              routeName: fileName,
              mapType: "streets"),
        );
      }
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

  void authenticate(context) {
    BlocProvider.of<StravaBloc>(context).add(AuthenticateUser());
  }

  void getProfile() {
    BlocProvider.of<StravaBloc>(context).add(GetProfile());
  }

  void getRoutes(int athleteId) {
    BlocProvider.of<StravaBloc>(context).add(GetRoutes(athleteId: athleteId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Color(0xFFBA704F),
      body: MultiBlocListener(
        listeners: [
          BlocListener<MaplibreBloc, MaplibreState>(
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
          ),
          BlocListener<StravaBloc, StravaState>(
            listener: (context, state) {
        if (state is AccessTokenRetrieved) {
          getProfile();
          print("STATE.TOKEN ${state.token}");
          setState(() {
            token = state.token;
          });
        }
        if (state is ProfileRetrieved) {
          getRoutes(state.athlete.id!);
          print("ID in home_page ${state.athlete.id}");
          setState(() {
            athleteId = state.athlete.id!;
            athlete = state.athlete;
          });
        }
        if (state is RoutesRetrieved) {
          print("Routes from strava: ${state.routes}");
          setState(() {
            stravaRoutes = state.routes;
          });
          state.routes.forEach((route)=>{
            if(route.name!=null){
              fileNames.add(route.name!)
            }else{
              fileNames.add(route.id.toString())
            }
            //route.map.summaryPolyline
          });
        }
      },
          )
        ],
            child: Column(
                children: [
                  SizedBox(height: 20),
                  Text("Device gpx files",
                      style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => pickFiles(),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.brown,
                      ),
                      child: Icon(FontAwesomeIcons.plus, size: 20),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 50,
                        color: Colors.brown,
                        child: Text(
                          "From device",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          child: Image.asset(
                            "assets/btn_strava_connectwith_orange.png",
                            width: 150,
                          ),
                        ),
                        onTap: () {
                          authenticate(context);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  fileNames.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: fileNames.length,
                              itemBuilder: (context, index) {
                                bool isMapDownloaded =
                                    donwloadedMaps.contains(fileNames[index])
                                        ? true
                                        : false;
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 8.0, 10.0, 8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      image: const DecorationImage(
                                        image: AssetImage(
                                            "assets/container_rusty_background.png"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: GestureDetector(
                                        child: GpxFileWidget(
                                            name: fileNames[index],
                                            isMapDownloaded: isMapDownloaded),
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
                      : SizedBox() /*Container(
                                child: GestureDetector(
                                    child: Text("Choose file"), onTap: () => pickFiles()),
                              ),*/
                  //Text(content),
                ],
              ),
      ),
    );
  }
}
