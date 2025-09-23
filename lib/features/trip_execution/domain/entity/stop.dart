import 'package:equatable/equatable.dart';

import '../../../order/domain/entity/order.dart';

enum StopStatus {
  pending,
  inTransit,
  completed,
  failed,
}

class Stop extends Equatable {
  final String id;
  final String tripId;
  final String customerId;
  final String customerName;
  final String address;
  final List<Order> orders;
  final StopStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? failureReason;
  final String? notes;

  const Stop({
    required this.id,
    required this.tripId,
    required this.customerId,
    required this.customerName,
    required this.address,
    required this.orders,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.failureReason,
    this.notes,
  });

  // Helper getters
  int get totalOrders => orders.length;
  int get completedOrders => orders.where((order) => order.isCompleted).length;
  int get failedOrders => orders.where((order) => order.isFailed).length;
  int get pendingOrders => orders.where((order) => order.isPending).length;
  
  double get totalWeight => orders.fold(0.0, (sum, order) => sum + order.totalWeight);
  double get totalVolume => orders.fold(0.0, (sum, order) => sum + order.totalVolume);
  double get totalCodAmount => orders.fold(0.0, (sum, order) => sum + order.codAmount);

  // State machine validation
  bool canStart() => status == StopStatus.pending;
  bool canComplete() => status == StopStatus.inTransit && allOrdersCompleted();
  bool canFail() => status == StopStatus.inTransit;
  bool isCompleted() => status == StopStatus.completed || status == StopStatus.failed;
  
  // Check if all orders are completed or failed
  bool allOrdersCompleted() => orders.every((order) => order.isCompleted || order.isFailed);
  bool hasAnyCompletedOrders() => orders.any((order) => order.isCompleted);
  bool hasAnyFailedOrders() => orders.any((order) => order.isFailed);

  // State transitions
  Stop start() {
    if (!canStart()) {
      throw StateTransitionException('Cannot start stop from ${status.name} status');
    }
    return copyWith(
      status: StopStatus.inTransit,
      startedAt: DateTime.now(),
    );
  }

  Stop complete({String? notes}) {
    if (!canComplete()) {
      throw StateTransitionException('Cannot complete stop from ${status.name} status');
    }
    return copyWith(
      status: StopStatus.completed,
      completedAt: DateTime.now(),
      notes: notes,
    );
  }

  Stop fail({required String reason, String? notes}) {
    if (!canFail()) {
      throw StateTransitionException('Cannot fail stop from ${status.name} status');
    }
    return copyWith(
      status: StopStatus.failed,
      completedAt: DateTime.now(),
      failureReason: reason,
      notes: notes,
    );
  }

  // Update a specific order in the stop
  Stop updateOrder(Order updatedOrder) {
    final updatedOrders = orders.map((order) {
      return order.id == updatedOrder.id ? updatedOrder : order;
    }).toList();
    
    return copyWith(orders: updatedOrders);
  }

  Stop copyWith({
    String? id,
    String? tripId,
    String? customerId,
    String? customerName,
    String? address,
    List<Order>? orders,
    StopStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    String? failureReason,
    String? notes,
  }) {
    return Stop(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
      orders: orders ?? List.from(this.orders),
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tripId,
        customerId,
        customerName,
        address,
        orders,
        status,
        startedAt,
        completedAt,
        failureReason,
        notes,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'customerId': customerId,
      'customerName': customerName,
      'address': address,
      'orders': orders.map((order) => order.toJson()).toList(),
      'status': status.name,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failureReason': failureReason,
      'notes': notes,
    };
  }

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      address: json['address'] as String,
      orders: (json['orders'] as List<dynamic>)
          .map((orderJson) => Order.fromJson(orderJson as Map<String, dynamic>))
          .toList(),
      status: StopStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StopStatus.pending,
      ),
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      failureReason: json['failureReason'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

class StateTransitionException implements Exception {
  final String message;
  StateTransitionException(this.message);
  
  @override
  String toString() => 'StateTransitionException: $message';
}
