import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart' as injectable;

import '../../../../core/exceptions/data_source_exceptions.dart';
import '../../domain/entity/customer.dart';
import '../model/customer_data_model.dart';

@injectable.injectable
class CustomerDataSource {
  static const String _dataPath = 'assets/data/dispatcher_data.json';
  
  Future<List<CustomerDataModel>> _loadCustomerData() async {
    try {
      final String jsonString = await rootBundle.loadString(_dataPath);
      
      if (jsonString.isEmpty) {
        throw const DataLoadException('Data file is empty');
      }
      
      final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
      
      if (jsonData.isEmpty) {
        throw const DataLoadException('JSON data is empty');
      }
      
      // Extract only customers from the JSON
      final List<dynamic> customersJson = jsonData['customers'] as List<dynamic>? ?? [];
      
      return customersJson
          .map((customerJson) => CustomerDataModel.fromJson(customerJson as Map<String, dynamic>))
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
  
  // Customer methods
  Future<List<Customer>> getAllCustomers() async {
    try {
      final customerDataModels = await _loadCustomerData();
      return customerDataModels.map((customerModel) => customerModel.toEntity()).toList();
    } catch (e) {
      if (e is DataSourceException) {
        rethrow;
      }
      throw DataSourceException('Failed to get all customers: ${e.toString()}');
    }
  }
  
  Future<Customer?> getCustomerById(String id) async {
    if (id.isEmpty) {
      throw const DataSourceException('Customer ID cannot be empty');
    }
    
    try {
      final customers = await getAllCustomers();
      try {
        return customers.firstWhere((customer) => customer.id == id);
      } catch (e) {
        return null; // Customer not found
      }
    } catch (e) {
      if (e is DataSourceException) {
        rethrow;
      }
      throw DataSourceException('Failed to get customer by ID "$id": ${e.toString()}');
    }
  }
}
