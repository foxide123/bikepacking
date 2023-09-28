import 'package:bikepacking/features/strava/domain/enities/route.dart';
import 'package:bikepacking/features/strava/domain/repository/i_strava_repository.dart';

class StravaLogic{

  const StravaLogic(this._repository);

  final IStravaRepository _repository;

  Future<String> authenticateUser() async{
    if(await _repository.getExpirationDate() != "" && await _repository.getExpirationDate() != null){
      DateTime currentDateTime = DateTime.now();
      String expirationString = await _repository.getExpirationDate();
     // print("EXPIRATION STRING: $expirationString");
      if(currentDateTime.isAfter(DateTime.parse(expirationString))){
        return await _repository.replaceTokensOnExpiry();
      }else{
        return await _repository.getAccessToken();
      }
    }else{
       _repository.authenticate();
    }
    return "";
  }

  Future<String> exchangeCodeForTokens(String scope, String code) async{
    if(await _repository.getExpirationDate() != "" && await _repository.getExpirationDate() != null){
      DateTime currentDateTime = DateTime.now();
      String expirationString = await _repository.getExpirationDate();
      //print("EXPIRATION STRING: $expirationString");
      if(currentDateTime.isAfter(DateTime.parse(expirationString))){
        return await _repository.replaceTokensOnExpiry();
      }else{
        return await _repository.getAccessToken();
      }
    }else{
       return _repository.exchangeCodeForTokens(scope, code);
    }
  }

  getProfile() async{
    if(await _repository.getExpirationDate() != "" && await _repository.getExpirationDate() != null){
      DateTime currentDateTime = DateTime.now();
      String expirationString = await _repository.getExpirationDate();
      if(currentDateTime.isAfter(DateTime.parse(expirationString))){
        await _repository.replaceTokensOnExpiry();
        return await _repository.getProfile();
      }else{
        final profile = await _repository.getProfile();
        print("STRAVA_LOGIC: $profile");
        return await profile;
      }
    }else{
      _repository.authenticate();
    }
  }

  getRoutes(int id) async{
    if(await _repository.getExpirationDate() != "" && await _repository.getExpirationDate() != null){
      DateTime currentDateTime = DateTime.now();
      String expirationString = await _repository.getExpirationDate();
      if(currentDateTime.isAfter(DateTime.parse(expirationString))){
        await _repository.replaceTokensOnExpiry();
        final profile =  await _repository.getProfile();
        if(profile.id == 0){
          _repository.authenticate();
        }
        return await _repository.getRoutes(profile.id);
      }else{
        final routes = await _repository.getRoutes(id);
        return routes;
      }
    }else{
      _repository.authenticate();
      return [];
    }
  }

  downloadRoute(int id) async{
    DateTime currentDateTime = DateTime.now();
      String expirationString = await _repository.getExpirationDate();

    _repository.downloadRoute(id);
  }
  
}