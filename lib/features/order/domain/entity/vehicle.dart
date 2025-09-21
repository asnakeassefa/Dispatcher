import 'package:equatable/equatable.dart';

class Capacity extends Equatable {
  final double weight; // kg
  final double volume; // m³

  const Capacity({
    required this.weight,
    required this.volume,
  });

  @override
  List<Object?> get props => [weight, volume];
}

class Vehicle extends Equatable {
  final String id;
  final String name;
  final Capacity capacity;
  final double fillRate; // Effective capacity percentage

  const Vehicle({
    required this.id,
    required this.name,
    required this.capacity,
    required this.fillRate,
  });

  double get effectiveWeightCapacity => capacity.weight * fillRate;
  double get effectiveVolumeCapacity => capacity.volume * fillRate;

  @override
  List<Object?> get props => [id, name, capacity, fillRate];
}
