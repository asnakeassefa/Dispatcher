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
import '../../features/order/data/data-source/order_local_data_source.dart'
    as _i485;
import '../../features/order/data/repository/customer_repository_impl.dart'
    as _i385;
import '../../features/order/data/repository/order_repository_impl.dart'
    as _i292;
import '../../features/order/domain/repository/customer_repository.dart'
    as _i849;
import '../../features/order/domain/repository/order_repository.dart' as _i18;
import '../../features/order/domain/service/order_customer_merger.dart'
    as _i373;
import '../../features/order/domain/usecase/get_all_customers_use_case.dart'
    as _i1038;
import '../../features/order/domain/usecase/get_customer_by_id_use_case.dart'
    as _i1070;
import '../../features/order/domain/usecase/get_order_by_id_use_case.dart'
    as _i91;
import '../../features/order/domain/usecase/get_orders_by_customer_use_case.dart'
    as _i559;
import '../../features/order/domain/usecase/get_orders_use_case.dart' as _i62;
import '../../features/order/presentation/bloc/order_cubit.dart' as _i900;
import '../../features/trip_planner/data/data-source/trip_local_data_source.dart'
    as _i263;
import '../../features/trip_planner/data/repository/trip_plan_repository_impl.dart'
    as _i793;
import '../../features/trip_planner/domain/repository/trip_planner_repository.dart'
    as _i721;
import '../../features/trip_planner/domain/usecase/assign_orders_to_trip_usecase.dart'
    as _i10;
import '../../features/trip_planner/domain/usecase/assign_vehicle_to_trip_usecase.dart'
    as _i340;
import '../../features/trip_planner/domain/usecase/create_trip_usecase.dart'
    as _i143;
import '../../features/trip_planner/domain/usecase/get_available_vehicles_usecase.dart'
    as _i659;
import '../../features/trip_planner/domain/usecase/get_trip_by_id_usecase.dart'
    as _i1071;
import '../../features/trip_planner/domain/usecase/get_trips_usecase.dart'
    as _i81;
import '../../features/trip_planner/domain/usecase/get_unassigned_orders_usecase.dart'
    as _i614;
import '../../features/trip_planner/domain/usecase/get_vehicle_by_id_usecase.dart'
    as _i764;
import '../../features/trip_planner/domain/usecase/update_trip_status_usecase.dart'
    as _i734;
import '../../features/trip_planner/presentation/bloc/trip_planner_cubit.dart'
    as _i398;
import '../database/app_database.dart' as _i982;
import 'database_module.dart' as _i384;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final databaseModule = _$DatabaseModule();
  gh.factory<_i88.OrderDataSource>(() => _i88.OrderDataSource());
  gh.factory<_i955.CustomerDataSource>(() => _i955.CustomerDataSource());
  gh.factory<_i373.OrderCustomerMerger>(() => _i373.OrderCustomerMerger());
  gh.factory<_i263.TripLocalDataSource>(() => _i263.TripLocalDataSource());
  gh.factory<_i485.OrderLocalDataSource>(() => _i485.OrderLocalDataSource());
  gh.singleton<_i982.AppDatabase>(() => databaseModule.appDatabase);
  gh.factory<_i18.OrderRepository>(
    () => _i292.OrderRepositoryImpl(gh<_i88.OrderDataSource>()),
  );
  gh.factory<_i62.GetOrdersUseCase>(
    () => _i62.GetOrdersUseCase(gh<_i18.OrderRepository>()),
  );
  gh.factory<_i559.GetOrdersByCustomerUseCase>(
    () => _i559.GetOrdersByCustomerUseCase(gh<_i18.OrderRepository>()),
  );
  gh.factory<_i91.GetOrderByIdUseCase>(
    () => _i91.GetOrderByIdUseCase(gh<_i18.OrderRepository>()),
  );
  gh.factory<_i849.CustomerRepository>(
    () => _i385.CustomerRepositoryImpl(gh<_i955.CustomerDataSource>()),
  );
  gh.lazySingleton<_i721.TripPlannerRepository>(
    () => _i793.TripPlanRepositoryImpl(
      gh<_i263.TripLocalDataSource>(),
      gh<_i485.OrderLocalDataSource>(),
    ),
  );
  gh.factory<_i10.AssignOrdersToTripUseCase>(
    () => _i10.AssignOrdersToTripUseCase(gh<_i721.TripPlannerRepository>()),
  );
  gh.factory<_i143.CreateTripUseCase>(
    () => _i143.CreateTripUseCase(gh<_i721.TripPlannerRepository>()),
  );
  gh.factory<_i81.GetTripsUseCase>(
    () => _i81.GetTripsUseCase(gh<_i721.TripPlannerRepository>()),
  );
  gh.factory<_i340.AssignVehicleToTripUseCase>(
    () => _i340.AssignVehicleToTripUseCase(gh<_i721.TripPlannerRepository>()),
  );
  gh.factory<_i1071.GetTripByIdUseCase>(
    () => _i1071.GetTripByIdUseCase(gh<_i721.TripPlannerRepository>()),
  );
  gh.factory<_i764.GetVehicleByIdUseCase>(
    () => _i764.GetVehicleByIdUseCase(gh<_i721.TripPlannerRepository>()),
  );
  gh.factory<_i659.GetAvailableVehiclesUseCase>(
    () => _i659.GetAvailableVehiclesUseCase(gh<_i721.TripPlannerRepository>()),
  );
  gh.factory<_i734.UpdateTripStatusUseCase>(
    () => _i734.UpdateTripStatusUseCase(gh<_i721.TripPlannerRepository>()),
  );
  gh.factory<_i614.GetUnassignedOrdersUseCase>(
    () => _i614.GetUnassignedOrdersUseCase(gh<_i721.TripPlannerRepository>()),
  );
  gh.factory<_i900.OrderCubit>(
    () => _i900.OrderCubit(
      gh<_i18.OrderRepository>(),
      gh<_i849.CustomerRepository>(),
      gh<_i373.OrderCustomerMerger>(),
    ),
  );
  gh.factory<_i1038.GetAllCustomersUseCase>(
    () => _i1038.GetAllCustomersUseCase(gh<_i849.CustomerRepository>()),
  );
  gh.factory<_i1070.GetCustomerByIdUseCase>(
    () => _i1070.GetCustomerByIdUseCase(gh<_i849.CustomerRepository>()),
  );
  gh.factory<_i398.TripPlannerCubit>(
    () => _i398.TripPlannerCubit(
      gh<_i81.GetTripsUseCase>(),
      gh<_i143.CreateTripUseCase>(),
      gh<_i659.GetAvailableVehiclesUseCase>(),
      gh<_i764.GetVehicleByIdUseCase>(),
      gh<_i614.GetUnassignedOrdersUseCase>(),
      gh<_i10.AssignOrdersToTripUseCase>(),
      gh<_i340.AssignVehicleToTripUseCase>(),
      gh<_i734.UpdateTripStatusUseCase>(),
    ),
  );
  return getIt;
}

class _$DatabaseModule extends _i384.DatabaseModule {}
