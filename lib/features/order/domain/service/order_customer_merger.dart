import 'package:injectable/injectable.dart' as injectable;

import '../entity/customer.dart';
import '../entity/order.dart';
import '../model/order_with_customer.dart';

@injectable.injectable
class OrderCustomerMerger {
  List<OrderWithCustomer> mergeOrdersWithCustomers({
    required List<Order> orders,
    required List<Customer> customers,
  }) {
    return orders.map((order) {
      // Find the customer for this order
      Customer? customer;
      try {
        customer = customers.firstWhere(
          (c) => c.id == order.customerId,
        );
      } catch (e) {
        // Customer not found - will be null
        customer = null;
      }

      return OrderWithCustomer(
        order: order,
        customer: customer,
      );
    }).toList();
  }

  // Helper method to filter orders with customer data
  List<OrderWithCustomer> getOrdersWithCustomerData(List<OrderWithCustomer> orders) {
    return orders.where((orderWithCustomer) => orderWithCustomer.hasCustomerData).toList();
  }

  // Helper method to filter orders without customer data
  List<OrderWithCustomer> getOrdersWithoutCustomerData(List<OrderWithCustomer> orders) {
    return orders.where((orderWithCustomer) => !orderWithCustomer.hasCustomerData).toList();
  }

  // Helper method to get orders by customer name
  List<OrderWithCustomer> getOrdersByCustomerName(
    List<OrderWithCustomer> orders,
    String customerName,
  ) {
    return orders.where((orderWithCustomer) => 
      orderWithCustomer.customerName?.toLowerCase().contains(customerName.toLowerCase()) ?? false
    ).toList();
  }

  // Helper method to get orders by customer ID
  List<OrderWithCustomer> getOrdersByCustomerId(
    List<OrderWithCustomer> orders,
    String customerId,
  ) {
    return orders.where((orderWithCustomer) => 
      orderWithCustomer.customerId == customerId
    ).toList();
  }

  // Helper method to filter by discount status
  List<OrderWithCustomer> getOrdersByDiscountStatus(
    List<OrderWithCustomer> orders,
    bool isDiscounted,
  ) {
    return orders.where((orderWithCustomer) => 
      orderWithCustomer.isDiscounted == isDiscounted
    ).toList();
  }
}
