import 'package:equatable/equatable.dart';

enum VehicleStatus {
  available,
  assigned,
  inUse,
  maintenance,
  outOfService,
}

class Vehicle extends Equatable {
  final String id;
  final String plateNumber;
  final double capacity; // in kg
  final double volumeCapacity; // in m³
  final String driverName;
  final VehicleStatus status;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.capacity,
    required this.volumeCapacity,
    required this.driverName,
    required this.status,
  });

  // Helper getters
  bool get isAvailable => status == VehicleStatus.available;
  bool get isAssigned => status == VehicleStatus.assigned;
  bool get isInUse => status == VehicleStatus.inUse;
  bool get isInMaintenance => status == VehicleStatus.maintenance;
  bool get isOutOfService => status == VehicleStatus.outOfService;

  // Check if vehicle can carry the given weight and volume
  bool canCarry({required double weight, required double volume}) {
    return weight <= capacity && volume <= volumeCapacity && isAvailable;
  }

  Vehicle copyWith({
    String? id,
    String? plateNumber,
    double? capacity,
    double? volumeCapacity,
    String? driverName,
    VehicleStatus? status,
  }) {
    return Vehicle(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      capacity: capacity ?? this.capacity,
      volumeCapacity: volumeCapacity ?? this.volumeCapacity,
      driverName: driverName ?? this.driverName,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, plateNumber, capacity, volumeCapacity, driverName, status];
}