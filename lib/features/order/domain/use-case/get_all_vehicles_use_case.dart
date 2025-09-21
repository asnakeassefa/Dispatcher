import 'package:injectable/injectable.dart' as injectable;

import '../entity/vehicle.dart';
import '../repository/vehicle_repository.dart';

@injectable.injectable
class GetAllVehiclesUseCase {
  final VehicleRepository _repository;
  
  GetAllVehiclesUseCase(this._repository);
  
  Future<List<Vehicle>> call() async {
    return await _repository.getAllVehicles();
  }
}
