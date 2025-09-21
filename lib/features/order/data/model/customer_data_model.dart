import 'package:equatable/equatable.dart';

import '../../domain/entity/customer.dart';

class LocationDataModel extends Equatable {
  final double lat;
  final double lon;

  const LocationDataModel({
    required this.lat,
    required this.lon,
  });

  factory LocationDataModel.fromJson(Map<String, dynamic> json) {
    return LocationDataModel(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
    };
  }

  // Map to domain entity
  Location toEntity() {
    return Location(
      lat: lat,
      lon: lon,
    );
  }

  @override
  List<Object?> get props => [lat, lon];
}

class CustomerDataModel extends Equatable {
  final String id;
  final String name;
  final LocationDataModel location;

  const CustomerDataModel({
    required this.id,
    required this.name,
    required this.location,
  });

  factory CustomerDataModel.fromJson(Map<String, dynamic> json) {
    return CustomerDataModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: LocationDataModel.fromJson(json['location'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location.toJson(),
    };
  }

  // Map to domain entity
  Customer toEntity() {
    return Customer(
      id: id,
      name: name,
      location: location.toEntity(),
    );
  }

  @override
  List<Object?> get props => [id, name, location];
}