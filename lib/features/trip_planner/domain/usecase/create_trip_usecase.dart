import 'package:injectable/injectable.dart' as injectable;

import '../entity/trip.dart';
import '../entity/vehicle.dart';
import '../repository/trip_planner_repository.dart';
import '../../../order/domain/entity/order.dart';

@injectable.injectable
class CreateTripUseCase {
  final TripPlannerRepository _repository;

  CreateTripUseCase(this._repository);

  Future<Trip> call({
    required DateTime date,
    Vehicle? assignedVehicle,
    List<Order> assignedOrders = const [],
  }) async {
    if (date.isBefore(DateTime.now().subtract(const Duration(minutes: 1)))) {
      throw Exception('Trip date cannot be in the past');
    }

    return await _repository.createTrip(
      date: date,
      assignedVehicle: assignedVehicle,
      assignedOrders: assignedOrders,
    );
  }
}