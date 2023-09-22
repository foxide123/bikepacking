import 'dart:convert';

import 'package:bikepacking/core/credentials.dart';
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
  exchangeCodeForTokens(String scope, String code) async {
    //final code = await localDataSource.getAuthCode();
    final Map<String, dynamic> map = await remoteDataSource.getTokens(code);
    final accessToken = map['access_token'];
    final refreshToken = map['refresh_token'];
    final expiresIn = map['expires_in'];

    print("REPOSITORY - EXPIRES IN : $expiresIn");

    DateTime now = DateTime.now();
    DateTime tokenExpiryDateTime = now.add(Duration(seconds: expiresIn));

    localDataSource.cacheAccessToken(accessToken);
    localDataSource.cacheRefreshToken(refreshToken);
    localDataSource
        .cacheExpirationDate(tokenExpiryDateTime.toUtc().toIso8601String());
  }

  @override
  Future<String> getAccessToken() async{
    return await localDataSource.getAccessToken();
  }

  @override
  Map<String, dynamic> getTokens() {
    final accessToken = localDataSource.getAccessToken();
    final refreshToken = localDataSource.getRefreshToken();
    return {"access_token": accessToken, "refresh_token": refreshToken};
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

}
