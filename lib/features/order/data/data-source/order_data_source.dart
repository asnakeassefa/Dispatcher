import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart' as injectable;

import '../../../../core/exceptions/data_source_exceptions.dart';
import '../../domain/entity/order.dart';
import '../model/order_data_model.dart';

@injectable.injectable
class OrderDataSource {
  static const String _dataPath = 'assets/data/dispatcher_data.json';
  
  Future<List<OrderDataModel>> _loadOrderData() async {
    try {
      final String jsonString = await rootBundle.loadString(_dataPath);
      
      if (jsonString.isEmpty) {
        throw const DataLoadException('Data file is empty');
      }
      
      final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
      
      if (jsonData.isEmpty) {
        throw const DataLoadException('JSON data is empty');
      }
      
      // Extract only orders from the JSON
      final List<dynamic> ordersJson = jsonData['orders'] as List<dynamic>? ?? [];
      
      return ordersJson
          .map((orderJson) => OrderDataModel.fromJson(orderJson as Map<String, dynamic>))
          .toList();
    } on PlatformException catch (e) {
      throw DataLoadException(
        'Failed to load data file: ${e.message ?? 'Unknown platform error'}',
        originalError: e,
      );
    } on FormatException catch (e) {
      throw DataParseException(
        'Invalid JSON format: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      if (e is DataSourceException) {
        rethrow;
      }
      throw DataLoadException(
        'Unexpected error loading data: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  // Order methods
  Future<List<Order>> getAllOrders() async {
    try {
      final orderDataModels = await _loadOrderData();
      return orderDataModels.map((orderModel) => orderModel.toEntity()).toList();
    } catch (e) {
      if (e is DataSourceException) {
        rethrow;
      }
      throw DataSourceException('Failed to get all orders: ${e.toString()}');
    }
  }
  
  Future<Order?> getOrderById(String id) async {
    if (id.isEmpty) {
      throw const DataSourceException('Order ID cannot be empty');
    }
    
    try {
      final orders = await getAllOrders();
      try {
        return orders.firstWhere((order) => order.id == id);
      } catch (e) {
        return null; // Order not found
      }
    } catch (e) {
      if (e is DataSourceException) {
        rethrow;
      }
      throw DataSourceException('Failed to get order by ID "$id": ${e.toString()}');
    }
  }
  
  Future<List<Order>> getOrdersByCustomerId(String customerId) async {
    if (customerId.isEmpty) {
      throw const DataSourceException('Customer ID cannot be empty');
    }
    
    try {
      final orders = await getAllOrders();
      return orders.where((order) => order.customerId == customerId).toList();
    } catch (e) {
      if (e is DataSourceException) {
        rethrow;
      }
      throw DataSourceException('Failed to get orders by customer ID "$customerId": ${e.toString()}');
    }
  }
  
  Future<List<Order>> getFilteredOrders({bool? isDiscounted}) async {
    try {
      final orders = await getAllOrders();
      
      if (isDiscounted == null) {
        return orders;
      }
      
      return orders.where((order) => order.isDiscounted == isDiscounted).toList();
    } catch (e) {
      if (e is DataSourceException) {
        rethrow;
      }
      throw DataSourceException('Failed to get filtered orders: ${e.toString()}');
    }
  }
}
