import 'package:injectable/injectable.dart' as injectable;

import '../entity/trip.dart';
import '../repository/trip_planner_repository.dart';
import '../../../order/domain/entity/order.dart';

@injectable.injectable
class AssignOrdersToTripUseCase {
  final TripPlannerRepository _repository;

  AssignOrdersToTripUseCase(this._repository);

  Future<Trip> call({
    required String tripId,
    required List<Order> orders,
  }) async {
    if (tripId.isEmpty) {
      throw Exception('Trip ID cannot be empty');
    }
    
    if (orders.isEmpty) {
      throw Exception('Orders list cannot be empty');
    }

    // Get the current trip to validate capacity
    final currentTrip = await _repository.getTripById(tripId);
    if (currentTrip == null) {
      throw Exception('Trip not found');
    }

    // Check if the assigned vehicle can carry all orders
    if (currentTrip.assignedVehicle != null) {
      final totalWeight = orders.fold(0.0, (sum, order) => sum + order.totalWeight);
      final totalVolume = orders.fold(0.0, (sum, order) => sum + order.totalVolume);
      
      if (!currentTrip.assignedVehicle!.canCarry(weight: totalWeight, volume: totalVolume)) {
        throw Exception('Vehicle cannot carry the assigned orders due to capacity constraints');
      }
    }

    return await _repository.assignOrdersToTrip(
      tripId: tripId,
      orders: orders,
    );
  }
}