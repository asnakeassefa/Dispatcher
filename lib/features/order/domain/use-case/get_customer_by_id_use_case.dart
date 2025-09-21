import 'package:injectable/injectable.dart' as injectable;

import '../entity/customer.dart';
import '../repository/customer_repository.dart';

@injectable.injectable
class GetCustomerByIdUseCase {
  final CustomerRepository _repository;
  
  GetCustomerByIdUseCase(this._repository);
  
  Future<Customer?> call(String id) async {
    return await _repository.getCustomerById(id);
  }
}
