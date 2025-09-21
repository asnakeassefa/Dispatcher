import 'package:equatable/equatable.dart';

import '../../domain/model/order_with_customer.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  final List<OrderWithCustomer> ordersWithCustomer;
  final DateTime lastUpdated;
  final OrderFilter currentFilter;

  const OrderLoaded({
    required this.ordersWithCustomer,
    required this.lastUpdated,
    required this.currentFilter,
  });

  @override
  List<Object?> get props => [ordersWithCustomer, lastUpdated, currentFilter];

  // Helper methods for filtering
  List<OrderWithCustomer> get ordersWithCustomerData => 
      ordersWithCustomer.where((order) => order.hasCustomerData).toList();

  List<OrderWithCustomer> get ordersWithoutCustomerData => 
      ordersWithCustomer.where((order) => !order.hasCustomerData).toList();

  List<OrderWithCustomer> getDiscountedOrders() => 
      ordersWithCustomer.where((order) => order.isDiscounted).toList();

  List<OrderWithCustomer> getNonDiscountedOrders() => 
      ordersWithCustomer.where((order) => !order.isDiscounted).toList();

  List<OrderWithCustomer> getOrdersByCustomerId(String customerId) => 
      ordersWithCustomer.where((order) => order.customerId == customerId).toList();

  List<OrderWithCustomer> getOrdersByCustomerName(String customerName) => 
      ordersWithCustomer.where((order) => 
        order.customerName?.toLowerCase().contains(customerName.toLowerCase()) ?? false
      ).toList();

  // For HydratedBloc persistence
  Map<String, dynamic> toJson() {
    return {
      'ordersWithCustomer': ordersWithCustomer.map((order) => order.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'currentFilter': currentFilter.toJson(),
    };
  }

  factory OrderLoaded.fromJson(Map<String, dynamic> json) {
    return OrderLoaded(
      ordersWithCustomer: (json['ordersWithCustomer'] as List<dynamic>)
          .map((orderJson) => OrderWithCustomer.fromJson(orderJson as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      currentFilter: OrderFilter.fromJson(json['currentFilter'] as Map<String, dynamic>),
    );
  }
}

class OrderError extends OrderState {
  final String message;
  final DateTime timestamp;

  const OrderError({
    required this.message,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [message, timestamp];

  // For HydratedBloc persistence
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory OrderError.fromJson(Map<String, dynamic> json) {
    return OrderError(
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

// Filter enum for better type safety
enum OrderFilterType {
  all,
  discounted,
  notDiscounted,
}

class OrderFilter extends Equatable {
  final OrderFilterType type;
  final String displayName;

  const OrderFilter({
    required this.type,
    required this.displayName,
  });

  static const OrderFilter all = OrderFilter(
    type: OrderFilterType.all,
    displayName: 'All Orders',
  );

  static const OrderFilter discounted = OrderFilter(
    type: OrderFilterType.discounted,
    displayName: 'Discounted',
  );

  static const OrderFilter notDiscounted = OrderFilter(
    type: OrderFilterType.notDiscounted,
    displayName: 'Not Discounted',
  );

  static const List<OrderFilter> allFilters = [
    all,
    discounted,
    notDiscounted,
  ];

  @override
  List<Object?> get props => [type, displayName];

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'displayName': displayName,
    };
  }

  factory OrderFilter.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    final type = OrderFilterType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => OrderFilterType.all,
    );
    
    return OrderFilter(
      type: type,
      displayName: json['displayName'] as String,
    );
  }
}
