// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dispatcher/core/database/app_database.dart' as _i346;
import 'package:dispatcher/core/di/database_module.dart' as _i708;
import 'package:dispatcher/features/order/data/data-source/customer_data_source.dart'
    as _i180;
import 'package:dispatcher/features/order/data/data-source/order_data_source.dart'
    as _i389;
import 'package:dispatcher/features/order/data/repository/customer_repository_impl.dart'
    as _i470;
import 'package:dispatcher/features/order/data/repository/order_repository_impl.dart'
    as _i239;
import 'package:dispatcher/features/order/domain/repository/customer_repository.dart'
    as _i609;
import 'package:dispatcher/features/order/domain/repository/order_repository.dart'
    as _i297;
import 'package:dispatcher/features/order/domain/service/order_customer_merger.dart'
    as _i752;
import 'package:dispatcher/features/order/domain/usecase/get_all_customers_use_case.dart'
    as _i711;
import 'package:dispatcher/features/order/domain/usecase/get_customer_by_id_use_case.dart'
    as _i914;
import 'package:dispatcher/features/order/domain/usecase/get_order_by_id_use_case.dart'
    as _i807;
import 'package:dispatcher/features/order/domain/usecase/get_orders_by_customer_use_case.dart'
    as _i677;
import 'package:dispatcher/features/order/domain/usecase/get_orders_use_case.dart'
    as _i761;
import 'package:dispatcher/features/order/presentation/bloc/order_cubit.dart'
    as _i1055;
import 'package:dispatcher/features/trip_execution/data/data-source/trip_execution_local_data_source.dart'
    as _i1015;
import 'package:dispatcher/features/trip_execution/data/repository/trip_execution_repository_impl.dart'
    as _i102;
import 'package:dispatcher/features/trip_execution/domain/repository/trip_execution_repository.dart'
    as _i22;
import 'package:dispatcher/features/trip_execution/domain/usecase/complete_stop_usecase.dart'
    as _i263;
import 'package:dispatcher/features/trip_execution/domain/usecase/create_trip_execution_from_trip_usecase.dart'
    as _i581;
import 'package:dispatcher/features/trip_execution/domain/usecase/create_trip_execution_usecase.dart'
    as _i894;
import 'package:dispatcher/features/trip_execution/domain/usecase/fail_stop_usecase.dart'
    as _i923;
import 'package:dispatcher/features/trip_execution/domain/usecase/start_stop_usecase.dart'
    as _i518;
import 'package:dispatcher/features/trip_execution/presentation/bloc/trip_execution_cubit.dart'
    as _i339;
import 'package:dispatcher/features/trip_planner/data/data-source/trip_local_data_source.dart'
    as _i551;
import 'package:dispatcher/features/trip_planner/data/repository/trip_plan_repository_impl.dart'
    as _i760;
import 'package:dispatcher/features/trip_planner/domain/repository/trip_planner_repository.dart'
    as _i1026;
import 'package:dispatcher/features/trip_planner/domain/usecase/assign_orders_to_trip_usecase.dart'
    as _i402;
import 'package:dispatcher/features/trip_planner/domain/usecase/assign_vehicle_to_trip_usecase.dart'
    as _i227;
import 'package:dispatcher/features/trip_planner/domain/usecase/create_trip_usecase.dart'
    as _i989;
import 'package:dispatcher/features/trip_planner/domain/usecase/get_available_vehicles_usecase.dart'
    as _i245;
import 'package:dispatcher/features/trip_planner/domain/usecase/get_trip_by_id_usecase.dart'
    as _i553;
import 'package:dispatcher/features/trip_planner/domain/usecase/get_trips_usecase.dart'
    as _i766;
import 'package:dispatcher/features/trip_planner/domain/usecase/get_unassigned_orders_usecase.dart'
    as _i137;
import 'package:dispatcher/features/trip_planner/domain/usecase/get_vehicle_by_id_usecase.dart'
    as _i986;
import 'package:dispatcher/features/trip_planner/domain/usecase/update_trip_status_usecase.dart'
    as _i15;
