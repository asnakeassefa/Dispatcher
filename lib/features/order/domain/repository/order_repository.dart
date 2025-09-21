import '../entity/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getAllOrders();
  Future<Order?> getOrderById(String id);
  Future<List<Order>> getOrdersByCustomerId(String customerId);
  Future<List<Order>> getFilteredOrders({
    bool? isDiscounted,
  });
}
