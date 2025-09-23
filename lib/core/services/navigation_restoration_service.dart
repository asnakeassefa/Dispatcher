import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/order/presentation/bloc/order_state.dart';
import '../state/app_state_manager.dart';
import '../../features/trip_planner/presentation/pages/trip_detail_page.dart';
import '../../features/order/presentation/pages/order_detail_page.dart';
import '../../features/trip_execution/presentation/pages/trip_execution_page.dart';
import '../../features/trip_planner/presentation/pages/create_trip_page.dart';
import '../../features/trip_planner/presentation/pages/assign_orders_page.dart';
import '../../features/order/presentation/bloc/order_cubit.dart';
import '../../features/order/domain/model/order_with_customer.dart';
import '../../features/trip_planner/presentation/bloc/trip_planner_cubit.dart';
import '../../features/trip_planner/presentation/bloc/trip_planner_state.dart';

@injectable
class NavigationRestorationService {
  Future<void> restoreNavigationState(BuildContext context, AppStateManager appStateManager) async {
    final state = appStateManager.state;
    
    if (state.currentDetailPage == DetailPageType.none) return;
    
    try {
      switch (state.currentDetailPage) {
        case DetailPageType.tripDetail:
          if (state.currentTripId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TripDetailPage(tripId: state.currentTripId!),
              ),
            );
          }
          break;
          
        case DetailPageType.orderDetail:
          if (state.currentOrderId != null) {
            await _restoreOrderDetail(context, state.currentOrderId!);
          }
          break;
          
        case DetailPageType.tripExecution:
          if (state.currentTripExecutionId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TripExecutionPage(tripId: state.currentTripExecutionId!),
              ),
            );
          }
          break;
          
        case DetailPageType.createTrip:
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateTripPage(),
            ),
          );
          break;
          
        case DetailPageType.assignOrders:
          if (state.currentTripId != null) {
            await _restoreAssignOrdersPage(context, state.currentTripId!);
          }
          break;
          
        case DetailPageType.none:
          break;
      }
    } catch (e) {
      print('Failed to restore navigation state: $e');
      // Clear the detail page state if restoration fails
      appStateManager.updateDetailPage(DetailPageType.none);
    }
  }

  // New helper method to restore AssignOrdersPage with Trip object
  Future<void> _restoreAssignOrdersPage(BuildContext context, String tripId) async {
    try {
      // Get the trip from TripPlannerCubit
      final tripPlannerCubit = context.read<TripPlannerCubit>();
      final currentState = tripPlannerCubit.state;
      
      if (currentState is TripPlannerLoaded) {
        // Find the trip with the saved ID
        final trip = currentState.trips.firstWhere(
          (t) => t.id == tripId,
          orElse: () => throw Exception('Trip not found: $tripId'),
        );
        
        // Navigate to assign orders page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AssignOrdersPage(trip: trip),
          ),
        );
      } else {
        // If trips aren't loaded yet, load them first
        await tripPlannerCubit.loadTrips();
        
        // Wait a bit for the data to load
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (context.mounted) {
          final updatedState = tripPlannerCubit.state;
          if (updatedState is TripPlannerLoaded) {
            final trip = updatedState.trips.firstWhere(
              (t) => t.id == tripId,
              orElse: () => throw Exception('Trip not found: $tripId'),
            );
            
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AssignOrdersPage(trip: trip),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Failed to restore assign orders page: $e');
      context.read<AppStateManager>().updateDetailPage(DetailPageType.none);
    }
  }

  Future<void> _restoreOrderDetail(BuildContext context, String orderId) async {
    try {
      final appStateManager = context.read<AppStateManager>();
      
      // First try to get saved order data
      final savedOrderData = appStateManager.getSavedOrderData(orderId);
      
      if (savedOrderData != null) {
        // Use saved order data for immediate restoration
        try {
          final orderWithCustomer = OrderWithCustomer.fromJson(savedOrderData);
          
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(orderWithCustomer: orderWithCustomer),
            ),
          );
          return;
        } catch (e) {
          print('Failed to restore from saved data: $e');
          // Fall through to live data retrieval
        }
      }
      
      // Fallback: Get the order data from the cubit
      final orderCubit = context.read<OrderCubit>();
      final currentState = orderCubit.state;
      
      if (currentState is OrderLoaded) {
        final orderWithCustomer = currentState.ordersWithCustomer.firstWhere(
          (owc) => owc.order.id == orderId,
          orElse: () => throw Exception('Order not found: $orderId'),
        );
        
        // Navigate to order detail
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(orderWithCustomer: orderWithCustomer),
          ),
        );
      } else {
        // If orders aren't loaded yet, load them first
        await orderCubit.loadOrdersWithCustomers();
        
        // Wait a bit for the data to load
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (context.mounted) {
          final updatedState = orderCubit.state;
          if (updatedState is OrderLoaded) {
            final orderWithCustomer = updatedState.ordersWithCustomer.firstWhere(
              (owc) => owc.order.id == orderId,
              orElse: () => throw Exception('Order not found: $orderId'),
            );
            
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OrderDetailPage(orderWithCustomer: orderWithCustomer),
              ),
            );
          }
        }
      }
    } catch (e) {
      // If order restoration fails, just clear the state
      print('Failed to restore order detail: $e');
      context.read<AppStateManager>().updateDetailPage(DetailPageType.none);
    }
  }
}
