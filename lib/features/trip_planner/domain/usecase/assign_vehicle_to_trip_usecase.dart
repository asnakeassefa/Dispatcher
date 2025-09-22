import 'package:injectable/injectable.dart' as injectable;

import '../entity/trip.dart';
import '../entity/vehicle.dart';
import '../repository/trip_planner_repository.dart';

@injectable.injectable
class AssignVehicleToTripUseCase {
  final TripPlannerRepository _repository;

  AssignVehicleToTripUseCase(this._repository);

  Future<Trip> call({
    required String tripId,
    required Vehicle vehicle,
  }) async {
    if (tripId.isEmpty) {
      throw Exception('Trip ID cannot be empty');
    }

    // Get the current trip to validate
    final currentTrip = await _repository.getTripById(tripId);
    if (currentTrip == null) {
      throw Exception('Trip not found');
    }

    // Check if vehicle is available
    if (!vehicle.isAvailable) {
      throw Exception('Vehicle is not available for assignment');
    }

    // Check if the vehicle can carry all assigned orders
    if (currentTrip.assignedOrders.isNotEmpty) {
      final totalWeight = currentTrip.totalWeight;
      final totalVolume = currentTrip.totalVolume;
      
      if (!vehicle.canCarry(weight: totalWeight, volume: totalVolume)) {
        throw Exception('Vehicle cannot carry the assigned orders due to capacity constraints');
      }
    }

    return await _repository.assignVehicleToTrip(
      tripId: tripId,
      vehicle: vehicle,
    );
  }
}