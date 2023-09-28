import 'package:equatable/equatable.dart';

class MapUrls extends Equatable {
  final String? url;
  final String? retinaUrl;

  const MapUrls({
    this.url,
    this.retinaUrl
  });

  @override
  List<Object?> get props => [url, retinaUrl];
}
