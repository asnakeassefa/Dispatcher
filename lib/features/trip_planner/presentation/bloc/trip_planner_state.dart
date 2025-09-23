import 'package:equatable/equatable.dart';

import '../../domain/entity/trip.dart';
import '../../domain/entity/vehicle.dart';
import '../../../order/domain/entity/order.dart';

abstract class TripPlannerState extends Equatable {
  const TripPlannerState();

  @override
  List<Object?> get props => [];
}

class TripPlannerInitial extends TripPlannerState {
  const TripPlannerInitial();
}

class TripPlannerLoading extends TripPlannerState {
  const TripPlannerLoading();
}

class TripPlannerLoaded extends TripPlannerState {
  final List<Trip> trips;
  final List<Vehicle> availableVehicles;
  final List<Order> unassignedOrders;
  final DateTime lastUpdated;

  const TripPlannerLoaded({
    required this.trips,
    this.availableVehicles = const [],
    this.unassignedOrders = const [],
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [trips, availableVehicles, unassignedOrders, lastUpdated];

  TripPlannerLoaded copyWith({
    List<Trip>? trips,
    List<Vehicle>? availableVehicles,
    List<Order>? unassignedOrders,
    DateTime? lastUpdated,
  }) {
    return TripPlannerLoaded(
      trips: trips ?? this.trips,
      availableVehicles: availableVehicles ?? this.availableVehicles,
      unassignedOrders: unassignedOrders ?? this.unassignedOrders,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Helper methods for filtering
  List<Trip> getTripsByStatus(TripStatus status) => 
      trips.where((trip) => trip.status == status).toList();

  List<Trip> getPlannedTrips() => getTripsByStatus(TripStatus.planned);
  List<Trip> getInProgressTrips() => getTripsByStatus(TripStatus.inProgress);
  List<Trip> getCompletedTrips() => getTripsByStatus(TripStatus.completed);
  List<Trip> getCancelledTrips() => getTripsByStatus(TripStatus.cancelled);

  List<Trip> getTripsByDate(DateTime date) => 
      trips.where((trip) => 
        trip.date.year == date.year &&
        trip.date.month == date.month &&
        trip.date.day == date.day
      ).toList();

  List<Trip> getTripsByDateRange(DateTime startDate, DateTime endDate) => 
      trips.where((trip) => 
        trip.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        trip.date.isBefore(endDate.add(const Duration(days: 1)))
      ).toList();

  // For HydratedBloc persistence
  Map<String, dynamic> toJson() {
    return {
      'trips': trips.map((trip) => {
        'id': trip.id,
        'date': trip.date.toIso8601String(),
        'assignedVehicleId': trip.assignedVehicle?.id,
        'assignedOrderIds': trip.assignedOrders.map((order) => order.id).toList(),
        'status': trip.status.index,
      }).toList(),
      'availableVehicles': availableVehicles.map((vehicle) => {
        'id': vehicle.id,
        'plateNumber': vehicle.plateNumber,
        'capacity': vehicle.capacity,
        'volumeCapacity': vehicle.volumeCapacity,
        'driverName': vehicle.driverName,
        'status': vehicle.status.index,
      }).toList(),
      'unassignedOrders': unassignedOrders.map((order) => {
        'id': order.id,
        'customerId': order.customerId,
        'codAmount': order.codAmount,
        'isDiscounted': order.isDiscounted,
        'items': order.items.map((item) => {
          'sku': item.sku,
          'name': item.name,
          'quantity': item.quantity,
          'weight': item.weight,
          'volume': item.volume,
          'serialTracked': item.serialTracked,
        }).toList(),
      }).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory TripPlannerLoaded.fromJson(Map<String, dynamic> json) {
    return TripPlannerLoaded(
      trips: (json['trips'] as List<dynamic>).map((tripJson) {
        return Trip(
          id: tripJson['id'] as String,
          date: DateTime.parse(tripJson['date'] as String),
          assignedVehicle: null, // Will be loaded separately
          assignedOrders: [], // Will be loaded separately
          status: TripStatus.values[tripJson['status'] as int],
        );
      }).toList(),
      availableVehicles: (json['availableVehicles'] as List<dynamic>? ?? []).map((vehicleJson) {
        return Vehicle(
          id: vehicleJson['id'] as String,
          plateNumber: vehicleJson['plateNumber'] as String,
          capacity: (vehicleJson['capacity'] as num).toDouble(),
          volumeCapacity: (vehicleJson['volumeCapacity'] as num).toDouble(),
          driverName: vehicleJson['driverName'] as String,
          status: VehicleStatus.values[vehicleJson['status'] as int],
        );
      }).toList(),
      unassignedOrders: (json['unassignedOrders'] as List<dynamic>? ?? []).map((orderJson) {
        return Order(
          id: orderJson['id'] as String,
          customerId: orderJson['customerId'] as String,
          codAmount: (orderJson['codAmount'] as num).toDouble(),
          isDiscounted: orderJson['isDiscounted'] as bool,
          items: (orderJson['items'] as List<dynamic>).map((itemJson) {
            return OrderItem(
              sku: itemJson['sku'] as String,
              name: itemJson['name'] as String,
              quantity: itemJson['quantity'] as int,
              weight: (itemJson['weight'] as num).toDouble(),
              volume: (itemJson['volume'] as num).toDouble(),
              serialTracked: itemJson['serialTracked'] as bool,
            );
          }).toList(),
          // New optional parameters
          collectedAmount: orderJson['collectedAmount'] != null 
              ? (orderJson['collectedAmount'] as num).toDouble() 
              : null,
          collectionDate: orderJson['collectionDate'] != null 
              ? DateTime.parse(orderJson['collectionDate'] as String) 
              : null,
          collectionNotes: orderJson['collectionNotes'] as String?,
        );
      }).toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

class TripPlannerError extends TripPlannerState {
  final String message;

  const TripPlannerError({required this.message});

  @override
  List<Object?> get props => [message];
}
