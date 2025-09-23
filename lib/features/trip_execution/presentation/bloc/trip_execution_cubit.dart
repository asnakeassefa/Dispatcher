import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart' as injectable;

import '../../domain/entity/trip_execution.dart';
import '../../domain/entity/stop.dart';
import '../../domain/repository/trip_execution_repository.dart';
import 'trip_execution_state.dart';
import '../../domain/usecase/create_trip_execution_from_trip_usecase.dart';
import '../../../trip_planner/domain/usecase/get_trip_by_id_usecase.dart';
import '../../../trip_planner/domain/usecase/update_trip_status_usecase.dart';
import '../../../trip_planner/domain/entity/trip.dart'; // Add this import for TripStatus
import '../../../order/domain/entity/order.dart'; // Add this import

@injectable.injectable
class TripExecutionCubit extends HydratedCubit<TripExecutionState> {
  final TripExecutionRepository _repository;
  final CreateTripExecutionFromTripUseCase _createTripExecutionFromTripUseCase;
  final GetTripByIdUseCase _getTripByIdUseCase;
  final UpdateTripStatusUseCase _updateTripStatusUseCase;

  TripExecutionCubit(
    this._repository,
    this._createTripExecutionFromTripUseCase,
    this._getTripByIdUseCase,
    this._updateTripStatusUseCase,
  ) : super(const TripExecutionInitial());

