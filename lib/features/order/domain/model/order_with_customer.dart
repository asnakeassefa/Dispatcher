import 'package:equatable/equatable.dart';

import '../entity/customer.dart';
import '../entity/order.dart';

class OrderWithCustomer extends Equatable {
  final Order order;
  final Customer? customer;

  const OrderWithCustomer({
    required this.order,
    this.customer,
  });

  // Convenience getters to access order properties directly
  String get id => order.id;
  String get customerId => order.customerId;
  double get codAmount => order.codAmount;
  bool get isDiscounted => order.isDiscounted;
  List<OrderItem> get items => order.items;
  double get totalWeight => order.totalWeight;
  double get totalVolume => order.totalVolume;

  // Customer properties
  String? get customerName => customer?.name;
  Location? get customerLocation => customer?.location;

  // Helper to check if customer data is available
  bool get hasCustomerData => customer != null;

  OrderWithCustomer copyWith({
    Order? order,
    Customer? customer,
  }) {
    return OrderWithCustomer(
      order: order ?? this.order,
      customer: customer ?? this.customer,
    );
  }

  // For JSON serialization (for HydratedBloc persistence)
  Map<String, dynamic> toJson() {
    return {
      'order': {
        'id': order.id,
        'customerId': order.customerId,
        'codAmount': order.codAmount,
        'isDiscounted': order.isDiscounted,
        'items': order.items.map((item) => {
          'sku': item.sku,
          'name': item.name,
          'quantity': item.quantity,
          'weight': item.weight,
          'volume': item.volume,
          'serialTracked': item.serialTracked,
        }).toList(),
      },
      'customer': customer != null ? {
        'id': customer!.id,
        'name': customer!.name,
        'location': {
          'lat': customer!.location.lat,
          'lon': customer!.location.lon,
        },
      } : null,
    };
  }

  factory OrderWithCustomer.fromJson(Map<String, dynamic> json) {
    final orderJson = json['order'] as Map<String, dynamic>;
    final customerJson = json['customer'] as Map<String, dynamic>?;

    return OrderWithCustomer(
      order: Order(
        id: orderJson['id'] as String,
        customerId: orderJson['customerId'] as String,
        codAmount: (orderJson['codAmount'] as num).toDouble(),
        isDiscounted: orderJson['isDiscounted'] as bool,
        items: (orderJson['items'] as List<dynamic>)
            .map((itemJson) => OrderItem(
                  sku: itemJson['sku'] as String,
                  name: itemJson['name'] as String,
                  quantity: itemJson['quantity'] as int,
                  weight: (itemJson['weight'] as num).toDouble(),
                  volume: (itemJson['volume'] as num).toDouble(),
                  serialTracked: itemJson['serialTracked'] as bool,
                ))
            .toList(),
      ),
      customer: customerJson != null ? Customer(
        id: customerJson['id'] as String,
        name: customerJson['name'] as String,
        location: Location(
          lat: (customerJson['location']['lat'] as num).toDouble(),
          lon: (customerJson['location']['lon'] as num).toDouble(),
        ),
      ) : null,
    );
  }

  @override
  List<Object?> get props => [order, customer];
}
