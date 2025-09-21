import 'package:injectable/injectable.dart' as injectable;

import '../entity/customer.dart';
import '../repository/customer_repository.dart';

@injectable.injectable
class GetAllCustomersUseCase {
  final CustomerRepository _repository;
  
  GetAllCustomersUseCase(this._repository);
  
  Future<List<Customer>> call() async {
    return await _repository.getAllCustomers();
  }
}
