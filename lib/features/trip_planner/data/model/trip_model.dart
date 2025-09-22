import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entity/trip.dart';
import '../../domain/entity/vehicle.dart';
import '../../../order/domain/entity/order.dart';

class TripModel extends Equatable {
  final int? id;
  final String tripId;
  final DateTime date;
  final String? assignedVehicleId;
  final List<String> assignedOrderIds;
  final int statusIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TripModel({
    this.id,
    required this.tripId,
    required this.date,
    this.assignedVehicleId,
    required this.assignedOrderIds,
    required this.statusIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripModel.fromEntity(Trip trip) {
    return TripModel(
      tripId: trip.id,
      date: trip.date,
      assignedVehicleId: trip.assignedVehicle?.id,
      assignedOrderIds: trip.assignedOrders.map((order) => order.id).toList(),
      statusIndex: trip.status.index,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Trip toEntity({
    Vehicle? assignedVehicle,
    List<Order> assignedOrders = const [],
  }) {
    return Trip(
      id: tripId,
      date: date,
      assignedVehicle: assignedVehicle,
      assignedOrders: assignedOrders,
      status: TripStatus.values[statusIndex],
    );
  }

  TripTableCompanion toCompanion() {
    return TripTableCompanion.insert(
      tripId: tripId,
      date: date,
      assignedVehicleId: Value(assignedVehicleId),
      assignedOrderIds: assignedOrderIds,
      statusIndex: statusIndex,
    );
  }

  factory TripModel.fromData(TripTableData data) {
    return TripModel(
      id: data.id,
      tripId: data.tripId,
      date: data.date,
      assignedVehicleId: data.assignedVehicleId,
      assignedOrderIds: data.assignedOrderIds,
      statusIndex: data.statusIndex,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tripId,
        date,
        assignedVehicleId,
        assignedOrderIds,
        statusIndex,
        createdAt,
        updatedAt,
      ];
}
