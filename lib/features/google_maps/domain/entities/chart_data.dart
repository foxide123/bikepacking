import 'package:equatable/equatable.dart';

class ChartData extends Equatable {
  final double? elevation;
  final double? distance;
  ChartData({this.elevation, this.distance});

  @override
  List<Object?> get props => [elevation, distance];
}
