import 'package:injectable/injectable.dart' as injectable;

import '../entity/trip_execution.dart';
import '../entity/stop.dart';
import '../repository/trip_execution_repository.dart';
import '../../../trip_planner/domain/entity/trip.dart';
import '../../../order/domain/entity/order.dart';

@injectable.injectable
class CreateTripExecutionFromTripUseCase {
  final TripExecutionRepository _repository;

  CreateTripExecutionFromTripUseCase(this._repository);

  Future<TripExecution> call(Trip trip) async {
    if (trip.assignedVehicle == null) {
      throw Exception('Cannot create trip execution without assigned vehicle');
    }

    // Check if trip execution already exists
    final existingTripExecution = await _repository.getTripExecutionByTripId(trip.id);
    if (existingTripExecution != null) {
      return existingTripExecution;
    }

    // Handle trips without orders
    if (trip.assignedOrders.isEmpty) {
      // Create a trip execution with no stops
      final tripExecution = TripExecution(
        id: 'exec_${trip.id}',
        trip: trip,
        vehicle: trip.assignedVehicle!,
        stops: [], // Empty stops list
        status: TripExecutionStatus.notStarted,
      );

      return await _repository.createTripExecution(tripExecution);
    }

    // Group orders by customer to create stops
    final Map<String, List<Order>> ordersByCustomer = {};
    for (final order in trip.assignedOrders) {
      ordersByCustomer.putIfAbsent(order.customerId, () => []).add(order);
    }

    // Create stops for each customer
    final List<Stop> stops = [];
    int stopIndex = 0;
    
    for (final entry in ordersByCustomer.entries) {
      final customerId = entry.key;
      final customerOrders = entry.value;
      
      // TODO: Get customer details from customer service
      // For now, using placeholder data
      final stop = Stop(
        id: '${trip.id}_stop_${stopIndex++}',
        tripId: trip.id,
        customerId: customerId,
        customerName: 'Customer $customerId', // Placeholder
        address: 'Address for $customerId', // Placeholder
        orders: customerOrders,
        status: StopStatus.pending,
      );
      
      stops.add(stop);
    }

    final tripExecution = TripExecution(
      id: 'exec_${trip.id}',
      trip: trip,
      vehicle: trip.assignedVehicle!,
      stops: stops,
      status: TripExecutionStatus.notStarted,
    );

    return await _repository.createTripExecution(tripExecution);
  }
}
