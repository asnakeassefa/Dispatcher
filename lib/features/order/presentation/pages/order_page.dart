
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/order_cubit.dart';
import '../bloc/order_state.dart';
import '../widgets/filter_button.dart';
import '../widgets/order_card.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Don't call loadOrdersWithCustomers here - let the cubit handle it
    // The cubit will automatically load the saved filter state
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged(OrderFilter filter) {
    // Apply filter based on selection
    switch (filter.type) {
      case OrderFilterType.all:
        context.read<OrderCubit>().loadOrdersWithCustomers(filter: filter);
        break;
      case OrderFilterType.discounted:
        context.read<OrderCubit>().loadFilteredOrdersWithCustomers(isDiscounted: true);
        break;
      case OrderFilterType.notDiscounted:
        context.read<OrderCubit>().loadFilteredOrdersWithCustomers(isDiscounted: false);
        break;
    }
  }

  Future<void> _refreshWithCurrentFilter() async {
    // Refresh while maintaining the current filter
    await context.read<OrderCubit>().refreshOrders();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<dynamic> _filterOrdersBySearch(List<dynamic> orders) {
    if (_searchQuery.isEmpty) return orders;
    
    return orders.where((orderWithCustomer) {
      final order = orderWithCustomer.order;
      final customer = orderWithCustomer.customer;
      
      return order.id.toLowerCase().contains(_searchQuery) ||
             order.customerId.toLowerCase().contains(_searchQuery) ||
             (customer?.name.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWithCurrentFilter,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomTextField(
                controller: _searchController,
                isObscure: false,
                headerText: '',
                hintText: 'Search by order ID, customer name, etc.',
                prefixIcon: Ionicons.search,
                keyboardType: TextInputType.text,
                maxLines: 1,
                onChanged: _onSearchChanged,
                validator: (value) {
                  return null; // Remove validation for search
                },
              ),
            ),
            // Line break
            const Divider(height: 1, color: Colors.grey),
        
            // Filter by discount status
            const SizedBox(height: 8),
            // Create horizontal list of filter chips
            BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                final currentFilter = state is OrderLoaded ? state.currentFilter : OrderFilter.all;
                
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      FillterButton(
                        isSelected: currentFilter.type == OrderFilterType.all,
                        onTap: () => _onFilterChanged(OrderFilter.all),
                        text: OrderFilter.all.displayName,
                      ),
                      const SizedBox(width: 8),
                      FillterButton(
                        isSelected: currentFilter.type == OrderFilterType.discounted,
                        onTap: () => _onFilterChanged(OrderFilter.discounted),
                        text: OrderFilter.discounted.displayName,
                      ),
                      const SizedBox(width: 8),
                      FillterButton(
                        isSelected: currentFilter.type == OrderFilterType.notDiscounted,
                        onTap: () => _onFilterChanged(OrderFilter.notDiscounted),
                        text: OrderFilter.notDiscounted.displayName,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            // Orders list
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 16),
            
            // BlocBuilder for orders
            Expanded(
              child: BlocBuilder<OrderCubit, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  if (state is OrderError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading orders',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshWithCurrentFilter,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (state is OrderLoaded) {
                    final filteredOrders = _filterOrdersBySearch(state.ordersWithCustomer);
                    
                    if (filteredOrders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty 
                                ? 'No orders found for "$_searchQuery"'
                                : 'No orders available',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty
                                ? 'Try adjusting your search terms'
                                : 'Pull to refresh to load orders',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return RefreshIndicator(
                      onRefresh: _refreshWithCurrentFilter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 10);
                          },
                          itemBuilder: (context, index) {
                            final orderWithCustomer = filteredOrders[index];
                            return OrderCard(
                              orderWithCustomer: orderWithCustomer,
                            );
                          },
                          itemCount: filteredOrders.length,
                        ),
                      ),
                    );
                  }
                  
                  return const Center(
                    child: Text('No data available'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
