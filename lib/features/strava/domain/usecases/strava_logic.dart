import 'package:bikepacking/features/strava/domain/repository/i_strava_repository.dart';

class StravaLogic{

  const StravaLogic(this._repository);

  final IStravaRepository _repository;

  Future<String> authenticateUser() async{
    if(await _repository.getExpirationDate() != "" && await _repository.getExpirationDate() != null){
      DateTime currentDateTime = DateTime.now();
      String expirationString = await _repository.getExpirationDate();
      print("EXPIRATION STRING: $expirationString");
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

  void exchangeCodeForTokens(String scope, String code) async{
    if(await _repository.getExpirationDate() != "" && await _repository.getExpirationDate() != null){
      DateTime currentDateTime = DateTime.now();
      String expirationString = await _repository.getExpirationDate();
      print("EXPIRATION STRING: $expirationString");
      if(currentDateTime.isAfter(DateTime.parse(expirationString))){
        _repository.replaceTokensOnExpiry();
      };
    }else{
       _repository.exchangeCodeForTokens(scope, code);
    }
  }
  
}