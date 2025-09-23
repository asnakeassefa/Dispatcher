import 'package:equatable/equatable.dart';

import '../../../trip_planner/domain/entity/trip.dart';
import '../../../trip_planner/domain/entity/vehicle.dart';
import 'stop.dart';

enum TripExecutionStatus {
  notStarted,
  inProgress,
  completed,
  cancelled,
}

class TripExecution extends Equatable {
  final String id;
  final Trip trip;
  final Vehicle vehicle;
  final List<Stop> stops;
  final TripExecutionStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? driverNotes;

  const TripExecution({
    required this.id,
    required this.trip,
    required this.vehicle,
    required this.stops,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.driverNotes,
  });

  // Helper getters
  int get totalStops => stops.length;
  int get completedStops => stops.where((stop) => stop.isCompleted()).length;
  int get pendingStops => stops.where((stop) => stop.status == StopStatus.pending).length;
  int get inTransitStops => stops.where((stop) => stop.status == StopStatus.inTransit).length;
  int get failedStops => stops.where((stop) => stop.status == StopStatus.failed).length;

  double get completionPercentage => totalStops > 0 ? (completedStops / totalStops) * 100 : 0.0;

  Stop? get currentStop => stops.firstWhere(
    (stop) => stop.status == StopStatus.inTransit,
    orElse: () => stops.firstWhere(
      (stop) => stop.status == StopStatus.pending,
      orElse: () => stops.first,
    ),
  );

  List<Stop> get pendingStopsList => stops.where((stop) => stop.status == StopStatus.pending).toList();
  List<Stop> get completedStopsList => stops.where((stop) => stop.isCompleted()).toList();

  // State machine validation
  bool canStart() => status == TripExecutionStatus.notStarted && stops.isNotEmpty;
  bool canComplete() => status == TripExecutionStatus.inProgress && completedStops == totalStops;
  bool canCancel() => status == TripExecutionStatus.inProgress;

  // State transitions
  TripExecution start() {
    if (!canStart()) {
      throw StateTransitionException('Cannot start trip execution from ${status.name} status');
    }
    return copyWith(
      status: TripExecutionStatus.inProgress,
      startedAt: DateTime.now(),
    );
  }

  TripExecution complete({String? driverNotes}) {
    if (!canComplete()) {
      throw StateTransitionException('Cannot complete trip execution. ${totalStops - completedStops} stops still pending.');
    }
    return copyWith(
      status: TripExecutionStatus.completed,
      completedAt: DateTime.now(),
      driverNotes: driverNotes,
    );
  }

  TripExecution cancel({String? reason}) {
    if (!canCancel()) {
      throw StateTransitionException('Cannot cancel trip execution from ${status.name} status');
    }
    return copyWith(
      status: TripExecutionStatus.cancelled,
      completedAt: DateTime.now(),
      driverNotes: reason,
    );
  }

  TripExecution copyWith({
    String? id,
    Trip? trip,
    Vehicle? vehicle,
    List<Stop>? stops,
    TripExecutionStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    String? driverNotes,
  }) {
    return TripExecution(
      id: id ?? this.id,
      trip: trip ?? this.trip,
      vehicle: vehicle ?? this.vehicle,
      stops: stops ?? this.stops,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      driverNotes: driverNotes ?? this.driverNotes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        trip,
        vehicle,
        stops,
        status,
        startedAt,
        completedAt,
        driverNotes,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip': trip.toJson(),
      'vehicle': vehicle.toJson(),
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'status': status.name,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'driverNotes': driverNotes,
    };
  }

  factory TripExecution.fromJson(Map<String, dynamic> json) {
    return TripExecution(
      id: json['id'] as String,
      trip: Trip.fromJson(json['trip'] as Map<String, dynamic>),
      vehicle: Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>),
      stops: (json['stops'] as List<dynamic>)
          .map((stopJson) => Stop.fromJson(stopJson as Map<String, dynamic>))
          .toList(),
      status: TripExecutionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TripExecutionStatus.notStarted,
      ),
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      driverNotes: json['driverNotes'] as String?,
    );
  }
}

class StateTransitionException implements Exception {
  final String message;
  StateTransitionException(this.message);
  
  @override
  String toString() => 'StateTransitionException: $message';
}
