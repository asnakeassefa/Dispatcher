import 'package:equatable/equatable.dart';

enum StopStatus {
  pending,
  inTransit,
  completed,
  failed,
}

extension StopStatusExtension on StopStatus {
  String get displayName {
    switch (this) {
      case StopStatus.pending:
        return 'Pending';
      case StopStatus.inTransit:
        return 'In Transit';
      case StopStatus.completed:
        return 'Completed';
      case StopStatus.failed:
        return 'Failed';
    }
  }

  bool canTransitionTo(StopStatus newStatus) {
    const allowedTransitions = {
      StopStatus.pending: [StopStatus.inTransit, StopStatus.failed],
      StopStatus.inTransit: [StopStatus.completed, StopStatus.failed],
      StopStatus.completed: [],
      StopStatus.failed: [],
    };
    
    return allowedTransitions[this]?.contains(newStatus) ?? false;
  }
}

class Stop extends Equatable {
  final String orderId;
  final StopStatus status;
  final double? collectedCodAmount;
  final Map<String, String>? serialNumbers; // SKU -> Serial number mapping
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? failureReason;

  const Stop({
    required this.orderId,
    required this.status,
    this.collectedCodAmount,
    this.serialNumbers,
    this.startedAt,
    this.completedAt,
    this.failureReason,
  });

  Stop copyWith({
    String? orderId,
    StopStatus? status,
    double? collectedCodAmount,
    Map<String, String>? serialNumbers,
    DateTime? startedAt,
    DateTime? completedAt,
    String? failureReason,
  }) {
    return Stop(
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      collectedCodAmount: collectedCodAmount ?? this.collectedCodAmount,
      serialNumbers: serialNumbers ?? this.serialNumbers,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        status,
        collectedCodAmount,
        serialNumbers,
        startedAt,
        completedAt,
        failureReason,
      ];
}

class Trip extends Equatable {
  final String id;
  final String vehicleId;
  final List<Stop> stops;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const Trip({
    required this.id,
    required this.vehicleId,
    required this.stops,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  double get totalCodAmount => stops.fold(0.0, (sum, stop) => sum + (stop.collectedCodAmount ?? 0.0));
  
  int get completedStops => stops.where((stop) => stop.status == StopStatus.completed).length;
  int get failedStops => stops.where((stop) => stop.status == StopStatus.failed).length;
  int get pendingStops => stops.where((stop) => stop.status == StopStatus.pending).length;
  int get inTransitStops => stops.where((stop) => stop.status == StopStatus.inTransit).length;

  double get completionRate => stops.isEmpty ? 0.0 : completedStops / stops.length;
  
  bool get isCompleted => stops.isNotEmpty && stops.every((stop) => 
      stop.status == StopStatus.completed || stop.status == StopStatus.failed);
  
  Trip copyWith({
    String? id,
    String? vehicleId,
    List<Stop>? stops,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      stops: stops ?? this.stops,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [id, vehicleId, stops, createdAt, startedAt, completedAt];
}
