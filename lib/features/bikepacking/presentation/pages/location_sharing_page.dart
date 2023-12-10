import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationSharingPage extends StatefulWidget {
  const LocationSharingPage({super.key});

  @override
  State<LocationSharingPage> createState() => _LocationSharingPageState();
}

class _LocationSharingPageState extends State<LocationSharingPage> {


  double lat = 0;
  double lon = 0;

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position =  await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
        setState(() {
          lat = position.latitude;
    lon = position.longitude;
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            lat!=0&&lon!=0 ? Text("Your current location is: ${lat}, ${lon}") : SizedBox(),
            ElevatedButton(onPressed: () {}, child: Text("Share location")),
            TextField(
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Add new contact",
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16.0,
                    color: Colors.black,
                  )),
              style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ));
  }
}
