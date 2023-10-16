import 'dart:convert';
import 'dart:io';

import 'package:bikepacking/features/strava/data/data_sources/strava_local_data_source.dart';
import 'package:bikepacking/features/strava/data/data_sources/strava_remote_data_source.dart';
import 'package:bikepacking/features/strava/domain/repository/i_strava_repository.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class StravaRepository implements IStravaRepository {
  final StravaLocalDataSource localDataSource;
  final StravaRemoteDataSource remoteDataSource;

  StravaRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  authenticate() async {
    remoteDataSource.authenticate();
  }

  @override
  Future<String> exchangeCodeForTokens(String scope, String code) async {
    //final code = await localDataSource.getAuthCode();
    final Map<String, dynamic> map = await remoteDataSource.getTokens(code);
    final accessToken = map['access_token'];
    final refreshToken = map['refresh_token'];
    final expiresIn = map['expires_in'];
    final athlete = map['athlete'];

    //print("REPOSITORY - EXPIRES IN : $expiresIn");

    DateTime now = DateTime.now();
    DateTime tokenExpiryDateTime = now.add(Duration(seconds: expiresIn));

    localDataSource.cacheAccessToken(accessToken);
    localDataSource.cacheRefreshToken(refreshToken);
    localDataSource
        .cacheExpirationDate(tokenExpiryDateTime.toUtc().toIso8601String());
    return accessToken;
  }

  @override
  getProfile() async{
    final token = await localDataSource.getAccessToken();
    final profile = await remoteDataSource.getProfile(token); 
    print("STRAVA_REPOSITORY: $profile");
    return profile; 
  }

  @override
  getRoutes(int id) async{
    final token = await localDataSource.getAccessToken();
    return remoteDataSource.getRoutes(id, token);
  }

  @override
  Future<String> getAccessToken() async{
    return await localDataSource.getAccessToken();
  }

  @override
  Future<String> getExpirationDate() async {
    final expDate = await localDataSource.getExpirationDate();
    if (expDate == null) {
      return Future.value("");
    } else {
      return Future.value(expDate);
    }
  }

  @override
  Future<String> replaceTokensOnExpiry() async {
    final refreshToken = await localDataSource.getRefreshToken();
    final Map<String, dynamic> map =
        await remoteDataSource.getNewAccessToken(refreshToken);
    final newAccessToken = map['access_token'];
    final newRefreshToken = map['refresh_token'];
    final expiresIn = map['expires_in'];

    DateTime now = DateTime.now();
    DateTime tokenExpiryDateTime = now.add(Duration(seconds: expiresIn));

    localDataSource.cacheAccessToken(newAccessToken);
    localDataSource.cacheRefreshToken(newRefreshToken);
    localDataSource
        .cacheExpirationDate(tokenExpiryDateTime.toUtc().toIso8601String());
    
    return Future.value(newAccessToken);
  }
  
  @override
  downloadRoute(int id, String routeName) async{
    final token = await localDataSource.getAccessToken();
    return await remoteDataSource.downloadRoute(id, token);
  }

}
