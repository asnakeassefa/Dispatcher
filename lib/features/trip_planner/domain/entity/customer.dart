import 'dart:math' as math;
import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final double lat;
  final double lon;

  const Location({
    required this.lat,
    required this.lon,
  });

  Location copyWith({
    double? lat,
    double? lon,
  }) {
    return Location(
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  // Calculate distance to another location (Haversine formula)
  double distanceTo(Location other) {
    const double earthRadius = 6371; // km
    final double dLat = _degreesToRadians(other.lat - lat);
    final double dLon = _degreesToRadians(other.lon - lon);
    
    final double a = 
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_degreesToRadians(lat)) * math.cos(_degreesToRadians(other.lat)) *
        math.pow(math.sin(dLon / 2), 2);
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  @override
  List<Object?> get props => [lat, lon];

  @override
  String toString() => 'Location(lat: $lat, lon: $lon)';
}

class Customer extends Equatable {
  final String id;
  final String name;
  final Location location;
  final String? phone;
  final String? email;
  final String? address;

  const Customer({
    required this.id,
    required this.name,
    required this.location,
    this.phone,
    this.email,
    this.address,
  });

  Customer copyWith({
    String? id,
    String? name,
    Location? location,
    String? phone,
    String? email,
    String? address,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [id, name, location, phone, email, address];

  @override
  String toString() => 'Customer(id: $id, name: $name, location: $location)';
}
