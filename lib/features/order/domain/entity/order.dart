

// create order entity
import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String sku;
  final String name;
  final int quantity;
  final double weight; // kg
  final double volume; // m³
  final bool serialTracked;

  const OrderItem({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.weight,
    required this.volume,
    required this.serialTracked,
  });

  double get totalWeight => weight * quantity;
  double get totalVolume => volume * quantity;

  OrderItem copyWith({
    String? sku,
    String? name,
    int? quantity,
    double? weight,
    double? volume,
    bool? serialTracked,
  }) {
    return OrderItem(
      sku: sku ?? this.sku,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
      volume: volume ?? this.volume,
      serialTracked: serialTracked ?? this.serialTracked,
    );
  }

  @override
  List<Object?> get props => [sku, name, quantity, weight, volume, serialTracked];
}

class Order extends Equatable {
  final String id;
  final String customerId;
  final double codAmount;
  final bool isDiscounted;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.customerId,
    required this.codAmount,
    required this.isDiscounted,
    required this.items,
  });

  double get totalWeight => items.fold(0.0, (sum, item) => sum + item.totalWeight);
  double get totalVolume => items.fold(0.0, (sum, item) => sum + item.totalVolume);

  Order copyWith({
    String? id,
    String? customerId,
    double? codAmount,
    bool? isDiscounted,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      codAmount: codAmount ?? this.codAmount,
      isDiscounted: isDiscounted ?? this.isDiscounted,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [id, customerId, codAmount, isDiscounted, items];
}