import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart' as injectable;

import '../../domain/entity/trip.dart';
import '../../domain/entity/vehicle.dart';
import '../../domain/usecase/create_trip_usecase.dart';
import '../../domain/usecase/get_trips_usecase.dart';
import '../../domain/usecase/get_available_vehicles_usecase.dart';
import '../../domain/usecase/get_vehicle_by_id_usecase.dart';
import '../../domain/usecase/assign_orders_to_trip_usecase.dart';
import '../../domain/usecase/assign_vehicle_to_trip_usecase.dart';
import '../../domain/usecase/update_trip_status_usecase.dart';
import '../../domain/usecase/get_unassigned_orders_usecase.dart';
import '../../../order/domain/entity/order.dart';
import 'trip_planner_state.dart';

@injectable.injectable
class TripPlannerCubit extends HydratedCubit<TripPlannerState> {
  final GetTripsUseCase _getTripsUseCase;
  final CreateTripUseCase _createTripUseCase;
  final GetAvailableVehiclesUseCase _getAvailableVehiclesUseCase;
  final GetVehicleByIdUseCase _getVehicleByIdUseCase;
  final GetUnassignedOrdersUseCase _getUnassignedOrdersUseCase;
  final AssignOrdersToTripUseCase _assignOrdersToTripUseCase;
  final AssignVehicleToTripUseCase _assignVehicleToTripUseCase;
  final UpdateTripStatusUseCase _updateTripStatusUseCase;

  TripPlannerCubit(
    this._getTripsUseCase,
    this._createTripUseCase,
    this._getAvailableVehiclesUseCase,
    this._getVehicleByIdUseCase,
    this._getUnassignedOrdersUseCase,
    this._assignOrdersToTripUseCase,
    this._assignVehicleToTripUseCase,
    this._updateTripStatusUseCase,
  ) : super(const TripPlannerInitial());

