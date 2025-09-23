import 'dart:convert';
import 'package:injectable/injectable.dart' as injectable;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/exceptions/data_source_exceptions.dart';
import '../../../order/domain/entity/order.dart';
import '../../domain/entity/trip_execution.dart';
import '../../domain/entity/stop.dart';

@injectable.injectable
class TripExecutionLocalDataSource {
  static const String _tripExecutionsKey = 'trip_executions_data';
  static const String _stopsKey = 'stops_data';

  // In-memory storage for trip executions
  static final Map<String, TripExecution> _tripExecutions = {};
  static final Map<String, Stop> _stops = {};

  TripExecutionLocalDataSource() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load trip executions
      final tripExecutionsJson = prefs.getString(_tripExecutionsKey);
      if (tripExecutionsJson != null) {
        final List<dynamic> tripExecutionsList = json.decode(tripExecutionsJson);
        for (final tripExecutionJson in tripExecutionsList) {
          final tripExecution = TripExecution.fromJson(tripExecutionJson);
          _tripExecutions[tripExecution.id] = tripExecution;
        }
      }

      // Load stops
      final stopsJson = prefs.getString(_stopsKey);
      if (stopsJson != null) {
        final List<dynamic> stopsList = json.decode(stopsJson);
        for (final stopJson in stopsList) {
          final stop = Stop.fromJson(stopJson);
          _stops[stop.id] = stop;
        }
      }
    } catch (e) {
      // If loading fails, start with empty data
      print('Failed to load trip execution data: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save trip executions
      final tripExecutionsList = _tripExecutions.values.map((te) => te.toJson()).toList();
      await prefs.setString(_tripExecutionsKey, json.encode(tripExecutionsList));

      // Save stops
      final stopsList = _stops.values.map((stop) => stop.toJson()).toList();
      await prefs.setString(_stopsKey, json.encode(stopsList));
    } catch (e) {
      throw DataSourceException('Failed to save trip execution data: ${e.toString()}');
    }
  }

  Future<TripExecution> createTripExecution(TripExecution tripExecution) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      _tripExecutions[tripExecution.id] = tripExecution;
      
      // Save all stops
      for (final stop in tripExecution.stops) {
        _stops[stop.id] = stop;
      }
      
      await _saveToStorage();
      return tripExecution;
    } catch (e) {
      throw DataSourceException('Failed to create trip execution: ${e.toString()}');
    }
  }

  Future<TripExecution?> getTripExecutionById(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return _tripExecutions[id];
    } catch (e) {
      throw DataSourceException('Failed to get trip execution by ID: ${e.toString()}');
    }
  }

  Future<TripExecution?> getTripExecutionByTripId(String tripId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Find trip execution by trip ID
      for (final tripExecution in _tripExecutions.values) {
        if (tripExecution.trip.id == tripId) {
          return tripExecution;
        }
      }
      return null;
    } catch (e) {
      throw DataSourceException('Failed to get trip execution by trip ID: ${e.toString()}');
    }
  }

  Future<List<TripExecution>> getActiveTripExecutions() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      return _tripExecutions.values
          .where((te) => te.status == TripExecutionStatus.inProgress)
          .toList();
    } catch (e) {
      throw DataSourceException('Failed to get active trip executions: ${e.toString()}');
    }
  }

  Future<List<TripExecution>> getAllTripExecutions() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return _tripExecutions.values.toList();
    } catch (e) {
      throw DataSourceException('Failed to get all trip executions: ${e.toString()}');
    }
  }

  Future<TripExecution> startTripExecution(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final tripExecution = _tripExecutions[id];
      if (tripExecution == null) {
        throw DataSourceException('Trip execution not found: $id');
      }

      final updatedTripExecution = tripExecution.start();
      _tripExecutions[id] = updatedTripExecution;
      await _saveToStorage();
      
      return updatedTripExecution;
    } catch (e) {
      throw DataSourceException('Failed to start trip execution: ${e.toString()}');
    }
  }

  Future<TripExecution> completeTripExecution(String id, {String? driverNotes}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final tripExecution = _tripExecutions[id];
      if (tripExecution == null) {
        throw DataSourceException('Trip execution not found: $id');
      }

      final updatedTripExecution = tripExecution.complete(driverNotes: driverNotes);
      _tripExecutions[id] = updatedTripExecution;
      await _saveToStorage();
      
      return updatedTripExecution;
    } catch (e) {
      throw DataSourceException('Failed to complete trip execution: ${e.toString()}');
    }
  }

  Future<TripExecution> cancelTripExecution(String id, {String? reason}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final tripExecution = _tripExecutions[id];
      if (tripExecution == null) {
        throw DataSourceException('Trip execution not found: $id');
      }

      final updatedTripExecution = tripExecution.cancel(reason: reason);
      _tripExecutions[id] = updatedTripExecution;
      await _saveToStorage();
      
      return updatedTripExecution;
    } catch (e) {
      throw DataSourceException('Failed to cancel trip execution: ${e.toString()}');
    }
  }

  Future<Stop> startStop(String stopId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final stop = _stops[stopId];
      if (stop == null) {
        throw DataSourceException('Stop not found: $stopId');
      }

      final updatedStop = stop.start();
      _stops[stopId] = updatedStop;
      
      // Update the trip execution
      final tripExecution = _tripExecutions.values.firstWhere(
        (te) => te.stops.any((s) => s.id == stopId),
        orElse: () => throw DataSourceException('Trip execution not found for stop: $stopId'),
      );
      
      final updatedStops = tripExecution.stops.map((s) => s.id == stopId ? updatedStop : s).toList();
      final updatedTripExecution = tripExecution.copyWith(stops: updatedStops);
      _tripExecutions[tripExecution.id] = updatedTripExecution;
      
      await _saveToStorage();
      return updatedStop;
    } catch (e) {
      throw DataSourceException('Failed to start stop: ${e.toString()}');
    }
  }

  Future<Stop> completeStop(String stopId, {String? notes, Map<String, Map<String, dynamic>>? codData}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final stop = _stops[stopId];
      if (stop == null) {
        throw DataSourceException('Stop not found: $stopId');
      }

      if (!stop.canComplete()) {
        throw DataSourceException('Stop cannot be completed in current state: ${stop.status}');
      }

      // Update orders with COD data if provided
      List<Order> updatedOrders = stop.orders;
      if (codData != null) {
        updatedOrders = stop.orders.map((order) {
          final orderCodData = codData[order.id];
          if (orderCodData != null) {
            return order.copyWith(
              collectedAmount: orderCodData['collectedAmount'] as double?,
              collectionDate: orderCodData['collectionDate'] as DateTime?,
              collectionNotes: orderCodData['collectionNotes'] as String?,
            );
          }
          return order;
        }).toList();
      }

      final updatedStop = stop.complete(notes: notes).copyWith(orders: updatedOrders);
      _stops[stopId] = updatedStop;
      
      return updatedStop;
    } catch (e) {
      throw DataSourceException('Failed to complete stop: ${e.toString()}');
    }
  }

  Future<Stop> failStop(String stopId, {required String reason, String? notes}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final stop = _stops[stopId];
      if (stop == null) {
        throw DataSourceException('Stop not found: $stopId');
      }

      final updatedStop = stop.fail(reason: reason, notes: notes);
      _stops[stopId] = updatedStop;
      
      // Update the trip execution
      final tripExecution = _tripExecutions.values.firstWhere(
        (te) => te.stops.any((s) => s.id == stopId),
        orElse: () => throw DataSourceException('Trip execution not found for stop: $stopId'),
      );
      
      final updatedStops = tripExecution.stops.map((s) => s.id == stopId ? updatedStop : s).toList();
      final updatedTripExecution = tripExecution.copyWith(stops: updatedStops);
      _tripExecutions[tripExecution.id] = updatedTripExecution;
      
      await _saveToStorage();
      return updatedStop;
    } catch (e) {
      throw DataSourceException('Failed to fail stop: ${e.toString()}');
    }
  }

  Future<TripExecution> updateTripExecution(TripExecution tripExecution) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      _tripExecutions[tripExecution.id] = tripExecution;
      
      // Update all stops
      for (final stop in tripExecution.stops) {
        _stops[stop.id] = stop;
      }
      
      await _saveToStorage();
      return tripExecution;
    } catch (e) {
      throw DataSourceException('Failed to update trip execution: ${e.toString()}');
    }
  }

  // Complete a specific order within a stop
  Future<Stop> completeOrder(String stopId, String orderId, {
    double? collectedAmount,
    String? collectionNotes,
    bool isPartialDelivery = false,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final stop = _stops[stopId];
      if (stop == null) {
        throw DataSourceException('Stop not found: $stopId');
      }

      final order = stop.orders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => throw DataSourceException('Order not found: $orderId'),
      );

      if (!order.canComplete()) {
        throw DataSourceException('Order cannot be completed in current state: ${order.status}');
      }

      // Complete the order with partial delivery flag
      final completedOrder = order.complete(
        collectedAmount: collectedAmount,
        collectionNotes: collectionNotes,
        isPartialDelivery: isPartialDelivery,
      );

      // Update the stop with the completed order
      final updatedStop = stop.updateOrder(completedOrder);
      
      // Auto-complete the stop if all orders are completed or failed
      final finalStop = updatedStop.allOrdersCompleted() && updatedStop.status == StopStatus.inTransit
          ? updatedStop.complete(notes: 'Auto-completed: All orders completed')
          : updatedStop;
      
      _stops[stopId] = finalStop;
      
      // Update the trip execution
      final tripExecution = _tripExecutions.values.firstWhere(
        (te) => te.stops.any((s) => s.id == stopId),
        orElse: () => throw DataSourceException('Trip execution not found for stop: $stopId'),
      );
      
      final updatedStops = tripExecution.stops.map((s) => s.id == stopId ? finalStop : s).toList();
      final updatedTripExecution = tripExecution.copyWith(stops: updatedStops);
      _tripExecutions[tripExecution.id] = updatedTripExecution;
      
      await _saveToStorage();
      return finalStop;
    } catch (e) {
      throw DataSourceException('Failed to complete order: ${e.toString()}');
    }
  }

  // Fail a specific order within a stop
  Future<Stop> failOrder(String stopId, String orderId, {required String reason}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final stop = _stops[stopId];
      if (stop == null) {
        throw DataSourceException('Stop not found: $stopId');
      }

      final order = stop.orders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => throw DataSourceException('Order not found: $orderId'),
      );

      if (!order.canFail()) {
        throw DataSourceException('Order cannot be failed in current state: ${order.status}');
      }

      // Fail the order
      final failedOrder = order.fail(reason: reason);

      // Update the stop with the failed order
      final updatedStop = stop.updateOrder(failedOrder);
      
      // Auto-complete the stop if all orders are completed or failed
      final finalStop = updatedStop.allOrdersCompleted() && updatedStop.status == StopStatus.inTransit
          ? updatedStop.complete(notes: 'Auto-completed: All orders processed')
          : updatedStop;
      
      _stops[stopId] = finalStop;
      
      // Update the trip execution
      final tripExecution = _tripExecutions.values.firstWhere(
        (te) => te.stops.any((s) => s.id == stopId),
        orElse: () => throw DataSourceException('Trip execution not found for stop: $stopId'),
      );
      
      final updatedStops = tripExecution.stops.map((s) => s.id == stopId ? finalStop : s).toList();
      final updatedTripExecution = tripExecution.copyWith(stops: updatedStops);
      _tripExecutions[tripExecution.id] = updatedTripExecution;
      
      await _saveToStorage();
      return finalStop;
    } catch (e) {
      throw DataSourceException('Failed to fail order: ${e.toString()}');
    }
  }
}
