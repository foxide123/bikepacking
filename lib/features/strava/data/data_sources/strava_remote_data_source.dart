import 'dart:convert';

import 'package:bikepacking/core/strava_credentials.dart';
import 'package:bikepacking/features/strava/data/models/athlete_model.dart';
import 'package:bikepacking/features/strava/data/models/route_model.dart';
import 'package:bikepacking/features/strava/domain/enities/athlete.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class StravaRemoteDataSource {
  final http.Client client;

  StravaRemoteDataSource({required this.client});

  Future<void> authenticate() async {
    try {
      final uri = Uri.https(
        "www.strava.com",
        "/oauth/mobile/authorize",
        {
          //credentials class
          "client_id": stravaClientId,
          "redirect_uri": stravaRedirectUri,
          "response_type": stravaResponseType,
          "approval_prompt": stravaApprovalPrompt,
          "scope": stravaScope,
        },
      );
      if (await canLaunchUrl(Uri.parse(uri.toString()))) {
        await launchUrl(Uri.parse(uri.toString()));
      } else {
        print("Could not launch $uri");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Athlete> getProfile(String token) async {
    final response = await client.get(
      Uri.https('www.strava.com', '/api/v3/athlete'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 202) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      print("SUCCESSFUL RESPONSE BODY: $responseBody");
      final athlete = AthleteModel.fromJson(responseBody);
      return athlete;
    } else {
      print("ERROR: ${jsonDecode(response.body)}");
      return Athlete.empty();
    }
  }

  getRoutes(int id, String token) async {
    final response = await client.get(
      Uri.https("www.strava.com", "/api/v3/athletes/$id/routes"),
      headers: {
        'Authorization': 'Bearer $token',
      }
    );
    if(response.statusCode == 200 || response.statusCode == 202){
      final responseList = jsonDecode(response.body);
      final routeList = [];
      for(Map<String, dynamic> route in responseList){
        routeList.add(RouteModel.fromJson(route));
      }
      return routeList;
    }else{
      print("ERROR: ${response.body}");
    }
  }

  downloadRoute(int id, String token) async{
    final response = await client.get(
      Uri.https("www.strava.com", "/routes/${id}/export_gpx"),
      headers: {
        'Authorization': 'Bearer $token',
      }
    );
    print("RESPONSE BODY: ${response.body}");
    print(response.headers);
    print(response.statusCode);
    return response.body;
  }

  Future<Map<String, dynamic>> getTokens(String code) async {
    final uri = Uri.https(
      "www.strava.com",
      "/oauth/token",
      {
        "client_id": stravaClientId,
        "client_secret": stravaClientSecret,
        "code": code,
        "grant_type": "authorization_code",
      },
    );

    Response response = await post(uri);
    if (response.statusCode == 200 || response.statusCode == 202) {
      print('Status code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      String accessToken = responseBody['access_token'];
      String refreshToken = responseBody['refresh_token'];
      int expiresIn = responseBody['expires_in'];
      final athlete =
          AthleteModel.fromJson(json.decode(response.body)['athlete']);

      Map<String, dynamic> map = {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
        'athlete': athlete,
      };
      return map;
      // localDataSource.cacheAccessToken(token);
      //localDataSource.cache
      //prefs.setString('accessToken', accessToken);
      // prefs.setString('refreshToken', refreshToken);
    } else {
      print('Status code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
    }
    return {};
  }

  Future<Map<String, dynamic>> getNewAccessToken(String refreshToken) async {
    final uri = Uri.https(
      "www.strava.com",
      "/api/v3/oauth/token",
      {
        "client_id": stravaClientId,
        "client_secret": stravaClientSecret,
        "grant_type": "refresh_token",
        "refresh_token": refreshToken
      },
    );

    Response response = await post(uri);
    if (response.statusCode == 200 || response.statusCode == 202) {
      print('Status code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      String accessToken = responseBody['access_token'];
      String refreshToken = responseBody['refresh_token'];
      int expiresIn = responseBody['expires_in'];

      Map<String, dynamic> map = {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_in': expiresIn
      };
      return map;
      // localDataSource.cacheAccessToken(token);
      //localDataSource.cache
      //prefs.setString('accessToken', accessToken);
      // prefs.setString('refreshToken', refreshToken);
    } else {
      throw Exception();
    }
  }
}
