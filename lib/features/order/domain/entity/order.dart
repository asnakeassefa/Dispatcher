

// create order entity
import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  completed,
  failed,
}

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

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
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

  @override
  List<Object?> get props => [sku, name, quantity, weight, volume, serialTracked];
}

class Order extends Equatable {
  final String id;
  final String customerId;
  final double codAmount;
  final bool isDiscounted;
  final List<OrderItem> items;
  final OrderStatus status;
  final double? collectedAmount; // New field for tracking collected cash
  final DateTime? collectionDate; // When cash was collected
  final String? collectionNotes; // Notes about collection
  final DateTime? completedAt; // When order was completed
  final String? failureReason; // Reason for failure if failed

  const Order({
    required this.id,
    required this.customerId,
    required this.codAmount,
    required this.isDiscounted,
    required this.items,
    this.status = OrderStatus.pending,
    this.collectedAmount,
    this.collectionDate,
    this.collectionNotes,
    this.completedAt,
    this.failureReason,
  });

  // Helper methods
  bool get isCollected => collectedAmount != null;
  bool get isCompleted => status == OrderStatus.completed;
  bool get isFailed => status == OrderStatus.failed;
  bool get isPending => status == OrderStatus.pending;
  
  double get collectionDifference => (collectedAmount ?? 0) - codAmount;
  bool get hasShortfall => collectionDifference < 0;
  bool get hasOverCollection => collectionDifference > 0;
  bool get isWithinTolerance => collectionDifference <= 1.0; // $1.00 tolerance
  
  // Weight and volume calculations
  double get totalWeight => items.fold(0.0, (sum, item) => sum + (item.weight * item.quantity));
  double get totalVolume => items.fold(0.0, (sum, item) => sum + (item.volume * item.quantity));

  // State machine methods
  bool canComplete() => status == OrderStatus.pending;
  bool canFail() => status == OrderStatus.pending;

  Order complete({
    double? collectedAmount,
    String? collectionNotes,
  }) {
    if (!canComplete()) {
      throw StateTransitionException('Cannot complete order from ${status.name} status');
    }
    
    return copyWith(
      status: OrderStatus.completed,
      collectedAmount: collectedAmount,
      collectionNotes: collectionNotes,
      collectionDate: DateTime.now(),
      completedAt: DateTime.now(),
    );
  }

  Order fail({required String reason}) {
    if (!canFail()) {
      throw StateTransitionException('Cannot fail order from ${status.name} status');
    }
    
    return copyWith(
      status: OrderStatus.failed,
      failureReason: reason,
      completedAt: DateTime.now(),
    );
  }

  Order copyWith({
    String? id,
    String? customerId,
    double? codAmount,
    bool? isDiscounted,
    List<OrderItem>? items,
    OrderStatus? status,
    double? collectedAmount,
    DateTime? collectionDate,
    String? collectionNotes,
    DateTime? completedAt,
    String? failureReason,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      codAmount: codAmount ?? this.codAmount,
      isDiscounted: isDiscounted ?? this.isDiscounted,
      items: items ?? this.items,
      status: status ?? this.status,
      collectedAmount: collectedAmount ?? this.collectedAmount,
      collectionDate: collectionDate ?? this.collectionDate,
      collectionNotes: collectionNotes ?? this.collectionNotes,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  @override
  List<Object?> get props => [
    id, 
    customerId, 
    codAmount, 
    isDiscounted, 
    items, 
    status,
    collectedAmount, 
    collectionDate, 
    collectionNotes,
    completedAt,
    failureReason,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'codAmount': codAmount,
      'isDiscounted': isDiscounted,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.name,
      'collectedAmount': collectedAmount,
      'collectionDate': collectionDate?.toIso8601String(),
      'collectionNotes': collectionNotes,
      'completedAt': completedAt?.toIso8601String(),
      'failureReason': failureReason,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      codAmount: (json['codAmount'] as num).toDouble(),
      isDiscounted: json['isDiscounted'] as bool,
      items: (json['items'] as List<dynamic>)
          .map((itemJson) => OrderItem.fromJson(itemJson as Map<String, dynamic>))
          .toList(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      collectedAmount: json['collectedAmount'] as double?,
      collectionDate: json['collectionDate'] != null ? DateTime.parse(json['collectionDate'] as String) : null,
      collectionNotes: json['collectionNotes'] as String?,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      failureReason: json['failureReason'] as String?,
    );
  }
}

class StateTransitionException implements Exception {
  final String message;
  StateTransitionException(this.message);
  
  @override
  String toString() => 'StateTransitionException: $message';
}