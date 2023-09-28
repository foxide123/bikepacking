import 'package:bikepacking/features/strava/domain/enities/route.dart';
import 'package:bikepacking/features/strava/presentation/bloc/bloc/strava_bloc.dart';
import 'package:bikepacking/features/strava/presentation/widgets/top_bar_back_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteDetails extends StatefulWidget {
  RouteClass? object;
  RouteDetails({super.key, this.object});

  @override
  State<RouteDetails> createState() => _RouteDetailsState();
}

class _RouteDetailsState extends State<RouteDetails> {
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylinesLatLng = [];
  late PolylineResult result;

  @override
  void initState() {
    super.initState();
    late List<PointLatLng> polylines =
        polylinePoints.decodePolyline(widget.object!.map!.summaryPolyline!);
    polylines.forEach((polyline) =>
        polylinesLatLng.add(LatLng(polyline.latitude, polyline.longitude)));

    //getRoute();
  }

  static LatLng sourceLocation = const LatLng(37.33500926, -122.03272188);
  static LatLng destinationLocation = const LatLng(37.33429383, -122.06600055);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarBackAction(),
      body: Column(
        children: [
          Container(
            height: 400,
            width: 400,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    polylinesLatLng[0].latitude, polylinesLatLng[0].longitude),
                zoom: 13.5,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: polylinesLatLng,
                  width: 6,
                ),
              },
            ),
          ),
          Image.network(widget.object!.mapUrls!.url!),
          Text(widget.object!.name!),
          Text(widget.object!.id!.toString()),
          Text((widget.object!.distance! / 1000).toString()),
          ElevatedButton(
            onPressed: () {
              launchMapsUrl(
                  "https://www.google.com/maps/dir/?api=1&origin=${polylinesLatLng[0].latitude},${polylinesLatLng[0].longitude}&destination=${polylinesLatLng[100].latitude},${polylinesLatLng[100].longitude}");
            },
            child: Text("OPEN GOOGLE MAPS"),
          ),
          SizedBox(height: 50),
          ElevatedButton(
              onPressed: () {
                downloadRoute(widget.object!.id!);
              },
              child: Text("DOWNLOAD"))
        ],
      ),
    );
  }

  void launchMapsUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void downloadRoute(int id) {
    BlocProvider.of<StravaBloc>(context).add(DownloadRoute(id: id));
  }
/*
  void getRoute() async{
    result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCIm0RKajmy5avqFn0q40e1oVyd1P5LdlY',
      PointLatLng(polylines[0].latitude, polylines[0].longitude),
      PointLatLng(polylines[polylines.length-1].latitude, polylines[polylines.length-1].longitude),
    );
  }
  */
}
