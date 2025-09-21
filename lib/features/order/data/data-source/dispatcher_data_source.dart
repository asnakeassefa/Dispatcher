import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart' as injectable;

import '../../domain/entity/customer.dart';
import '../../domain/entity/order.dart';
import '../../domain/entity/vehicle.dart';
import '../model/dispatcher_data_model.dart';

@injectable.injectable
class DispatcherDataSource {
  static const String _dataPath = 'assets/data/dispatcher_data.json';
  
  Future<DispatcherDataModel> _loadData() async {
    final String jsonString = await rootBundle.loadString(_dataPath);
    final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
    return DispatcherDataModel.fromJson(jsonData);
  }
  
  // Order methods
  Future<List<Order>> getAllOrders() async {
    final data = await _loadData();
    return data.orders.map((orderModel) => orderModel.toEntity()).toList();
  }
  
  Future<Order?> getOrderById(String id) async {
    final orders = await getAllOrders();
    try {
      return orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<List<Order>> getOrdersByCustomerId(String customerId) async {
    final orders = await getAllOrders();
    return orders.where((order) => order.customerId == customerId).toList();
  }
  
  Future<List<Order>> getFilteredOrders({bool? isDiscounted}) async {
    final orders = await getAllOrders();
    
    if (isDiscounted == null) {
      return orders;
    }
    
    return orders.where((order) => order.isDiscounted == isDiscounted).toList();
  }
  
  // Customer methods
  Future<List<Customer>> getAllCustomers() async {
    final data = await _loadData();
    return data.customers.map((customerModel) => customerModel.toEntity()).toList();
  }
  
  Future<Customer?> getCustomerById(String id) async {
    final customers = await getAllCustomers();
    try {
      return customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Vehicle methods
  Future<List<Vehicle>> getAllVehicles() async {
    final data = await _loadData();
    return data.vehicles.map((vehicleModel) => vehicleModel.toEntity()).toList();
  }
  
  Future<Vehicle?> getVehicleById(String id) async {
    final vehicles = await getAllVehicles();
    try {
      return vehicles.firstWhere((vehicle) => vehicle.id == id);
    } catch (e) {
      return null;
    }
  }
}