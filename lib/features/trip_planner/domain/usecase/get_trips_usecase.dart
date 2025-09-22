import 'package:injectable/injectable.dart' as injectable;

import '../entity/trip.dart';
import '../repository/trip_planner_repository.dart';

@injectable.injectable
class GetTripsUseCase {
  final TripPlannerRepository _repository;

  GetTripsUseCase(this._repository);

  Future<List<Trip>> call() async {
    return await _repository.getTrips();
  }
}
