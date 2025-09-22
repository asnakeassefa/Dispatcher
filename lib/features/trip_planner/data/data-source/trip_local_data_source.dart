import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart' as injectable;
import 'package:drift/drift.dart';

import '../../../../core/exceptions/data_source_exceptions.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entity/vehicle.dart';
import '../model/trip_model.dart';

@injectable.injectable
class TripLocalDataSource {
  final AppDatabase _database;
  
  // In-memory storage for vehicle usage tracking
  static final Map<String, VehicleStatus> _vehicleUsage = {};

  TripLocalDataSource(this._database);

  // Trip CRUD operations
  Future<TripModel> createTrip(TripModel tripModel) async {
    try {
      // Simulate async operation
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Insert into database
      final tripCompanion = TripTableCompanion.insert(
        tripId: tripModel.tripId,
        date: tripModel.date,
        assignedVehicleId: Value(tripModel.assignedVehicleId),
        assignedOrderIds: tripModel.assignedOrderIds,
        statusIndex: tripModel.statusIndex,
      );
      
      final insertedId = await _database.into(_database.tripTable).insert(tripCompanion);
      
      // Return the created trip model with the database ID
      return tripModel.copyWith(id: insertedId);
    } catch (e) {
      throw DataSourceException('Failed to create trip: ${e.toString()}');
    }
  }

  Future<List<TripModel>> getAllTrips() async {
    try {
      // Simulate async operation
      await Future.delayed(const Duration(milliseconds: 100));
      
      final query = _database.select(_database.tripTable);
      final trips = await query.get();
      
      return trips.map((trip) => TripModel.fromData(trip)).toList();
    } catch (e) {
      throw DataSourceException('Failed to get all trips: ${e.toString()}');
    }
  }

  Future<TripModel?> getTripById(String tripId) async {
    try {
      // Simulate async operation
      await Future.delayed(const Duration(milliseconds: 100));
      
      final query = _database.select(_database.tripTable)
        ..where((t) => t.tripId.equals(tripId));
      
      final trip = await query.getSingleOrNull();
      return trip != null ? TripModel.fromData(trip) : null;
    } catch (e) {
      throw DataSourceException('Failed to get trip by ID "$tripId": ${e.toString()}');
    }
  }

  Future<TripModel> updateTrip(TripModel tripModel) async {
    try {
      // Simulate async operation
      await Future.delayed(const Duration(milliseconds: 100));
      
      final query = _database.update(_database.tripTable)
        ..where((t) => t.tripId.equals(tripModel.tripId));
      
      final tripCompanion = TripTableCompanion(
        tripId: Value(tripModel.tripId),
        date: Value(tripModel.date),
        assignedVehicleId: Value(tripModel.assignedVehicleId),
        assignedOrderIds: Value(tripModel.assignedOrderIds),
        statusIndex: Value(tripModel.statusIndex),
        updatedAt: Value(DateTime.now()),
      );
      
      await query.write(tripCompanion);
      return tripModel;
    } catch (e) {
      throw DataSourceException('Failed to update trip: ${e.toString()}');
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      // Simulate async operation
      await Future.delayed(const Duration(milliseconds: 100));
      
      final query = _database.delete(_database.tripTable)
        ..where((t) => t.tripId.equals(tripId));
      
      await query.go();
    } catch (e) {
      throw DataSourceException('Failed to delete trip "$tripId": ${e.toString()}');
    }
  }

  // Trip assignment operations
  Future<TripModel> assignOrdersToTrip(String tripId, List<String> orderIds) async {
    try {
      final tripModel = await getTripById(tripId);
      if (tripModel == null) {
        throw DataSourceException('Trip not found: $tripId');
      }

      final updatedModel = tripModel.copyWith(
        assignedOrderIds: orderIds,
        updatedAt: DateTime.now(),
      );
      
      return await updateTrip(updatedModel);
    } catch (e) {
      if (e is DataSourceException) {
        rethrow;
      }
      throw DataSourceException('Failed to assign orders to trip: ${e.toString()}');
    }
  }

  Future<TripModel> assignVehicleToTrip(String tripId, String vehicleId) async {
    try {
      final tripModel = await getTripById(tripId);
      if (tripModel == null) {
        throw DataSourceException('Trip not found: $tripId');
      }

      final updatedModel = tripModel.copyWith(
        assignedVehicleId: vehicleId,
        updatedAt: DateTime.now(),
      );
      
      return await updateTrip(updatedModel);
    } catch (e) {
      if (e is DataSourceException) {
        rethrow;
      }
      throw DataSourceException('Failed to assign vehicle to trip: ${e.toString()}');
    }
  }

  Future<TripModel> updateTripStatus(String tripId, int statusIndex) async {
    try {
      final tripModel = await getTripById(tripId);
      if (tripModel == null) {
        throw DataSourceException('Trip not found: $tripId');
      }

      final updatedModel = tripModel.copyWith(
        statusIndex: statusIndex,
        updatedAt: DateTime.now(),
      );
      
      return await updateTrip(updatedModel);
    } catch (e) {
      if (e is DataSourceException) {
        rethrow;
      }
      throw DataSourceException('Failed to update trip status: ${e.toString()}');
    }
  }

