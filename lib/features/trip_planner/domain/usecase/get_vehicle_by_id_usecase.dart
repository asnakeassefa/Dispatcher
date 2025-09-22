import 'package:injectable/injectable.dart' as injectable;

import '../entity/vehicle.dart';
import '../repository/trip_planner_repository.dart';

@injectable.injectable
class GetVehicleByIdUseCase {
  final TripPlannerRepository _repository;

  GetVehicleByIdUseCase(this._repository);

  Future<Vehicle?> call(String id) async {
    return await _repository.getVehicleById(id);
  }
}