  Future<void> loadTrips() async {
    try {
      emit(const TripPlannerLoading());
      final trips = await _getTripsUseCase();
      emit(TripPlannerLoaded(
        trips: trips,
        availableVehicles: const [],
        unassignedOrders: const [],
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(TripPlannerError(message: 'Failed to load trips: ${e.toString()}'));
    }
  }

  Future<void> refreshTrips() async {
    try {
      final trips = await _getTripsUseCase();
      final currentState = state;
      if (currentState is TripPlannerLoaded) {
        emit(TripPlannerLoaded(
          trips: trips,
          availableVehicles: currentState.availableVehicles,
          unassignedOrders: currentState.unassignedOrders,
          lastUpdated: DateTime.now(),
        ));
      } else {
        emit(TripPlannerLoaded(
          trips: trips,
          availableVehicles: const [],
          unassignedOrders: const [],
          lastUpdated: DateTime.now(),
        ));
      }
    } catch (e) {
      emit(TripPlannerError(message: 'Failed to refresh trips: ${e.toString()}'));
    }
  }

  Future<void> createTrip({
    required DateTime date,
    Vehicle? assignedVehicle,
    List<Order> assignedOrders = const [],
  }) async {
    try {
      emit(const TripPlannerLoading());
      final newTrip = await _createTripUseCase(
        date: date,
        assignedVehicle: assignedVehicle,
        assignedOrders: assignedOrders,
      );
      
      final currentState = state;
      if (currentState is TripPlannerLoaded) {
        final updatedTrips = [newTrip, ...currentState.trips];
        emit(TripPlannerLoaded(
          trips: updatedTrips,
          availableVehicles: currentState.availableVehicles,
          unassignedOrders: currentState.unassignedOrders,
          lastUpdated: DateTime.now(),
        ));
      } else {
        await loadTrips();
      }
    } catch (e) {
      emit(TripPlannerError(message: 'Failed to create trip: ${e.toString()}'));
    }
  }

  Future<void> assignOrdersToTrip({
    required String tripId,
    required List<Order> orders,
  }) async {
    try {
      emit(const TripPlannerLoading());
      final updatedTrip = await _assignOrdersToTripUseCase(
        tripId: tripId,
        orders: orders,
      );
      
      final currentState = state;
      if (currentState is TripPlannerLoaded) {
        final updatedTrips = currentState.trips.map<Trip>((trip) {
          return trip.id == tripId ? updatedTrip : trip;
        }).toList();
        
        emit(TripPlannerLoaded(
          trips: updatedTrips,
          availableVehicles: currentState.availableVehicles,
          unassignedOrders: currentState.unassignedOrders,
          lastUpdated: DateTime.now(),
        ));
      } else {
        await loadTrips();
      }
    } catch (e) {
      emit(TripPlannerError(message: 'Failed to assign orders: ${e.toString()}'));
    }
  }

  Future<void> assignVehicleToTrip({
    required String tripId,
    required Vehicle vehicle,
  }) async {
    try {
      emit(const TripPlannerLoading());
      final updatedTrip = await _assignVehicleToTripUseCase(
        tripId: tripId,
        vehicle: vehicle,
      );
      
      final currentState = state;
      if (currentState is TripPlannerLoaded) {
        final updatedTrips = currentState.trips.map<Trip>((trip) {
          return trip.id == tripId ? updatedTrip : trip;
        }).toList();
        
        emit(TripPlannerLoaded(
          trips: updatedTrips,
          availableVehicles: currentState.availableVehicles,
          unassignedOrders: currentState.unassignedOrders,
          lastUpdated: DateTime.now(),
        ));
      }
    } catch (e) {
      emit(TripPlannerError(message: 'Failed to assign vehicle: ${e.toString()}'));
    }
  }

  Future<void> loadAvailableVehicles() async {
    try {
      final vehicles = await _getAvailableVehiclesUseCase();
      final currentState = state;
      if (currentState is TripPlannerLoaded) {
        emit(TripPlannerLoaded(
          trips: currentState.trips,
          availableVehicles: vehicles,
          unassignedOrders: currentState.unassignedOrders,
          lastUpdated: currentState.lastUpdated,
        ));
      } else {
        emit(TripPlannerLoaded(
          trips: [],
          availableVehicles: vehicles,
          unassignedOrders: const [],
          lastUpdated: DateTime.now(),
        ));
      }
    } catch (e) {
      emit(TripPlannerError(message: 'Failed to load vehicles: ${e.toString()}'));
    }
  }

  Future<void> updateTripStatus({
    required String tripId,
    required TripStatus status,
  }) async {
    try {
      emit(const TripPlannerLoading());
      final updatedTrip = await _updateTripStatusUseCase(
        tripId: tripId,
        status: status,
      );
      
      final currentState = state;
      if (currentState is TripPlannerLoaded) {
        final updatedTrips = currentState.trips.map<Trip>((trip) {
          return trip.id == tripId ? updatedTrip : trip;
        }).toList();
        
        emit(TripPlannerLoaded(
          trips: updatedTrips,
          availableVehicles: currentState.availableVehicles,
          unassignedOrders: currentState.unassignedOrders,
          lastUpdated: DateTime.now(),
        ));
      }
    } catch (e) {
      emit(TripPlannerError(message: 'Failed to update trip status: ${e.toString()}'));
    }
  }

  Future<void> loadUnassignedOrders() async {
    try {
      final orders = await _getUnassignedOrdersUseCase();
      final currentState = state;
      if (currentState is TripPlannerLoaded) {
        emit(TripPlannerLoaded(
          trips: currentState.trips,
          availableVehicles: currentState.availableVehicles,
          unassignedOrders: orders,
          lastUpdated: currentState.lastUpdated,
        ));
      } else {
        emit(TripPlannerLoaded(
          trips: [],
          availableVehicles: const [],
          unassignedOrders: orders,
          lastUpdated: DateTime.now(),
        ));
      }
    } catch (e) {
      emit(TripPlannerError(message: 'Failed to load orders: ${e.toString()}'));
    }
  }

  @override
  TripPlannerState? fromJson(Map<String, dynamic> json) {
    try {
      return TripPlannerLoaded.fromJson(json);
    } catch (e) {
      return const TripPlannerInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(TripPlannerState state) {
    if (state is TripPlannerLoaded) {
      return state.toJson();
    }
    return null;
  }
}
