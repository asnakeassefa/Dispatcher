import '../../domain/entity/trip.dart';
import '../../domain/entity/vehicle.dart';
import '../../../order/domain/entity/order.dart';
import '../model/trip_model.dart';

class TripMapper {
  static TripModel toModel(Trip trip) {
    return TripModel.fromEntity(trip);
  }

  static Trip toEntity(
    TripModel model, {
    Vehicle? assignedVehicle,
    List<Order> assignedOrders = const [],
  }) {
    return model.toEntity(
      assignedVehicle: assignedVehicle,
      assignedOrders: assignedOrders,
    );
  }

  static List<TripModel> toModelList(List<Trip> trips) {
    return trips.map((trip) => toModel(trip)).toList();
  }

  static List<Trip> toEntityList(
    List<TripModel> models, {
    Map<String, Vehicle>? vehicles,
    Map<String, Order>? orders,
  }) {
    return models.map((model) {
      final vehicle = model.assignedVehicleId != null && vehicles != null
          ? vehicles[model.assignedVehicleId]
          : null;
      
      final tripOrders = model.assignedOrderIds
          .map((orderId) => orders?[orderId])
          .where((order) => order != null)
          .cast<Order>()
          .toList();

      return toEntity(
        model,
        assignedVehicle: vehicle,
        assignedOrders: tripOrders,
      );
    }).toList();
  }
}
