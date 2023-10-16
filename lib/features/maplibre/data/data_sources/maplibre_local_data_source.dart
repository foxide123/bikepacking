import 'package:shared_preferences/shared_preferences.dart';

class MaplibreLocalDataSource{
  final SharedPreferences sharedPreferences;

  MaplibreLocalDataSource({required this.sharedPreferences});
}