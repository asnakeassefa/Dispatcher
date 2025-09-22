import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart' as injectable;

import '../../../../core/exceptions/data_source_exceptions.dart';
import '../../domain/entity/order.dart';
import '../../domain/entity/customer.dart';

@injectable.injectable
class OrderLocalDataSource {
  OrderLocalDataSource();

  Future<List<Order>> getAllOrders() async {
    try {
      // Load order data from JSON
      final String jsonString = await rootBundle.loadString('assets/data/dispatcher_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      final List<dynamic> ordersJson = jsonData['orders'] as List<dynamic>;
      
      return ordersJson.map((orderJson) {
        final String id = orderJson['id'] as String;
        final String customerId = orderJson['customerId'] as String;
        final double codAmount = (orderJson['codAmount'] as num).toDouble();
        final bool isDiscounted = orderJson['isDiscounted'] as bool;
        final List<dynamic> itemsJson = orderJson['items'] as List<dynamic>;
        
        final List<OrderItem> items = itemsJson.map((itemJson) {
          return OrderItem(
            sku: itemJson['sku'] as String,
            name: itemJson['name'] as String,
            quantity: itemJson['quantity'] as int,
            weight: (itemJson['weight'] as num).toDouble(),
            volume: (itemJson['volume'] as num).toDouble(),
            serialTracked: itemJson['serialTracked'] as bool,
          );
        }).toList();
        
        return Order(
          id: id,
          customerId: customerId,
          codAmount: codAmount,
          isDiscounted: isDiscounted,
          items: items,
        );
      }).toList();
    } catch (e) {
      throw DataSourceException('Failed to load orders: ${e.toString()}');
    }
  }

  Future<List<Customer>> getAllCustomers() async {
    try {
      // Load customer data from JSON
      final String jsonString = await rootBundle.loadString('assets/data/dispatcher_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      final List<dynamic> customersJson = jsonData['customers'] as List<dynamic>;
      
      return customersJson.map((customerJson) {
        final String id = customerJson['id'] as String;
        final String name = customerJson['name'] as String;
        final Map<String, dynamic> locationJson = customerJson['location'] as Map<String, dynamic>;
        
        return Customer(
          id: id,
          name: name,
          location: Location(
            lat: (locationJson['lat'] as num).toDouble(),
            lon: (locationJson['lon'] as num).toDouble(),
          ),
        );
      }).toList();
    } catch (e) {
      throw DataSourceException('Failed to load customers: ${e.toString()}');
    }
  }

  Future<Order?> getOrderById(String id) async {
    try {
      final orders = await getAllOrders();
      return orders.where((order) => order.id == id).firstOrNull;
    } catch (e) {
      throw DataSourceException('Failed to get order by ID "$id": ${e.toString()}');
    }
  }

  Future<Customer?> getCustomerById(String id) async {
    try {
      final customers = await getAllCustomers();
      return customers.where((customer) => customer.id == id).firstOrNull;
    } catch (e) {
      throw DataSourceException('Failed to get customer by ID "$id": ${e.toString()}');
    }
  }
}
