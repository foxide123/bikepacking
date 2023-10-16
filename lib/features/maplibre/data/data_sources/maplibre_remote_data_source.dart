
import 'package:bikepacking/core/security/osm_credentials.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MaplibreRemoteDataSource{
  final http.Client client;

  MaplibreRemoteDataSource({required this.client});
}