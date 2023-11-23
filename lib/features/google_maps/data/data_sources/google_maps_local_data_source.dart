import 'package:shared_preferences/shared_preferences.dart';

class GoogleMapsLocalDataSource{
  final SharedPreferences sharedPreferences;
  
  GoogleMapsLocalDataSource({required this.sharedPreferences});
}