  @override
  TripExecutionState? fromJson(Map<String, dynamic> json) {
    try {
      final String stateType = json['type'] as String;
      
      switch (stateType) {
        case 'TripExecutionLoaded':
          return TripExecutionLoaded.fromJson(json['data'] as Map<String, dynamic>);
        case 'TripExecutionListLoaded':
          return TripExecutionListLoaded.fromJson(json['data'] as Map<String, dynamic>);
        case 'TripExecutionError':
          return TripExecutionError.fromJson(json['data'] as Map<String, dynamic>);
        case 'TripExecutionInitial':
          return const TripExecutionInitial();
        default:
          return const TripExecutionInitial();
      }
    } catch (e) {
      return const TripExecutionInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(TripExecutionState state) {
    try {
      if (state is TripExecutionLoaded) {
        return {
          'type': 'TripExecutionLoaded',
          'data': state.toJson(),
        };
      } else if (state is TripExecutionListLoaded) {
        return {
          'type': 'TripExecutionListLoaded',
          'data': state.toJson(),
        };
      } else if (state is TripExecutionError) {
        return {
          'type': 'TripExecutionError',
          'data': state.toJson(),
        };
      } else if (state is TripExecutionInitial) {
        return {
          'type': 'TripExecutionInitial',
          'data': {},
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> loadTripExecution(String tripId) async {
    try {
      emit(const TripExecutionLoading());
      final tripExecution = await _repository.getTripExecutionByTripId(tripId);
      
      if (tripExecution != null) {
        emit(TripExecutionLoaded(
          tripExecution: tripExecution,
          lastUpdated: DateTime.now(),
        ));
      } else {
        emit(TripExecutionError(
          message: 'Trip execution not found for trip: $tripId',
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      emit(TripExecutionError(
        message: 'Failed to load trip execution: ${e.toString()}',
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> loadActiveTripExecutions() async {
    try {
      emit(const TripExecutionLoading());
      final tripExecutions = await _repository.getActiveTripExecutions();
      
      emit(TripExecutionListLoaded(
        tripExecutions: tripExecutions,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(TripExecutionError(
        message: 'Failed to load active trip executions: ${e.toString()}',
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> startTripExecution(String tripExecutionId) async {
    try {
      // Get current state BEFORE emitting loading
      final currentState = state;
      if (currentState is! TripExecutionLoaded) {
        throw Exception('Invalid state for starting trip execution');
      }
      
      // Store the trip execution ID before emitting loading
      final storedTripExecutionId = currentState.tripExecution.id;
      
      emit(const TripExecutionLoading());
      final updatedTripExecution = await _repository.startTripExecution(storedTripExecutionId);
      
      emit(TripExecutionLoaded(
        tripExecution: updatedTripExecution,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(TripExecutionError(
        message: 'Failed to start trip execution: ${e.toString()}',
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> completeTripExecution(String tripExecutionId, {String? driverNotes}) async {
    try {
      // Get current state BEFORE emitting loading
      final currentState = state;
      if (currentState is! TripExecutionLoaded) {
        throw Exception('Invalid state for completing trip execution');
      }
      
      // Store the trip execution ID before emitting loading
      final storedTripExecutionId = currentState.tripExecution.id;
      
      emit(const TripExecutionLoading());
      final updatedTripExecution = await _repository.completeTripExecution(
        storedTripExecutionId,
        driverNotes: driverNotes,
      );
      
      // Update the original trip status to completed
      await _updateTripStatusUseCase.call(
        tripId: updatedTripExecution.trip.id,
        status: TripStatus.completed,
      );
      
      emit(TripExecutionLoaded(
        tripExecution: updatedTripExecution,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(TripExecutionError(
        message: 'Failed to complete trip execution: ${e.toString()}',
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> cancelTripExecution(String tripExecutionId, {String? reason}) async {
    try {
      final currentState = state;
      if (currentState is! TripExecutionLoaded) {
        throw Exception('Invalid state for cancelling trip execution');
      }
      
      emit(const TripExecutionLoading());
      
      // Cancel the trip execution
      final updatedTripExecution = await _repository.cancelTripExecution(tripExecutionId, reason: reason);
      
      // Update the original trip status to cancelled
      await _updateTripStatusUseCase.call(
        tripId: updatedTripExecution.trip.id,
        status: TripStatus.cancelled,
      );
      
      emit(TripExecutionLoaded(
        tripExecution: updatedTripExecution,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(TripExecutionError(
        message: 'Failed to cancel trip execution: ${e.toString()}',
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> startStop(String stopId) async {
    try {
      // Get current state BEFORE emitting loading
      final currentState = state;
      if (currentState is! TripExecutionLoaded) {
        throw Exception('Invalid state for starting stop');
      }
      
      // Store the trip execution ID before emitting loading
      final tripExecutionId = currentState.tripExecution.id;
      final tripExecution = currentState.tripExecution;
      
      emit(const TripExecutionLoading());
      
      // If trip execution is still not started, start it first
      if (tripExecution.status == TripExecutionStatus.notStarted) {
        await _repository.startTripExecution(tripExecutionId);
      }
      
      // Start the stop
      await _repository.startStop(stopId);
      
      // Get the updated trip execution using the stored ID
      final updatedTripExecution = await _repository.getTripExecutionById(tripExecutionId);
      if (updatedTripExecution != null) {
        // Force a new state by ensuring the timestamp is different
        emit(TripExecutionLoaded(
          tripExecution: updatedTripExecution,
          lastUpdated: DateTime.now(),
        ));
      } else {
        throw Exception('Failed to reload trip execution after starting stop');
      }
    } catch (e) {
      emit(TripExecutionError(
        message: 'Failed to start stop: ${e.toString()}',
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> completeStop(String stopId, {String? notes, Map<String, Map<String, dynamic>>? codData}) async {
    try {
      // Get current state BEFORE emitting loading
      final currentState = state;
      if (currentState is! TripExecutionLoaded) {
        throw Exception('Invalid state for completing stop');
      }
      
      // Store the trip execution ID before emitting loading
      final tripExecutionId = currentState.tripExecution.id;
      
      emit(const TripExecutionLoading());
      
      // Complete the stop
      await _repository.completeStop(stopId, notes: notes, codData: codData);
      
      // Get the updated trip execution using the stored ID
      final updatedTripExecution = await _repository.getTripExecutionById(tripExecutionId);
      if (updatedTripExecution != null) {
        // Check if all stops are completed
        final allStopsCompleted = updatedTripExecution.stops.every((stop) => stop.isCompleted());
        
        if (allStopsCompleted && updatedTripExecution.status != TripExecutionStatus.completed) {
          // Auto-complete the trip execution
          final completedTripExecution = await _repository.completeTripExecution(
            tripExecutionId,
            driverNotes: 'Auto-completed: All stops completed',
          );
          
          // Update the original trip status to completed
          await _updateTripStatusUseCase.call(
            tripId: updatedTripExecution.trip.id,
            status: TripStatus.completed,
          );
          
          emit(TripExecutionLoaded(
            tripExecution: completedTripExecution,
            lastUpdated: DateTime.now(),
          ));
        } else {
          emit(TripExecutionLoaded(
            tripExecution: updatedTripExecution,
            lastUpdated: DateTime.now(),
          ));
        }
      } else {
        throw Exception('Failed to reload trip execution after completing stop');
      }
    } catch (e) {
      emit(TripExecutionError(
        message: 'Failed to complete stop: ${e.toString()}',
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> failStop(String stopId, {String? reason}) async {
    try {
      // Get current state BEFORE emitting loading
      final currentState = state;
      if (currentState is! TripExecutionLoaded) {
        throw Exception('Invalid state for failing stop');
      }
      
      // Store the trip execution ID before emitting loading
      final storedTripExecutionId = currentState.tripExecution.id;
      
      emit(const TripExecutionLoading());
      final updatedTripExecution = await _repository.cancelTripExecution(
        storedTripExecutionId,
        reason: reason ?? "",
      );
      
      // Update the original trip status to cancelled
      await _updateTripStatusUseCase.call(
        tripId: updatedTripExecution.trip.id,
        status: TripStatus.cancelled,
      );
      
      emit(TripExecutionLoaded(
        tripExecution: updatedTripExecution,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(TripExecutionError(
        message: 'Failed to cancel trip execution: ${e.toString()}',
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> createTripExecutionFromTrip(String tripId) async {
    try {
      emit(const TripExecutionLoading());
      
      // First get the trip
      final trip = await _getTripByIdUseCase(tripId);
      if (trip == null) {
        emit(TripExecutionError(
          message: 'Trip not found: $tripId',
          timestamp: DateTime.now(),
        ));
        return;
      }

      // Create trip execution from trip
      final tripExecution = await _createTripExecutionFromTripUseCase(trip);
      
      emit(TripExecutionLoaded(
        tripExecution: tripExecution,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(TripExecutionError(
        message: 'Failed to create trip execution: ${e.toString()}',
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> refreshTripExecution(String tripId) async {
    try {
      emit(const TripExecutionLoading());
      
      // Reload the trip execution to get any new orders/stops
      final tripExecution = await _repository.getTripExecutionByTripId(tripId);
      
      if (tripExecution != null) {
        emit(TripExecutionLoaded(
          tripExecution: tripExecution,
          lastUpdated: DateTime.now(),
        ));
      } else {
        // If no trip execution exists, create one
        await createTripExecutionFromTrip(tripId);
      }
    } catch (e) {
      emit(TripExecutionError(
        message: 'Failed to refresh trip execution: ${e.toString()}',
        timestamp: DateTime.now(),
      ));
    }
  }

  void clearError() {
    if (state is TripExecutionError) {
      emit(const TripExecutionInitial());
    }
  }

  // Complete a specific order within a stop
  Future<void> completeOrder(String stopId, String orderId, {
    double? collectedAmount,
    String? collectionNotes,
    bool isPartialDelivery = false, // Add this parameter
  }) async {
    try {
      final currentState = state;
      if (currentState is! TripExecutionLoaded) {
        throw Exception('Invalid state for completing order');
      }
      
      final tripExecutionId = currentState.tripExecution.id;
      
      // Find the order to validate business rules
      final stop = currentState.tripExecution.stops.firstWhere(
        (s) => s.id == stopId,
        orElse: () => throw Exception('Stop not found: $stopId'),
      );
      
      final order = stop.orders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => throw Exception('Order not found: $orderId'),
      );
      
      // Business rule validation: Partial delivery policy
      if (isPartialDelivery && order.isDiscounted) {
        emit(TripExecutionError(message: 'Partial delivery is not allowed for discounted orders. Please deliver all items or mark as failed.', timestamp: DateTime.now()));
        return;
      }
      
      emit(const TripExecutionLoading());
      
      // Complete the order
      await _repository.completeOrder(stopId, orderId, 
        collectedAmount: collectedAmount,
        collectionNotes: collectionNotes,
        isPartialDelivery: isPartialDelivery,
      );
      
      // Reload the trip execution
      final updatedTripExecution = await _repository.getTripExecutionById(tripExecutionId);
      if (updatedTripExecution != null) {
        // Check if all stops are completed
        final allStopsCompleted = updatedTripExecution.stops.every((stop) => stop.isCompleted());
        
        if (allStopsCompleted && updatedTripExecution.status != TripExecutionStatus.completed) {
          // Auto-complete the trip execution
          final completedTripExecution = await _repository.completeTripExecution(
            tripExecutionId,
            driverNotes: 'Auto-completed: All stops completed',
          );
          
          // Update the original trip status to completed
          await _updateTripStatusUseCase.call(
            tripId: updatedTripExecution.trip.id,
            status: TripStatus.completed,
          );
          
          emit(TripExecutionLoaded(
            tripExecution: completedTripExecution,
            lastUpdated: DateTime.now(),
          ));
        } else {
          emit(TripExecutionLoaded(
            tripExecution: updatedTripExecution,
            lastUpdated: DateTime.now(),
          ));
        }
      }
    } catch (e) {
      emit(TripExecutionError(message: 'Failed to complete order: ${e.toString()}', timestamp: DateTime.now()));
    }
  }

  // Fail a specific order within a stop
  Future<void> failOrder(String stopId, String orderId, {required String reason}) async {
    try {
      final currentState = state;
      if (currentState is! TripExecutionLoaded) {
        throw Exception('Invalid state for failing order');
      }
      
      final tripExecutionId = currentState.tripExecution.id;
      
      emit(const TripExecutionLoading());
      
      // Fail the order
      await _repository.failOrder(stopId, orderId, reason: reason);
      
      // Reload the trip execution
      final updatedTripExecution = await _repository.getTripExecutionById(tripExecutionId);
      if (updatedTripExecution != null) {
        emit(TripExecutionLoaded(
          tripExecution: updatedTripExecution,
          lastUpdated: DateTime.now(),
        ));
      }
    } catch (e) {
      emit(TripExecutionError(message: 'Failed to fail order: ${e.toString()}', timestamp: DateTime.now()));
    }
  }
}
