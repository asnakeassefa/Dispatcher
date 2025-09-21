import 'package:equatable/equatable.dart';

import '../../domain/entity/vehicle.dart';

class CapacityDataModel extends Equatable {
  final double weight; // kg
  final double volume; // m³

  const CapacityDataModel({
    required this.weight,
    required this.volume,
  });

  factory CapacityDataModel.fromJson(Map<String, dynamic> json) {
    return CapacityDataModel(
      weight: (json['weight'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'volume': volume,
    };
  }

  // Map to domain entity
  Capacity toEntity() {
    return Capacity(
      weight: weight,
      volume: volume,
    );
  }

  @override
  List<Object?> get props => [weight, volume];
}

class VehicleDataModel extends Equatable {
  final String id;
  final String name;
  final CapacityDataModel capacity;
  final double fillRate; // Effective capacity percentage

  const VehicleDataModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.fillRate,
  });

  factory VehicleDataModel.fromJson(Map<String, dynamic> json) {
    return VehicleDataModel(
      id: json['id'] as String,
      name: json['name'] as String,
      capacity: CapacityDataModel.fromJson(json['capacity'] as Map<String, dynamic>),
      fillRate: (json['fillRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity.toJson(),
      'fillRate': fillRate,
    };
  }

  // Map to domain entity
  Vehicle toEntity() {
    return Vehicle(
      id: id,
      name: name,
      capacity: capacity.toEntity(),
      fillRate: fillRate,
    );
  }

  @override
  List<Object?> get props => [id, name, capacity, fillRate];
}