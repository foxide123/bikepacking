import 'dart:convert';

import 'package:bikepacking/features/google_maps/domain/entities/coordinates_class.dart';
import 'package:http/http.dart' as http;

class GoogleMapsRemoteDataSource {
  final http.Client client;

  GoogleMapsRemoteDataSource({required this.client});

  Future<List<CoordinatesClass>> getRouting(
      String startLat, String startLon, String endLat, String endLon) async {
    final response = await http.post(Uri.parse(
        "https://maps.googleapis.com/maps/api/directions/json?destination=$startLat,$startLon&origin=$endLat,$endLon&key=AIzaSyCIm0RKajmy5avqFn0q40e1oVyd1P5LdlY"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routes = data['routes'];
      if (routes.isNotEmpty) {
        final legs = routes[0]['legs'];
        if (legs.isNotEmpty) {
          final steps = legs[0]['steps'];
          return steps.map<CoordinatesClass>((step) {
            return CoordinatesClass(
                lat: step['start_location']['lat'],
                lon: step['start_location']['lng']);
          }).toList();
        }
      }
    } else {
      throw Exception('Failed to fetch waypoints');
    }
    return [
      CoordinatesClass.empty()
    ];
  }
}