import 'package:dispatcher/features/trip_planner/presentation/bloc/trip_planner_cubit.dart'
    as _i693;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final databaseModule = _$DatabaseModule();
    gh.factory<_i389.OrderDataSource>(() => _i389.OrderDataSource());
    gh.factory<_i180.CustomerDataSource>(() => _i180.CustomerDataSource());
    gh.factory<_i752.OrderCustomerMerger>(() => _i752.OrderCustomerMerger());
    gh.factory<_i1015.TripExecutionLocalDataSource>(
      () => _i1015.TripExecutionLocalDataSource(),
    );
    gh.singleton<_i346.AppDatabase>(() => databaseModule.appDatabase);
    gh.factory<_i297.OrderRepository>(
      () => _i239.OrderRepositoryImpl(gh<_i389.OrderDataSource>()),
    );
    gh.lazySingleton<_i22.TripExecutionRepository>(
      () => _i102.TripExecutionRepositoryImpl(
        gh<_i1015.TripExecutionLocalDataSource>(),
      ),
    );
    gh.factory<_i761.GetOrdersUseCase>(
      () => _i761.GetOrdersUseCase(gh<_i297.OrderRepository>()),
    );
    gh.factory<_i677.GetOrdersByCustomerUseCase>(
      () => _i677.GetOrdersByCustomerUseCase(gh<_i297.OrderRepository>()),
    );
    gh.factory<_i807.GetOrderByIdUseCase>(
      () => _i807.GetOrderByIdUseCase(gh<_i297.OrderRepository>()),
    );
    gh.factory<_i609.CustomerRepository>(
      () => _i470.CustomerRepositoryImpl(gh<_i180.CustomerDataSource>()),
    );
    gh.factory<_i551.TripLocalDataSource>(
      () => _i551.TripLocalDataSource(gh<_i346.AppDatabase>()),
    );
    gh.factory<_i1055.OrderCubit>(
      () => _i1055.OrderCubit(
        gh<_i297.OrderRepository>(),
        gh<_i609.CustomerRepository>(),
        gh<_i752.OrderCustomerMerger>(),
      ),
    );
    gh.factory<_i711.GetAllCustomersUseCase>(
      () => _i711.GetAllCustomersUseCase(gh<_i609.CustomerRepository>()),
    );
    gh.factory<_i914.GetCustomerByIdUseCase>(
      () => _i914.GetCustomerByIdUseCase(gh<_i609.CustomerRepository>()),
    );
    gh.factory<_i518.StartStopUseCase>(
      () => _i518.StartStopUseCase(gh<_i22.TripExecutionRepository>()),
    );
    gh.factory<_i923.FailStopUseCase>(
      () => _i923.FailStopUseCase(gh<_i22.TripExecutionRepository>()),
    );
    gh.factory<_i894.CreateTripExecutionUseCase>(
      () =>
          _i894.CreateTripExecutionUseCase(gh<_i22.TripExecutionRepository>()),
    );
    gh.factory<_i581.CreateTripExecutionFromTripUseCase>(
      () => _i581.CreateTripExecutionFromTripUseCase(
        gh<_i22.TripExecutionRepository>(),
      ),
    );
    gh.factory<_i263.CompleteStopUseCase>(
      () => _i263.CompleteStopUseCase(gh<_i22.TripExecutionRepository>()),
    );
    gh.lazySingleton<_i1026.TripPlannerRepository>(
      () => _i760.TripPlanRepositoryImpl(
        gh<_i551.TripLocalDataSource>(),
        gh<_i389.OrderDataSource>(),
      ),
    );
    gh.factory<_i402.AssignOrdersToTripUseCase>(
      () => _i402.AssignOrdersToTripUseCase(gh<_i1026.TripPlannerRepository>()),
    );
    gh.factory<_i989.CreateTripUseCase>(
      () => _i989.CreateTripUseCase(gh<_i1026.TripPlannerRepository>()),
    );
    gh.factory<_i766.GetTripsUseCase>(
      () => _i766.GetTripsUseCase(gh<_i1026.TripPlannerRepository>()),
    );
    gh.factory<_i227.AssignVehicleToTripUseCase>(
      () =>
          _i227.AssignVehicleToTripUseCase(gh<_i1026.TripPlannerRepository>()),
    );
    gh.factory<_i553.GetTripByIdUseCase>(
      () => _i553.GetTripByIdUseCase(gh<_i1026.TripPlannerRepository>()),
    );
    gh.factory<_i986.GetVehicleByIdUseCase>(
      () => _i986.GetVehicleByIdUseCase(gh<_i1026.TripPlannerRepository>()),
    );
    gh.factory<_i245.GetAvailableVehiclesUseCase>(
      () =>
          _i245.GetAvailableVehiclesUseCase(gh<_i1026.TripPlannerRepository>()),
    );
    gh.factory<_i15.UpdateTripStatusUseCase>(
      () => _i15.UpdateTripStatusUseCase(gh<_i1026.TripPlannerRepository>()),
    );
    gh.factory<_i137.GetUnassignedOrdersUseCase>(
      () =>
          _i137.GetUnassignedOrdersUseCase(gh<_i1026.TripPlannerRepository>()),
    );
    gh.factory<_i339.TripExecutionCubit>(
      () => _i339.TripExecutionCubit(
        gh<_i22.TripExecutionRepository>(),
        gh<_i581.CreateTripExecutionFromTripUseCase>(),
        gh<_i553.GetTripByIdUseCase>(),
        gh<_i15.UpdateTripStatusUseCase>(),
      ),
    );
    gh.factory<_i693.TripPlannerCubit>(
      () => _i693.TripPlannerCubit(
        gh<_i766.GetTripsUseCase>(),
        gh<_i989.CreateTripUseCase>(),
        gh<_i245.GetAvailableVehiclesUseCase>(),
        gh<_i986.GetVehicleByIdUseCase>(),
        gh<_i137.GetUnassignedOrdersUseCase>(),
        gh<_i402.AssignOrdersToTripUseCase>(),
        gh<_i227.AssignVehicleToTripUseCase>(),
        gh<_i15.UpdateTripStatusUseCase>(),
      ),
    );
    return this;
  }
}

class _$DatabaseModule extends _i708.DatabaseModule {}
