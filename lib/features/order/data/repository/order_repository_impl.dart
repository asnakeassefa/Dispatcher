import 'package:injectable/injectable.dart' as injectable;

import '../data-source/dispatcher_data_source.dart';
import '../../domain/entity/order.dart';
import '../../domain/repository/order_repository.dart';

@injectable.Injectable(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final DispatcherDataSource _dataSource;
  
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