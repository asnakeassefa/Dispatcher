import 'package:injectable/injectable.dart' as injectable;

import '../entity/vehicle.dart';
import '../repository/trip_planner_repository.dart';

@injectable.injectable
class GetAvailableVehiclesUseCase {
  final TripPlannerRepository _repository;

  GetAvailableVehiclesUseCase(this._repository);

  Future<List<Vehicle>> call() async {
    return await _repository.getAvailableVehicles();
  }
}
