import 'package:equatable/equatable.dart';

import '../../../order/domain/entity/order.dart';
import 'vehicle.dart';

enum TripStatus {
  planned,
  inProgress,
  completed,
  cancelled,
}

class Trip extends Equatable {
  final String id;
  final DateTime date;
  final Vehicle? assignedVehicle;
  final List<Order> assignedOrders;
  final TripStatus status;

  const Trip({
    required this.id,
    required this.date,
    this.assignedVehicle,
    required this.assignedOrders,
    required this.status,
  });

  // Helper getters
  int get totalOrders => assignedOrders.length;
  double get totalWeight => assignedOrders.fold(0.0, (sum, order) => sum + order.totalWeight);
  double get totalVolume => assignedOrders.fold(0.0, (sum, order) => sum + order.totalVolume);
  double get totalCodAmount => assignedOrders.fold(0.0, (sum, order) => sum + order.codAmount);

  // Check if trip can accommodate more orders
  bool canAccommodateOrder(Order order, {double? maxWeight, double? maxVolume}) {
    if (assignedVehicle == null) return false;
    
    final newTotalWeight = totalWeight + order.totalWeight;
    final newTotalVolume = totalVolume + order.totalVolume;
    
    if (maxWeight != null && newTotalWeight > maxWeight) return false;
    if (maxVolume != null && newTotalVolume > maxVolume) return false;
    
    return true;
  }

  Trip copyWith({
    String? id,
    DateTime? date,
    Vehicle? assignedVehicle,
    List<Order>? assignedOrders,
    TripStatus? status,
  }) {
    return Trip(
      id: id ?? this.id,
      date: date ?? this.date,
      assignedVehicle: assignedVehicle ?? this.assignedVehicle,
      assignedOrders: assignedOrders ?? this.assignedOrders,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, date, assignedVehicle, assignedOrders, status];
}