import 'package:injectable/injectable.dart' as injectable;

import '../entity/order.dart';
import '../repository/order_repository.dart';

@injectable.injectable
class GetOrdersUseCase {
  final OrderRepository _repository;
  
  GetOrdersUseCase(this._repository);
  
  Future<List<Order>> call({bool? isDiscounted}) async {
    if (isDiscounted == null) {
      return await _repository.getAllOrders();
    }
    return await _repository.getFilteredOrders(isDiscounted: isDiscounted);
  }
}
