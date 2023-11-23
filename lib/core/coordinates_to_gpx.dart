import 'dart:io';

import 'package:bikepacking/features/google_maps/domain/entities/coordinates_class.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class CoordinatesToGpx {
  static void convertWaypointsToGPX(List<CoordinatesClass> waypoints) {
    StringBuffer sb = StringBuffer();

    sb.writeln('<?xml version="1.0" encoding="UTF-8" standalone="no" ?>');
    sb.writeln(
        '<gpx xmlns="http://www.topografix.com/GPX/1/1" creator="YourAppName" version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">');

    sb.writeln('<trk>');
    sb.writeln('<name>Route</name>');
    sb.writeln('<trkseg>');

    for (var point in waypoints) {
      sb.writeln('<trkpt lat="${point.lat}" lon="${point.lon}"></trkpt>');
    }

    sb.writeln('</trkseg>');
    sb.writeln('</trk>');
    sb.writeln('</gpx>');

    print(sb.toString());
    externalFolder(sb.toString());
  }

  static externalFolder(String gpxContent) async {
    if (await Permission.manageExternalStorage.isGranted) {
      final path = Directory('/storage/emulated/0/Download');
      String res = "";

      if (await path.exists()) {
        res = path.path;
      } else {
        final Directory appDocDirNewFolder = await path.create(recursive: true);
        res = appDocDirNewFolder.path;
      }

      final File file = File("$res/gpx_file.gpx");
      await file.writeAsString(gpxContent);
    } else {
      await Permission.manageExternalStorage.request();
    }
  }
}
