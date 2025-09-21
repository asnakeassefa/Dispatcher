import 'package:dispatcher/core/theme/app_theme.dart';
import 'package:dispatcher/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

import '../../domain/model/order_with_customer.dart';

class OrderCard extends StatelessWidget {
  final OrderWithCustomer orderWithCustomer;
  
  const OrderCard({
    super.key,
    required this.orderWithCustomer,
  });

  @override
  Widget build(BuildContext context) {
    final order = orderWithCustomer.order;
    final customer = orderWithCustomer.customer;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.borderColor,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.isDiscounted ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.isDiscounted ? 'Discounted' : 'Regular',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 12),
          
          // Customer information
          Row(
            children: [
              Text(
                'Customer: ',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  customer?.name ?? 'Unknown Customer',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Location information
          Row(
            children: [
              Text(
                'Location: ',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  customer?.location != null 
                    ? '${customer!.location.lat.toStringAsFixed(4)}, ${customer.location.lon.toStringAsFixed(4)}'
                    : 'Location not available',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 12),

          // Order details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight: ${order.totalWeight.toStringAsFixed(1)} kg',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Volume: ${order.totalVolume.toStringAsFixed(2)} m³',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'COD: \$${order.codAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Items: ${order.items.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Center(
            child: CustomButton(
              onPressed: () {
                // Navigate to order details
                Navigator.pushNamed(
                  context,
                  '/order-detail',
                  arguments: orderWithCustomer,
                );
              },
              text: "View Order Details",
              isLoading: false,
              height: 48,
              width: MediaQuery.sizeOf(context).width * .7,
            ),
          ),
        ],
      ),
    );
  }
}
