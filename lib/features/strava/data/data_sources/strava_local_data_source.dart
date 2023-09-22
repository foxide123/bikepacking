import 'package:bikepacking/core/local_storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StravaLocalDataSource{
  final SharedPreferences sharedPreferences;
  
  StravaLocalDataSource({required this.sharedPreferences});

  Future<String> getAccessToken(){
    final token = sharedPreferences.getString(LS_access_token);
    if(token != null){
      return Future.value(token);
    }else{
      throw Exception();
    }
  }

  Future<void> cacheAccessToken(String token){
    return sharedPreferences.setString(LS_access_token, token);
  }

  Future<String> getRefreshToken(){
    final token = sharedPreferences.getString(LS_refresh_token);
    if(token != null){
      return Future.value(token);
    }else{
      throw Exception();
    }
  }

  Future<void> cacheRefreshToken(String token){
    return sharedPreferences.setString(LS_refresh_token, token);
  }

  Future<String> getAuthCode(){
    final token = sharedPreferences.getString(LS_auth_code);
    if(token != null){
      return Future.value(token);
    }else{
      throw Exception();
    }
  }

  Future<void> cacheAuthCode(String code){
    return sharedPreferences.setString(LS_auth_code, code);
  }

  Future<String> getExpirationDate(){
    final expDate = sharedPreferences.getString(LS_token_expiration);
    if(expDate != null){
      return Future.value(expDate);
    }else{
      return Future.value("");
    }
  }

  Future<void> cacheExpirationDate(String dateTime){
    return sharedPreferences.setString(LS_token_expiration, dateTime);
  }
}