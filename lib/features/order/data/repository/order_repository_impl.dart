import 'package:injectable/injectable.dart' as injectable;

import '../../domain/entity/order.dart';
import '../../domain/repository/order_repository.dart';
import '../data-source/order_data_source.dart';

@injectable.Injectable(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final OrderDataSource _dataSource;
  
  OrderRepositoryImpl(this._dataSource);
  
  @override
  Future<List<Order>> getAllOrders() async {
    return await _dataSource.getAllOrders();
  }
  
  @override
  Future<Order?> getOrderById(String id) async {
    return await _dataSource.getOrderById(id);
  }
  
  @override
  Future<List<Order>> getOrdersByCustomerId(String customerId) async {
    return await _dataSource.getOrdersByCustomerId(customerId);
  }
  
  @override
  Future<List<Order>> getFilteredOrders({bool? isDiscounted}) async {
    return await _dataSource.getFilteredOrders(isDiscounted: isDiscounted);
  }
}