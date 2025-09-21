import 'package:equatable/equatable.dart';

class Capacity extends Equatable {
  final double weight; // kg
  final double volume; // m³

  const Capacity({
    required this.weight,
    required this.volume,
  });

  Capacity copyWith({
    double? weight,
    double? volume,
  }) {
    return Capacity(
      weight: weight ?? this.weight,
      volume: volume ?? this.volume,
    );
  }

  @override
  List<Object?> get props => [weight, volume];

  @override
  String toString() => 'Capacity(weight: ${weight}kg, volume: ${volume}m³)';
}

class Vehicle extends Equatable {
  final String id;
  final String name;
  final Capacity capacity;
  final double fillRate; // 0.0 to 1.0

  const Vehicle({
    required this.id,
    required this.name,
    required this.capacity,
    required this.fillRate,
  });

  double get effectiveWeightCapacity => capacity.weight * fillRate;
  double get effectiveVolumeCapacity => capacity.volume * fillRate;

  Capacity get effectiveCapacity => Capacity(
    weight: effectiveWeightCapacity,
    volume: effectiveVolumeCapacity,
  );

  Vehicle copyWith({
    String? id,
    String? name,
    Capacity? capacity,
    double? fillRate,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      fillRate: fillRate ?? this.fillRate,
    );
  }

  @override
  List<Object?> get props => [id, name, capacity, fillRate];

  @override
  String toString() => 'Vehicle(id: $id, name: $name, capacity: $capacity, fillRate: $fillRate)';
}
