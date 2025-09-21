import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart' as injectable;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/exceptions/data_source_exceptions.dart';
import '../../domain/model/order_with_customer.dart';
import '../../domain/repository/customer_repository.dart';
import '../../domain/repository/order_repository.dart';
import '../../domain/service/order_customer_merger.dart';
import 'order_state.dart';

@injectable.injectable
class OrderCubit extends HydratedCubit<OrderState> {
  final OrderRepository _orderRepository;
  final CustomerRepository _customerRepository;
  final OrderCustomerMerger _merger;
  
  OrderCubit(
    this._orderRepository,
    this._customerRepository,
    this._merger,
  ) : super(const OrderInitial()) {
    _loadSavedFilter();
  }
  
  Future<void> _loadSavedFilter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFilterType = prefs.getString('order_filter_type');
      
      if (savedFilterType != null) {
        OrderFilter filter;
        switch (savedFilterType) {
          case 'discounted':
            filter = OrderFilter.discounted;
            break;
          case 'notDiscounted':
            filter = OrderFilter.notDiscounted;
            break;
          default:
            filter = OrderFilter.all;
        }
        
        // Load orders with the saved filter
        await loadOrdersWithCustomers(filter: filter);
      } else {
        // Load all orders if no saved filter
        await loadOrdersWithCustomers();
      }
    } catch (e) {
      // If loading saved filter fails, load all orders
      await loadOrdersWithCustomers();
    }
  }
  
  Future<void> _saveFilter(OrderFilter filter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('order_filter_type', filter.type.name);
    } catch (e) {
      print('Error saving filter: $e');
    }
  }
  
  @override
  OrderState? fromJson(Map<String, dynamic> json) {
    try {
      final String stateType = json['type'] as String;
      
      switch (stateType) {
        case 'OrderLoaded':
          return OrderLoaded.fromJson(json['data'] as Map<String, dynamic>);
        case 'OrderError':
          return OrderError.fromJson(json['data'] as Map<String, dynamic>);
        case 'OrderInitial':
          return const OrderInitial();
        default:
          return const OrderInitial();
      }
    } catch (e) {
      return const OrderInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(OrderState state) {
    try {
      if (state is OrderLoaded) {
        return {
          'type': 'OrderLoaded',
          'data': state.toJson(),
        };
      } else if (state is OrderError) {
        return {
          'type': 'OrderError',
          'data': state.toJson(),
        };
      } else if (state is OrderInitial) {
        return {
          'type': 'OrderInitial',
          'data': {},
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> loadOrdersWithCustomers({OrderFilter? filter}) async {
    emit(const OrderLoading());
    
    try {
      // Fetch orders and customers separately
      final orders = await _orderRepository.getAllOrders();
      final customers = await _customerRepository.getAllCustomers();
      
      // Merge them using the service
      final ordersWithCustomer = _merger.mergeOrdersWithCustomers(
        orders: orders,
        customers: customers,
      );
      
      // Apply filter if provided, otherwise use current filter or default to all
      final currentFilter = filter ?? (state is OrderLoaded ? (state as OrderLoaded).currentFilter : OrderFilter.all);
      final filteredOrders = _applyFilter(ordersWithCustomer, currentFilter);
      
      // Save the filter
      await _saveFilter(currentFilter);
      
      emit(OrderLoaded(
        ordersWithCustomer: filteredOrders,
        lastUpdated: DateTime.now(),
        currentFilter: currentFilter,
      ));
    } on DataSourceException catch (e) {
      emit(OrderError(
        message: e.message,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      emit(OrderError(
        message: 'Unexpected error: ${e.toString()}',
        timestamp: DateTime.now(),
      ));
    }
  }
  
  Future<void> loadFilteredOrdersWithCustomers({bool? isDiscounted}) async {
    emit(const OrderLoading());
    
    try {
      // Fetch filtered orders and all customers
      final orders = await _orderRepository.getFilteredOrders(isDiscounted: isDiscounted);
      final customers = await _customerRepository.getAllCustomers();
      
      // Merge them using the service
      final ordersWithCustomer = _merger.mergeOrdersWithCustomers(
        orders: orders,
        customers: customers,
      );
      
      // Determine filter type
      OrderFilter filter;
      if (isDiscounted == null) {
        filter = OrderFilter.all;
      } else if (isDiscounted) {
        filter = OrderFilter.discounted;
      } else {
        filter = OrderFilter.notDiscounted;
      }
      
      // Save the filter
      await _saveFilter(filter);
      
      emit(OrderLoaded(
        ordersWithCustomer: ordersWithCustomer,
        lastUpdated: DateTime.now(),
        currentFilter: filter,
      ));
    } on DataSourceException catch (e) {
      emit(OrderError(
        message: e.message,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      emit(OrderError(
        message: 'Unexpected error: ${e.toString()}',
        timestamp: DateTime.now(),
      ));
    }
  }
  
  Future<void> loadOrdersWithCustomersByCustomerId(String customerId) async {
    emit(const OrderLoading());
    
    try {
      // Fetch orders for specific customer and all customers
      final orders = await _orderRepository.getOrdersByCustomerId(customerId);
      final customers = await _customerRepository.getAllCustomers();
      
      // Merge them using the service
      final ordersWithCustomer = _merger.mergeOrdersWithCustomers(
        orders: orders,
        customers: customers,
      );
      
      emit(OrderLoaded(
        ordersWithCustomer: ordersWithCustomer,
        lastUpdated: DateTime.now(),
        currentFilter: OrderFilter.all, // Reset to all when filtering by customer
      ));
    } on DataSourceException catch (e) {
      emit(OrderError(
        message: e.message,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      emit(OrderError(
        message: 'Unexpected error: ${e.toString()}',
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> refreshOrders() async {
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      await loadOrdersWithCustomers(filter: currentState.currentFilter);
    } else {
      await loadOrdersWithCustomers();
    }
  }

  void clearError() {
    if (state is OrderError) {
      emit(const OrderInitial());
    }
  }

  // Helper method to apply filter to orders
  List<OrderWithCustomer> _applyFilter(List<OrderWithCustomer> orders, OrderFilter filter) {
    switch (filter.type) {
      case OrderFilterType.all:
        return orders;
      case OrderFilterType.discounted:
        return orders.where((order) => order.isDiscounted).toList();
      case OrderFilterType.notDiscounted:
        return orders.where((order) => !order.isDiscounted).toList();
    }
  }
}
