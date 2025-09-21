import 'package:injectable/injectable.dart' as injectable;

import '../entity/order.dart';
import '../repository/order_repository.dart';

@injectable.injectable
class GetOrdersByCustomerUseCase {
  final OrderRepository _repository;
  
  GetOrdersByCustomerUseCase(this._repository);
  
  Future<List<Order>> call(String customerId) async {
    return await _repository.getOrdersByCustomerId(customerId);
  }
}
