import 'package:injectable/injectable.dart' as injectable;

import '../data-source/dispatcher_data_source.dart';
import '../../domain/entity/vehicle.dart';
import '../../domain/repository/vehicle_repository.dart';

@injectable.Injectable(as: VehicleRepository)
class VehicleRepositoryImpl implements VehicleRepository {
  final DispatcherDataSource _dataSource;
  
  VehicleRepositoryImpl(this._dataSource);
  
  @override
  Future<List<Vehicle>> getAllVehicles() async {
    return await _dataSource.getAllVehicles();
  }
  
  @override
  Future<Vehicle?> getVehicleById(String id) async {
    return await _dataSource.getVehicleById(id);
  }
}