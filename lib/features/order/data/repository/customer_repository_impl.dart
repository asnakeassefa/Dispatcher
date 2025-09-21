import 'package:injectable/injectable.dart' as injectable;

import '../../domain/entity/customer.dart';
import '../../domain/repository/customer_repository.dart';
import '../data-source/customer_data_source.dart';

@injectable.Injectable(as: CustomerRepository)
class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerDataSource _dataSource;
  
  CustomerRepositoryImpl(this._dataSource);
  
  @override
  Future<List<Customer>> getAllCustomers() async {
    return await _dataSource.getAllCustomers();
  }
  
  @override
  Future<Customer?> getCustomerById(String id) async {
    return await _dataSource.getCustomerById(id);
  }
}