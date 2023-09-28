import 'package:equatable/equatable.dart';

class MapClass extends Equatable {
  final String? id;
  final String? summaryPolyline;
  final int? resourceState;

  const MapClass({
    this.id,
    this.summaryPolyline,
    this.resourceState,
  });

  @override
  List<Object?> get props => [id, summaryPolyline, resourceState];
}
