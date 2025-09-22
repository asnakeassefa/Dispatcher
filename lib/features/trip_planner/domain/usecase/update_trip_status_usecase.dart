import 'package:injectable/injectable.dart' as injectable;

import '../entity/trip.dart';
import '../repository/trip_planner_repository.dart';

@injectable.injectable
class UpdateTripStatusUseCase {
  final TripPlannerRepository _repository;

  UpdateTripStatusUseCase(this._repository);

  Future<Trip> call({
    required String tripId,
    required TripStatus status,
  }) async {
    if (tripId.isEmpty) {
      throw Exception('Trip ID cannot be empty');
    }

    return await _repository.updateTripStatus(
      tripId: tripId,
      status: status,
    );
  }
}
