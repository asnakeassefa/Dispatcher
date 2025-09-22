import '../entity/trip.dart';
import '../entity/vehicle.dart';
import '../../../order/domain/entity/order.dart';

abstract class TripPlannerRepository {
  // Trip management
  Future<Trip> createTrip({
    required DateTime date,
    Vehicle? assignedVehicle,
    List<Order> assignedOrders = const [],
  });

  Future<List<Trip>> getTrips();
  
  Future<Trip?> getTripById(String id);

  // Trip assignments
  Future<Trip> assignOrdersToTrip({
    required String tripId,
    required List<Order> orders,
  });

  Future<Trip> assignVehicleToTrip({
    required String tripId,
    required Vehicle vehicle,
  });

  // Trip status management
  Future<Trip> updateTripStatus({
    required String tripId,
    required TripStatus status,
  });

  // Vehicle management
  Future<List<Vehicle>> getAvailableVehicles();
  
  Future<Vehicle?> getVehicleById(String id);

  // Order management for trips
  Future<List<Order>> getUnassignedOrders();
  
  Future<List<Order>> getOrdersByTripId(String tripId);
}
