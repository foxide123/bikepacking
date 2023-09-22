import 'dart:convert';

import 'package:bikepacking/core/credentials.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class StravaRemoteDataSource{
  final http.Client client;

  StravaRemoteDataSource({required this.client});

  Future<void> authenticate()async {
    try{
      final uri = Uri.https(
      "www.strava.com",
      "/oauth/mobile/authorize",
      {
        //credentials class
        "client_id": clientId,
        "redirect_uri": redirectUri,
        "response_type": responseType,
        "approval_prompt": approvalPrompt,
        "scope": scope,
      },
    );
    if (await canLaunchUrl(Uri.parse(uri.toString()))) {
      await launchUrl(Uri.parse(uri.toString()));
    } else {
      print("Could not launch $uri");
    }
    }catch(e){
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> getTokens(String code) async{
    final uri = Uri.https(
      "www.strava.com",
      "/oauth/token",
      {
        "client_id": clientId,
        "client_secret": clientSecret,
        "code": code,
        "grant_type": "authorization_code",
      },
    );

    Response response = await post(uri);
    if (response.statusCode == 200 || response.statusCode==202) {
      print('Status code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      String accessToken = responseBody['access_token'];
      String refreshToken = responseBody['refresh_token'];
      int expiresIn = responseBody['expires_in'];

      Map<String, dynamic> map = {'access_token':accessToken, 'refresh_token': refreshToken, 'expires_in': expiresIn};
      return map;
     // localDataSource.cacheAccessToken(token);
      //localDataSource.cache
      //prefs.setString('accessToken', accessToken);
     // prefs.setString('refreshToken', refreshToken);
    }else{
      print('Status code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
    }
    return {};
  }

  Future<Map<String,dynamic>> getNewAccessToken(String refreshToken) async{
    final uri = Uri.https(
      "www.strava.com",
      "/api/v3/oauth/token",
      {
        "client_id": clientId,
        "client_secret": clientSecret,
        "grant_type": "refresh_token",
        "refresh_token": refreshToken
      },
    );

    Response response = await post(uri);
    if (response.statusCode == 200 || response.statusCode==202) {
      print('Status code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      String accessToken = responseBody['access_token'];
      String refreshToken = responseBody['refresh_token'];
      int expiresIn = responseBody['expires_in'];

      Map<String, dynamic> map = {'access_token':accessToken, 'refresh_token': refreshToken, 'expires_in': expiresIn};
      return map;
     // localDataSource.cacheAccessToken(token);
      //localDataSource.cache
      //prefs.setString('accessToken', accessToken);
     // prefs.setString('refreshToken', refreshToken);
    }else{
      throw Exception();
    }
  }
}