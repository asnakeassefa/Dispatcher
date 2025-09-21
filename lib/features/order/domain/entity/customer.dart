import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final double lat;
  final double lon;

  const Location({
    required this.lat,
    required this.lon,
  });

  @override
  List<Object?> get props => [lat, lon];
}

class Customer extends Equatable {
  final String id;
  final String name;
  final Location location;

  const Customer({
    required this.id,
    required this.name,
    required this.location,
  });

  @override
  List<Object?> get props => [id, name, location];
}
