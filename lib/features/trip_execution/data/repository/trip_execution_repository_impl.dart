import 'package:injectable/injectable.dart' as injectable;

import '../../domain/entity/trip_execution.dart';
import '../../domain/entity/stop.dart';
import '../../domain/repository/trip_execution_repository.dart';
import '../data-source/trip_execution_local_data_source.dart';

@injectable.LazySingleton(as: TripExecutionRepository)
class TripExecutionRepositoryImpl implements TripExecutionRepository {
  final TripExecutionLocalDataSource _localDataSource;

  TripExecutionRepositoryImpl(this._localDataSource);

  @override
  Future<TripExecution> createTripExecution(TripExecution tripExecution) async {
    return await _localDataSource.createTripExecution(tripExecution);
  }

  @override
  Future<TripExecution?> getTripExecutionById(String id) async {
    return await _localDataSource.getTripExecutionById(id);
  }

  @override
  Future<TripExecution?> getTripExecutionByTripId(String tripId) async {
    return await _localDataSource.getTripExecutionByTripId(tripId);
  }

  @override
  Future<List<TripExecution>> getActiveTripExecutions() async {
    return await _localDataSource.getActiveTripExecutions();
  }

  @override
  Future<List<TripExecution>> getAllTripExecutions() async {
    return await _localDataSource.getAllTripExecutions();
  }

  @override
  Future<TripExecution> startTripExecution(String id) async {
    return await _localDataSource.startTripExecution(id);
  }

  @override
  Future<TripExecution> completeTripExecution(String id, {String? driverNotes}) async {
    return await _localDataSource.completeTripExecution(id, driverNotes: driverNotes);
  }

  @override
  Future<TripExecution> cancelTripExecution(String id, {String? reason}) async {
    return await _localDataSource.cancelTripExecution(id, reason: reason);
  }

  @override
  Future<Stop> startStop(String stopId) async {
    return await _localDataSource.startStop(stopId);
  }

  @override
  Future<Stop> completeStop(String stopId, {String? notes, Map<String, Map<String, dynamic>>? codData}) async {
    return await _localDataSource.completeStop(stopId, notes: notes, codData: codData);
  }

  @override
  Future<Stop> failStop(String stopId, {required String reason, String? notes}) async {
    return await _localDataSource.failStop(stopId, reason: reason, notes: notes);
  }

  @override
  Future<Stop> completeOrder(String stopId, String orderId, {
    double? collectedAmount,
    String? collectionNotes,
  }) async {
    return await _localDataSource.completeOrder(stopId, orderId,
      collectedAmount: collectedAmount,
      collectionNotes: collectionNotes,
    );
  }

  @override
  Future<Stop> failOrder(String stopId, String orderId, {required String reason}) async {
    return await _localDataSource.failOrder(stopId, orderId, reason: reason);
  }

  @override
  Future<TripExecution> updateTripExecution(TripExecution tripExecution) async {
    return await _localDataSource.updateTripExecution(tripExecution);
  }
}
