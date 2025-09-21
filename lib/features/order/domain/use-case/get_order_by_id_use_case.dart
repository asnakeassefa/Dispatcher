import 'package:injectable/injectable.dart' as injectable;

import '../entity/order.dart';
import '../repository/order_repository.dart';

@injectable.injectable
class GetOrderByIdUseCase {
  final OrderRepository _repository;
  
  GetOrderByIdUseCase(this._repository);
  
  Future<Order?> call(String id) async {
    return await _repository.getOrderById(id);
  }
}
