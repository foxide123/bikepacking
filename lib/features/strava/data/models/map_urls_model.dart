import 'package:bikepacking/features/strava/domain/enities/map_urls.dart';

class MapUrlsModel extends MapUrls {

  const MapUrlsModel({
    super.url,
    super.retinaUrl,
  });
  
  factory MapUrlsModel.fromJson(Map<String, dynamic> json) {
    return MapUrlsModel(
      url: json['url'],
      retinaUrl: json['retina_url']
    );
  }
}