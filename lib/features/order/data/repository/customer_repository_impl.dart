import 'package:injectable/injectable.dart' as injectable;

import '../data-source/dispatcher_data_source.dart';
import '../../domain/entity/customer.dart';
import '../../domain/repository/customer_repository.dart';

@injectable.Injectable(as: CustomerRepository)
class CustomerRepositoryImpl implements CustomerRepository {
  final DispatcherDataSource _dataSource;
  
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