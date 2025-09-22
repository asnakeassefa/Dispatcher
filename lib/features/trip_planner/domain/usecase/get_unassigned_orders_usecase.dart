import 'package:injectable/injectable.dart' as injectable;

import '../../../order/domain/entity/order.dart';
import '../repository/trip_planner_repository.dart';

@injectable.injectable
class GetUnassignedOrdersUseCase {
  final TripPlannerRepository _repository;

  GetUnassignedOrdersUseCase(this._repository);

  Future<List<Order>> call() async {
    return await _repository.getUnassignedOrders();
  }
}
