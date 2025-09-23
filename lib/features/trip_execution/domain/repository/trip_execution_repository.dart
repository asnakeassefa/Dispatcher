import '../entity/trip_execution.dart';
import '../entity/stop.dart';

abstract class TripExecutionRepository {
  // Trip execution management
  Future<TripExecution> createTripExecution(TripExecution tripExecution);
  Future<TripExecution?> getTripExecutionById(String id);
  Future<TripExecution?> getTripExecutionByTripId(String tripId);
  Future<List<TripExecution>> getActiveTripExecutions();
  Future<List<TripExecution>> getAllTripExecutions();
  
  // Trip execution state management
  Future<TripExecution> startTripExecution(String id);
  Future<TripExecution> completeTripExecution(String id, {String? driverNotes});
  Future<TripExecution> cancelTripExecution(String id, {String? reason});
  
  // Stop management
  Future<Stop> startStop(String stopId);
  Future<Stop> completeStop(String stopId, {String? notes, Map<String, Map<String, dynamic>>? codData});
  Future<Stop> failStop(String stopId, {required String reason, String? notes});
  
  // Update trip execution
  Future<TripExecution> updateTripExecution(TripExecution tripExecution);

  // Complete a specific order within a stop
  Future<Stop> completeOrder(String stopId, String orderId, {
    double? collectedAmount,
    String? collectionNotes,
  });

  // Fail a specific order within a stop
  Future<Stop> failOrder(String stopId, String orderId, {required String reason});
}