  // Query operations
  Future<List<TripModel>> getTripsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      // Simulate async operation
      await Future.delayed(const Duration(milliseconds: 100));
      
      final query = _database.select(_database.tripTable)
        ..where((t) => t.date.isBiggerOrEqualValue(startDate) & 
                      t.date.isSmallerOrEqualValue(endDate));
      
      final trips = await query.get();
      return trips.map((trip) => TripModel.fromData(trip)).toList();
    } catch (e) {
      throw DataSourceException('Failed to get trips by date range: ${e.toString()}');
    }
  }

  Future<List<TripModel>> getTripsByStatus(int statusIndex) async {
    try {
      // Simulate async operation
      await Future.delayed(const Duration(milliseconds: 100));
      
      final query = _database.select(_database.tripTable)
        ..where((t) => t.statusIndex.equals(statusIndex));
      
      final trips = await query.get();
      return trips.map((trip) => TripModel.fromData(trip)).toList();
    } catch (e) {
      throw DataSourceException('Failed to get trips by status: ${e.toString()}');
    }
  }

  Future<List<TripModel>> getTripsByVehicleId(String vehicleId) async {
    try {
      // Simulate async operation
      await Future.delayed(const Duration(milliseconds: 100));
      
      final query = _database.select(_database.tripTable)
        ..where((t) => t.assignedVehicleId.equals(vehicleId));
      
      final trips = await query.get();
      return trips.map((trip) => TripModel.fromData(trip)).toList();
    } catch (e) {
      throw DataSourceException('Failed to get trips by vehicle ID: ${e.toString()}');
    }
  }

  // Vehicle methods
  Future<List<Vehicle>> getAvailableVehicles() async {
    try {
      // Load vehicle data from JSON
      final String jsonString = await rootBundle.loadString('assets/data/dispatcher_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      final List<dynamic> vehiclesJson = jsonData['vehicles'] as List<dynamic>;
      
      return vehiclesJson.map((vehicleJson) {
        final String id = vehicleJson['id'] as String;
        final String name = vehicleJson['name'] as String;
        final Map<String, dynamic> capacity = vehicleJson['capacity'] as Map<String, dynamic>;
        final double weightCapacity = (capacity['weight'] as num).toDouble();
        final double volumeCapacity = (capacity['volume'] as num).toDouble();
        
        // Get current status from usage tracking, default to available
        final VehicleStatus status = _vehicleUsage[id] ?? VehicleStatus.available;
        
        // Generate plate number from vehicle ID
        final String plateNumber = _generatePlateNumber(id);
        
        // Generate driver name
        final String driverName = _generateDriverName(id);
        
        return Vehicle(
          id: id,
          plateNumber: plateNumber,
          capacity: weightCapacity,
          volumeCapacity: volumeCapacity,
          driverName: driverName,
          status: status,
        );
      }).toList();
    } catch (e) {
      throw DataSourceException('Failed to load vehicles: ${e.toString()}');
    }
  }

  Future<Vehicle?> getVehicleById(String id) async {
    try {
      final allVehicles = await getAvailableVehicles();
      return allVehicles.where((vehicle) => vehicle.id == id).firstOrNull;
    } catch (e) {
      throw DataSourceException('Failed to get vehicle by ID "$id": ${e.toString()}');
    }
  }

  Future<void> updateVehicleStatus(String vehicleId, VehicleStatus status) async {
    try {
      _vehicleUsage[vehicleId] = status;
    } catch (e) {
      throw DataSourceException('Failed to update vehicle status: ${e.toString()}');
    }
  }

  // Helper methods to generate missing data
  String _generatePlateNumber(String vehicleId) {
    final Map<String, String> plateNumbers = {
      'v01': 'ABC-123',
      'v02': 'XYZ-789',
      'v03': 'DEF-456',
      'v04': 'GHI-012',
      'v05': 'JKL-345',
    };
    return plateNumbers[vehicleId] ?? 'UNK-000';
  }

  String _generateDriverName(String vehicleId) {
    final Map<String, String> driverNames = {
      'v01': 'John Smith',
      'v02': 'Jane Doe',
      'v03': 'Mike Johnson',
      'v04': 'Sarah Wilson',
      'v05': 'David Brown',
    };
    return driverNames[vehicleId] ?? 'Unknown Driver';
  }
}

// Extension to add copyWith method to TripModel
extension TripModelCopyWith on TripModel {
  TripModel copyWith({
    int? id,
    String? tripId,
    DateTime? date,
    String? assignedVehicleId,
    List<String>? assignedOrderIds,
    int? statusIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      assignedVehicleId: assignedVehicleId ?? this.assignedVehicleId,
      assignedOrderIds: assignedOrderIds ?? this.assignedOrderIds,
      statusIndex: statusIndex ?? this.statusIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}