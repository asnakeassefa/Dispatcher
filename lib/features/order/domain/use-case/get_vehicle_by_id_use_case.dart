import 'package:injectable/injectable.dart' as injectable;

import '../entity/vehicle.dart';
import '../repository/vehicle_repository.dart';

@injectable.injectable
class GetVehicleByIdUseCase {
  final VehicleRepository _repository;
  
  GetVehicleByIdUseCase(this._repository);
  
  Future<Vehicle?> call(String id) async {
    return await _repository.getVehicleById(id);
  }
}
