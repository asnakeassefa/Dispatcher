import 'package:equatable/equatable.dart';

import '../../domain/entity/order.dart';

class OrderItemDataModel extends Equatable {
  final String sku;
  final String name;
  final int quantity;
  final double weight;
  final double volume;
  final bool serialTracked;

  const OrderItemDataModel({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.weight,
    required this.volume,
    required this.serialTracked,
  });

  factory OrderItemDataModel.fromJson(Map<String, dynamic> json) {
    return OrderItemDataModel(
      sku: json['sku'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      weight: (json['weight'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      serialTracked: json['serialTracked'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'name': name,
      'quantity': quantity,
      'weight': weight,
      'volume': volume,
      'serialTracked': serialTracked,
    };
  }

  // Map to domain entity
  OrderItem toEntity() {
    return OrderItem(
      sku: sku,
      name: name,
      quantity: quantity,
      weight: weight,
      volume: volume,
      serialTracked: serialTracked,
    );
  }

  @override
  List<Object?> get props => [sku, name, quantity, weight, volume, serialTracked];
}

class OrderDataModel extends Equatable {
  final String id;
  final String customerId;
  final double codAmount;
  final bool isDiscounted;
  final List<OrderItemDataModel> items;
  final double? collectedAmount;
  final DateTime? collectionDate;
  final String? collectionNotes;

  const OrderDataModel({
    required this.id,
    required this.customerId,
    required this.codAmount,
    required this.isDiscounted,
    required this.items,
    this.collectedAmount,
    this.collectionDate,
    this.collectionNotes,
  });

  factory OrderDataModel.fromJson(Map<String, dynamic> json) {
    return OrderDataModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      codAmount: (json['codAmount'] as num).toDouble(),
      isDiscounted: json['isDiscounted'] as bool,
      items: (json['items'] as List<dynamic>)
          .map((itemJson) => OrderItemDataModel.fromJson(itemJson as Map<String, dynamic>))
          .toList(),
      // COD fields - handle missing fields gracefully
      collectedAmount: json.containsKey('collectedAmount') && json['collectedAmount'] != null 
          ? (json['collectedAmount'] as num).toDouble() 
          : null,
      collectionDate: json.containsKey('collectionDate') && json['collectionDate'] != null 
          ? DateTime.parse(json['collectionDate'] as String) 
          : null,
      collectionNotes: json.containsKey('collectionNotes') ? json['collectionNotes'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'codAmount': codAmount,
      'isDiscounted': isDiscounted,
      'items': items.map((item) => item.toJson()).toList(),
      'collectedAmount': collectedAmount,
      'collectionDate': collectionDate?.toIso8601String(),
      'collectionNotes': collectionNotes,
    };
  }

  // Map to domain entity
  Order toEntity() {
    return Order(
      id: id,
      customerId: customerId,
      codAmount: codAmount,
      isDiscounted: isDiscounted,
      items: items.map((item) => item.toEntity()).toList(),
      collectedAmount: collectedAmount,
      collectionDate: collectionDate,
      collectionNotes: collectionNotes,
    );
  }

  @override
  List<Object?> get props => [id, customerId, codAmount, isDiscounted, items, collectedAmount, collectionDate, collectionNotes];
}