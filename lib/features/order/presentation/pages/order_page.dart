import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/filter_chip_button.dart';
import '../../domain/model/order_with_customer.dart';
import '../bloc/order_cubit.dart';
import '../bloc/order_state.dart';
import '../widgets/order_card.dart';
import 'order_detail_page.dart';

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
    // Load orders when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderCubit>().loadOrdersWithCustomers();
    });
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

  List<OrderWithCustomer> _filterOrdersBySearch(List<OrderWithCustomer> orders) {
    if (_searchQuery.isEmpty) return orders;
    
    return orders.where((orderWithCustomer) {
      final order = orderWithCustomer.order;
      final customer = orderWithCustomer.customer;
      
      return order.id.toLowerCase().contains(_searchQuery) ||
             customer?.name.toLowerCase().contains(_searchQuery) == true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWithCurrentFilter,
          ),
        ],
      ),
      body: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading orders...'),
                ],
              ),
            );
          }

          if (state is OrderLoaded) {
            final filteredOrders = _filterOrdersBySearch(state.ordersWithCustomer);
            
            return Column(
              children: [
                // Search and filter section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search bar
                      CustomTextField(
                        controller: _searchController,
                        hintText: 'Search orders...',
                        prefixIcon: Icons.search,
                        onChanged: _onSearchChanged,
                        isObscure: false,
                        headerText: 'Search orders...',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Filter chips
                      BlocBuilder<OrderCubit, OrderState>(
                        builder: (context, state) {
                          final currentFilter = state is OrderLoaded ? state.currentFilter : OrderFilter.all;
                          
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                OrderFilterChip(
                                  label: 'All Orders',
                                  isSelected: currentFilter.type == OrderFilterType.all,
                                  onTap: () => _onFilterChanged(OrderFilter.all),
                                  type: OrderFilterType.all,
                                ),
                                const SizedBox(width: 12),
                                OrderFilterChip(
                                  label: 'Discounted',
                                  isSelected: currentFilter.type == OrderFilterType.discounted,
                                  onTap: () => _onFilterChanged(OrderFilter.discounted),
                                  type: OrderFilterType.discounted,
                                ),
                                const SizedBox(width: 12),
                                OrderFilterChip(
                                  label: 'Regular',
                                  isSelected: currentFilter.type == OrderFilterType.notDiscounted,
                                  onTap: () => _onFilterChanged(OrderFilter.notDiscounted),
                                  type: OrderFilterType.notDiscounted,
                                  
                                ),
                                const SizedBox(width: 16),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Orders list
                Expanded(
                  child: filteredOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No orders found',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Try adjusting your search'
                                    : 'No orders available',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final orderWithCustomer = filteredOrders[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: OrderCard(
                                orderWithCustomer: orderWithCustomer,
                                onTap: () {
                                  // Navigate to order details
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailPage(
                                        orderWithCustomer: orderWithCustomer,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('No order data available'),
          );
        },
      ),
    );
  }
}