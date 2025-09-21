// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/order/data/data-source/customer_data_source.dart'
    as _i955;
import '../../features/order/data/data-source/order_data_source.dart' as _i88;
import '../../features/order/data/repository/customer_repository_impl.dart'
    as _i385;
import '../../features/order/data/repository/order_repository_impl.dart'
    as _i292;
import '../../features/order/domain/repository/customer_repository.dart'
    as _i849;
import '../../features/order/domain/repository/order_repository.dart' as _i18;
import '../../features/order/domain/service/order_customer_merger.dart'
    as _i373;
import '../../features/order/domain/use-case/get_all_customers_use_case.dart'
    as _i435;
import '../../features/order/domain/use-case/get_customer_by_id_use_case.dart'
    as _i284;
import '../../features/order/domain/use-case/get_order_by_id_use_case.dart'
    as _i231;
import '../../features/order/domain/use-case/get_orders_by_customer_use_case.dart'
    as _i844;
import '../../features/order/domain/use-case/get_orders_use_case.dart' as _i490;
import '../../features/order/presentation/bloc/order_cubit.dart' as _i900;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  gh.factory<_i88.OrderDataSource>(() => _i88.OrderDataSource());
  gh.factory<_i955.CustomerDataSource>(() => _i955.CustomerDataSource());
  gh.factory<_i373.OrderCustomerMerger>(() => _i373.OrderCustomerMerger());
  gh.factory<_i18.OrderRepository>(
    () => _i292.OrderRepositoryImpl(gh<_i88.OrderDataSource>()),
  );
  gh.factory<_i490.GetOrdersUseCase>(
    () => _i490.GetOrdersUseCase(gh<_i18.OrderRepository>()),
  );
  gh.factory<_i844.GetOrdersByCustomerUseCase>(
    () => _i844.GetOrdersByCustomerUseCase(gh<_i18.OrderRepository>()),
  );
  gh.factory<_i231.GetOrderByIdUseCase>(
    () => _i231.GetOrderByIdUseCase(gh<_i18.OrderRepository>()),
  );
  gh.factory<_i849.CustomerRepository>(
    () => _i385.CustomerRepositoryImpl(gh<_i955.CustomerDataSource>()),
  );
  gh.factory<_i900.OrderCubit>(
    () => _i900.OrderCubit(
      gh<_i18.OrderRepository>(),
      gh<_i849.CustomerRepository>(),
      gh<_i373.OrderCustomerMerger>(),
    ),
  );
  gh.factory<_i435.GetAllCustomersUseCase>(
    () => _i435.GetAllCustomersUseCase(gh<_i849.CustomerRepository>()),
  );
  gh.factory<_i284.GetCustomerByIdUseCase>(
    () => _i284.GetCustomerByIdUseCase(gh<_i849.CustomerRepository>()),
  );
  return getIt;
}
