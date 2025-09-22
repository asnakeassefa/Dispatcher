import 'package:injectable/injectable.dart' as injectable;

import '../../domain/entity/trip.dart';
import '../../domain/entity/vehicle.dart';
import '../../domain/repository/trip_planner_repository.dart';
import '../../../order/domain/entity/order.dart';
import '../data-source/trip_local_data_source.dart';
import '../mapper/trip_mapper.dart';
import '../../../order/data/data-source/order_local_data_source.dart';

@injectable.LazySingleton(as: TripPlannerRepository)
class TripPlanRepositoryImpl implements TripPlannerRepository {
  final TripLocalDataSource _localDataSource;
  final OrderLocalDataSource _orderDataSource;

  TripPlanRepositoryImpl(
    this._localDataSource,
    this._orderDataSource,
  );

  @override
  Future<Trip> createTrip({
    required DateTime date,
    Vehicle? assignedVehicle,
    List<Order> assignedOrders = const [],
  }) async {
    try {
      final trip = Trip(
        id: _generateTripId(),
        date: date,
        assignedVehicle: assignedVehicle,
        assignedOrders: assignedOrders,
        status: TripStatus.planned,
      );

      final tripModel = TripMapper.toModel(trip);
      await _localDataSource.createTrip(tripModel);
      
      return trip;
    } catch (e) {
      throw Exception('Failed to create trip: ${e.toString()}');
    }
  }

  @override
  Future<List<Trip>> getTrips() async {
    try {
      final tripModels = await _localDataSource.getAllTrips();
      
      // Get all vehicles to map them to trips
      final vehicles = await getAvailableVehicles();
      final vehicleMap = {for (var v in vehicles) v.id: v};
      
      // Get all orders to map them to trips
      final orders = await _orderDataSource.getAllOrders();
      final orderMap = {for (var o in orders) o.id: o};
      
      return tripModels.map((model) {
        final vehicle = model.assignedVehicleId != null 
            ? vehicleMap[model.assignedVehicleId]
            : null;
        
        final tripOrders = model.assignedOrderIds
            .map((orderId) => orderMap[orderId])
            .where((order) => order != null)
            .cast<Order>()
            .toList();
        
        return model.toEntity(
          assignedVehicle: vehicle,
          assignedOrders: tripOrders,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get trips: ${e.toString()}');
    }
  }

  @override
  Future<Trip?> getTripById(String id) async {
    try {
      final tripModel = await _localDataSource.getTripById(id);
      if (tripModel == null) return null;
      
      // Get the vehicle if assigned
      Vehicle? vehicle;
      if (tripModel.assignedVehicleId != null) {
        vehicle = await getVehicleById(tripModel.assignedVehicleId!);
      }
      
      // Get the orders if assigned
      final orders = await getOrdersByTripId(id);
      
      return tripModel.toEntity(
        assignedVehicle: vehicle,
        assignedOrders: orders,
      );
    } catch (e) {
      throw Exception('Failed to get trip by ID: ${e.toString()}');
    }
  }

  @override
  Future<Trip> assignOrdersToTrip({
    required String tripId,
    required List<Order> orders,
  }) async {
    try {
      final orderIds = orders.map((order) => order.id).toList();
      final updatedModel = await _localDataSource.assignOrdersToTrip(tripId, orderIds);
      
      return updatedModel.toEntity(assignedOrders: orders);
    } catch (e) {
      throw Exception('Failed to assign orders to trip: ${e.toString()}');
    }
  }

  @override
  Future<Trip> assignVehicleToTrip({
    required String tripId,
    required Vehicle vehicle,
  }) async {
    try {
      final updatedModel = await _localDataSource.assignVehicleToTrip(tripId, vehicle.id);
      
      return updatedModel.toEntity(assignedVehicle: vehicle);
    } catch (e) {
      throw Exception('Failed to assign vehicle to trip: ${e.toString()}');
    }
  }

  @override
  Future<Trip> updateTripStatus({
    required String tripId,
    required TripStatus status,
  }) async {
    try {
      final updatedModel = await _localDataSource.updateTripStatus(tripId, status.index);
      
      return updatedModel.toEntity();
    } catch (e) {
      throw Exception('Failed to update trip status: ${e.toString()}');
    }
  }

  @override
  Future<List<Vehicle>> getAvailableVehicles() async {
    try {
      return await _localDataSource.getAvailableVehicles();
    } catch (e) {
      throw Exception('Failed to get available vehicles: ${e.toString()}');
    }
  }

  @override
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      return await _localDataSource.getVehicleById(id);
    } catch (e) {
      throw Exception('Failed to get vehicle by ID: ${e.toString()}');
    }
  }

  @override
  Future<List<Order>> getUnassignedOrders() async {
    try {
      // For now, return all orders as unassigned
      // In a real app, you'd track which orders are assigned to trips
      return await _orderDataSource.getAllOrders();
    } catch (e) {
      throw Exception('Failed to get unassigned orders: ${e.toString()}');
    }
  }

  @override
  Future<List<Order>> getOrdersByTripId(String tripId) async {
    try {
      final tripModel = await _localDataSource.getTripById(tripId);
      if (tripModel == null) return [];
      
      final orders = <Order>[];
      for (final orderId in tripModel.assignedOrderIds) {
        final order = await _orderDataSource.getOrderById(orderId);
        if (order != null) {
          orders.add(order);
        }
      }
      
      return orders;
    } catch (e) {
      throw Exception('Failed to get orders by trip ID: ${e.toString()}');
    }
  }

  // Helper method to generate unique trip IDs
  String _generateTripId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'trip_$timestamp';
  }
}
