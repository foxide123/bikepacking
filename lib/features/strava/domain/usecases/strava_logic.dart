import 'dart:io';

import 'package:bikepacking/core/errors/failure.dart';
import 'package:bikepacking/core/strava_local_notifications.dart';
import 'package:bikepacking/features/strava/domain/enities/route.dart';
import 'package:bikepacking/features/strava/domain/repository/i_strava_repository.dart';
import 'package:dart_either/dart_either.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class StravaLogic {
  const StravaLogic(this._repository);

  final IStravaRepository _repository;

  Future<String> authenticateUser() async {
    if (await _repository.getExpirationDate() != "" &&
        await _repository.getExpirationDate() != null) {
      DateTime currentDateTime = DateTime.now();
      String expirationString = await _repository.getExpirationDate();
      // print("EXPIRATION STRING: $expirationString");
      if (currentDateTime.isAfter(DateTime.parse(expirationString))) {
        return await _repository.replaceTokensOnExpiry();
      } else {
        return await _repository.getAccessToken();
      }
    } else {
      _repository.authenticate();
    }
    return "";
  }

  Future<String> exchangeCodeForTokens(String scope, String code) async {
    if (await _repository.getExpirationDate() != "" &&
        await _repository.getExpirationDate() != null) {
      DateTime currentDateTime = DateTime.now();
      String expirationString = await _repository.getExpirationDate();
      //print("EXPIRATION STRING: $expirationString");
      if (currentDateTime.isAfter(DateTime.parse(expirationString))) {
        return await _repository.replaceTokensOnExpiry();
      } else {
        return await _repository.getAccessToken();
      }
    } else {
      return _repository.exchangeCodeForTokens(scope, code);
    }
  }

  getProfile() async {
    if (await _repository.getExpirationDate() != "" &&
        await _repository.getExpirationDate() != null) {
      DateTime currentDateTime = DateTime.now();
      String expirationString = await _repository.getExpirationDate();
      if (currentDateTime.isAfter(DateTime.parse(expirationString))) {
        await _repository.replaceTokensOnExpiry();
        return await _repository.getProfile();
      } else {
        final profile = await _repository.getProfile();
        print("STRAVA_LOGIC: $profile");
        return await profile;
      }
    } else {
      _repository.authenticate();
    }
  }

  Future<Either<Failure, List<RouteClass>>> getRoutes(int id) async {
    if (await _repository.getExpirationDate() != "" &&
        await _repository.getExpirationDate() != null) {
      DateTime currentDateTime = DateTime.now();
      String expirationString = await _repository.getExpirationDate();
      if (currentDateTime.isAfter(DateTime.parse(expirationString))) {
        await _repository.replaceTokensOnExpiry();
        final profile = await _repository.getProfile();
        if (profile.id == 0) {
          _repository.authenticate();
        }
        return _repository.getRoutes(profile.id);
      } else {
        return _repository.getRoutes(id);
      }
    } else {
      _repository.authenticate();
      return Left(RetrievingFailure(message: "Failure retrieving routes. Expiration Date null", statusCode: 500));
    }
  }

  downloadRoute(int id, String routeName) async {
    DateTime currentDateTime = DateTime.now();
    String expirationString = await _repository.getExpirationDate();

    final gpxContent = await _repository.downloadRoute(id, routeName);

    if (await Permission.manageExternalStorage.isGranted) {
      final File file = File("/storage/emulated/0/Download/${routeName}.gpx");
      await file.writeAsString(gpxContent);
    } else {
      await Permission.manageExternalStorage.request();
    }

    NotificationService().showNotification(
        title: 'GPX Download',
        body: 'Successfuly downloaded gpx file to "Downloads" folder');

    return gpxContent;
  }
}
