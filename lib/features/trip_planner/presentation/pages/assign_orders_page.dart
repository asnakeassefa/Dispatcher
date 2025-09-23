import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/trip.dart';
import '../../../order/domain/entity/order.dart';
import '../bloc/trip_planner_cubit.dart';
import '../bloc/trip_planner_state.dart';

class AssignOrdersPage extends StatefulWidget {
  final Trip trip;

  const AssignOrdersPage({
    super.key,
    required this.trip,
  });

  @override
  State<AssignOrdersPage> createState() => _AssignOrdersPageState();
}

class _AssignOrdersPageState extends State<AssignOrdersPage> {
  final Set<String> _selectedOrderIds = {};
  bool _isLoading = false;
  List<Order> _availableOrders = [];

  @override
  void initState() {
    super.initState();
    // Initialize with already assigned orders
    _selectedOrderIds.addAll(widget.trip.assignedOrders.map((order) => order.id));
    _loadAvailableOrders();
  }

  void _loadAvailableOrders() {
    // Mock orders - in real implementation, this would come from the cubit
    _availableOrders = [
      Order(
        id: 'ORD-001',
        customerId: 'CUST-A',
        codAmount: 150.75,
        isDiscounted: true,
        items: [
          OrderItem(
            sku: 'SKU-TV',
            name: '65-inch 4K TV',
            quantity: 1,
            weight: 25,
            volume: 0.4,
            serialTracked: false,
          ),
        ],
        // New optional parameters
        collectedAmount: null,
        collectionDate: null,
        collectionNotes: null,
      ),
      Order(
        id: 'ORD-002',
        customerId: 'CUST-B',
        codAmount: 0.00,
        isDiscounted: false,
        items: [
          OrderItem(
            sku: 'SKU-LAPTOP',
            name: 'Laptop Pro',
            quantity: 2,
            weight: 2.5,
            volume: 0.01,
            serialTracked: true,
          ),
        ],
        // New optional parameters
        collectedAmount: null,
        collectionDate: null,
        collectionNotes: null,
      ),
      Order(
        id: 'ORD-003',
        customerId: 'CUST-C',
        codAmount: 75.50,
        isDiscounted: false,
        items: [
          OrderItem(
            sku: 'SKU-PHONE',
            name: 'Smartphone',
            quantity: 1,
            weight: 0.2,
            volume: 0.001,
            serialTracked: true,
          ),
          OrderItem(
            sku: 'SKU-CASE',
            name: 'Phone Case',
            quantity: 3,
            weight: 0.05,
            volume: 0.0001,
            serialTracked: false,
          ),
        ],
      ),
      Order(
        id: 'ORD-004',
        customerId: 'CUST-D',
        codAmount: 200.00,
        isDiscounted: true,
        items: [
          OrderItem(
            sku: 'SKU-FURNITURE',
            name: 'Office Chair',
            quantity: 1,
            weight: 15,
            volume: 0.8,
            serialTracked: false,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Orders to Trip ${widget.trip.id}'),
        actions: [
          if (_selectedOrderIds.isNotEmpty)
            TextButton(
              onPressed: _isLoading ? null : _assignOrders,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Assign'),
            ),
        ],
      ),
      body: BlocConsumer<TripPlannerCubit, TripPlannerState>(
        listener: (context, state) {
          if (state is TripPlannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
            setState(() {
              _isLoading = false;
            });
          } else if (state is TripPlannerLoaded && _isLoading) {
            // Orders assigned successfully
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Orders assigned successfully!'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TripPlannerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildOrdersList(context);
        },
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    return Column(
      children: [
        // Trip capacity info
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Trip Capacity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.trip.assignedVehicle != null) ...[
                Text('Vehicle: ${widget.trip.assignedVehicle!.plateNumber}'),
                Text('Capacity: ${widget.trip.assignedVehicle!.capacity}kg'),
                Text('Volume: ${widget.trip.assignedVehicle!.volumeCapacity}m³'),
              ] else
                Text('No vehicle assigned - cannot add orders'),
            ],
          ),
        ),

        // Selected orders summary
        if (_selectedOrderIds.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  '${_selectedOrderIds.length} orders selected',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Orders list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _availableOrders.length,
            itemBuilder: (context, index) {
              final order = _availableOrders[index];
              final isSelected = _selectedOrderIds.contains(order.id);
              final canSelect = _canSelectOrder(order);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: canSelect
                      ? (value) {
                          setState(() {
                            if (value == true) {
                              _selectedOrderIds.add(order.id);
                            } else {
                              _selectedOrderIds.remove(order.id);
                            }
                          });
                        }
                      : null,
                  title: Text(
                    order.id,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: canSelect ? null : Colors.grey,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${order.customerId}'),
                      Text('Items: ${order.items.length}'),
                      Text('Weight: ${order.totalWeight.toStringAsFixed(2)}kg'),
                      Text('Volume: ${order.totalVolume.toStringAsFixed(3)}m³'),
                      if (order.codAmount > 0)
                        Text('COD: \$${order.codAmount.toStringAsFixed(2)}'),
                      if (order.isDiscounted)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Discounted',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  secondary: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        order.codAmount > 0 ? Icons.attach_money : Icons.payment,
                        color: order.codAmount > 0 ? Colors.orange : Colors.green,
                      ),
                      if (!canSelect)
                        Icon(
                          Icons.warning,
                          color: Colors.red,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _canSelectOrder(Order order) {
    if (widget.trip.assignedVehicle == null) return false;
    
    // Check if adding this order would exceed vehicle capacity
    final currentWeight = widget.trip.totalWeight;
    final currentVolume = widget.trip.totalVolume;
    
    final newWeight = currentWeight + order.totalWeight;
    final newVolume = currentVolume + order.totalVolume;
    
    return newWeight <= widget.trip.assignedVehicle!.capacity &&
           newVolume <= widget.trip.assignedVehicle!.volumeCapacity;
  }

  Future<void> _assignOrders() async {
    if (_selectedOrderIds.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Get the selected orders from the available orders list
    final selectedOrders = _availableOrders
        .where((order) => _selectedOrderIds.contains(order.id))
        .toList();

    if (selectedOrders.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No orders selected'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Call the cubit to assign orders
    context.read<TripPlannerCubit>().assignOrdersToTrip(
      tripId: widget.trip.id,
      orders: selectedOrders,
    );
  }
}
