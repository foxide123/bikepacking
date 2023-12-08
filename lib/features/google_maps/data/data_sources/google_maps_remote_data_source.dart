import 'dart:convert';

import 'package:bikepacking/core/errors/failure.dart';
import 'package:bikepacking/features/google_maps/data/models/elevation_dao.dart';
import 'package:bikepacking/features/google_maps/domain/entities/coordinates_class.dart';
import 'package:bikepacking/features/google_maps/domain/entities/elevation_class.dart';
import 'package:dart_either/dart_either.dart';
import 'package:http/http.dart' as http;

class GoogleMapsRemoteDataSource {
  final http.Client client;

  GoogleMapsRemoteDataSource({required this.client});

  Future<Either<Failure, List<CoordinatesClass>>> getRouting(
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
          return Right(steps.map<CoordinatesClass>((step) {
            return CoordinatesClass(
                lat: step['start_location']['lat'],
                lon: step['start_location']['lng']);
          }).toList());
        }
      }
    } 
    return Left(NotFoundFailure(message: "Error when getting routing", statusCode: response.statusCode));
  }

  Future<Either<Failure, List<ElevationDAO>>> getElevation(String encodedPolyline) async{
    print("encodedPolyline: $encodedPolyline");
    List<ElevationDAO> elevationList = [];
       final response = await http.post(Uri.parse(
        "https://maps.googleapis.com/maps/api/elevation/json?locations=enc:$encodedPolyline&key=AIzaSyCIm0RKajmy5avqFn0q40e1oVyd1P5LdlY"));
      
      try{
        if(response.statusCode == 200){
        final data = json.decode(response.body);
        final results = data['results'];
        print("Results: $results");
        if(results.isNotEmpty){
          elevationList.addAll(results.map<ElevationDAO>((result){
            return ElevationDAO.fromJSON(result);
          }).toList());
        }
      }else{
        return Left(NotFoundFailure(message: response.body, statusCode: response.statusCode));
      }
      }catch(e){
        return Left(RetrievingFailure(message: e.toString(), statusCode: 500));
      }
    if(elevationList.isNotEmpty){
      return Right(elevationList);
    }else{
      return Left(RetrievingFailure(message: "Failure retrieving elevation profile", statusCode: 500));
    }
  }
}
