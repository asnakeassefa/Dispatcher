import 'package:equatable/equatable.dart';

import 'customer_data_model.dart';
import 'order_data_model.dart';
import 'vehicle_data_model.dart';

class MetaDataModel extends Equatable {
  final String planDate;
  final String depotTimezone;
  final LocationDataModel depot;

  const MetaDataModel({
    required this.planDate,
    required this.depotTimezone,
    required this.depot,
  });

  factory MetaDataModel.fromJson(Map<String, dynamic> json) {
    return MetaDataModel(
      planDate: json['planDate'] as String,
      depotTimezone: json['depotTimezone'] as String,
      depot: LocationDataModel.fromJson(json['depot'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planDate': planDate,
      'depotTimezone': depotTimezone,
      'depot': depot.toJson(),
    };
  }

  @override
  List<Object?> get props => [planDate, depotTimezone, depot];
}

class DispatcherDataModel extends Equatable {
  final MetaDataModel meta;
  final List<VehicleDataModel> vehicles;
  final List<OrderDataModel> orders;
  final List<CustomerDataModel> customers;

  const DispatcherDataModel({
    required this.meta,
    required this.vehicles,
    required this.orders,
    required this.customers,
  });

  factory DispatcherDataModel.fromJson(Map<String, dynamic> json) {
    return DispatcherDataModel(
      meta: MetaDataModel.fromJson(json['meta'] as Map<String, dynamic>),
      vehicles: (json['vehicles'] as List<dynamic>)
          .map((vehicleJson) => VehicleDataModel.fromJson(vehicleJson as Map<String, dynamic>))
          .toList(),
      orders: (json['orders'] as List<dynamic>)
          .map((orderJson) => OrderDataModel.fromJson(orderJson as Map<String, dynamic>))
          .toList(),
      customers: (json['customers'] as List<dynamic>)
          .map((customerJson) => CustomerDataModel.fromJson(customerJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'vehicles': vehicles.map((vehicle) => vehicle.toJson()).toList(),
      'orders': orders.map((order) => order.toJson()).toList(),
      'customers': customers.map((customer) => customer.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [meta, vehicles, orders, customers];
}
