import 'package:injectable/injectable.dart' as injectable;

import '../entity/trip.dart';
import '../repository/trip_planner_repository.dart';

@injectable.injectable
class GetTripByIdUseCase {
  final TripPlannerRepository _repository;

  GetTripByIdUseCase(this._repository);

  Future<Trip?> call(String id) async {
    if (id.isEmpty) {
      throw Exception('Trip ID cannot be empty');
    }
    
    return await _repository.getTripById(id);
  }
}
