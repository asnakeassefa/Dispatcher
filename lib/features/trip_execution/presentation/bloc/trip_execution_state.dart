import 'package:equatable/equatable.dart';

import '../../domain/entity/trip_execution.dart';
import '../../domain/entity/stop.dart';

abstract class TripExecutionState extends Equatable {
  const TripExecutionState();

  @override
  List<Object?> get props => [];
}

class TripExecutionInitial extends TripExecutionState {
  const TripExecutionInitial();
}

class TripExecutionLoading extends TripExecutionState {
  const TripExecutionLoading();
}

class TripExecutionLoaded extends TripExecutionState {
  final TripExecution tripExecution;
  final DateTime lastUpdated;

  const TripExecutionLoaded({
    required this.tripExecution,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [tripExecution, lastUpdated];

  TripExecutionLoaded copyWith({
    TripExecution? tripExecution,
    DateTime? lastUpdated,
  }) {
    return TripExecutionLoaded(
      tripExecution: tripExecution ?? this.tripExecution,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripExecution': tripExecution.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory TripExecutionLoaded.fromJson(Map<String, dynamic> json) {
    return TripExecutionLoaded(
      tripExecution: TripExecution.fromJson(json['tripExecution'] as Map<String, dynamic>),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

class TripExecutionError extends TripExecutionState {
  final String message;
  final DateTime timestamp;

  const TripExecutionError({
    required this.message,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [message, timestamp];

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TripExecutionError.fromJson(Map<String, dynamic> json) {
    return TripExecutionError(
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class TripExecutionListLoaded extends TripExecutionState {
  final List<TripExecution> tripExecutions;
  final DateTime lastUpdated;

  const TripExecutionListLoaded({
    required this.tripExecutions,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [tripExecutions, lastUpdated];

  Map<String, dynamic> toJson() {
    return {
      'tripExecutions': tripExecutions.map((te) => te.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory TripExecutionListLoaded.fromJson(Map<String, dynamic> json) {
    return TripExecutionListLoaded(
      tripExecutions: (json['tripExecutions'] as List<dynamic>)
          .map((teJson) => TripExecution.fromJson(teJson as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}
