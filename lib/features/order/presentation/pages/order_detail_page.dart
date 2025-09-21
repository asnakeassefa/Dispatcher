import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/customer_card.dart';
import '../widgets/status_card.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Order Details'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // display order id
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.boxBackground,
                ),
                padding: const EdgeInsets.all(16),
                width: MediaQuery.sizeOf(context).width,
                height: 80,
                child: Row(
                  children: [
                    Text(
                      'Order ID: #123456',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 24),
                    StatusCard(
                      isSelected: true,
                      text: 'Pending',
                      color: Colors.orange,
                      icon: Ionicons.time,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // customer information
              CustomerCard(),
              const SizedBox(height: 16),
              // order items
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Order Items',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.borderColor,
                        child: Icon(
                          Ionicons.fast_food_outline,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      title: Text('Item ${index + 1}'),
                      subtitle: Text('Quantity: ${index + 1}'),
                      trailing: Text('\$${(index + 1) * 10}'),
                    );
                  },
                ),
              ),
              // show total amount
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '\$150.00',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // discount information
              const SizedBox(height: 16),
              // add a card here that has light grey rounded border and have information in side the card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(16),
                width: MediaQuery.sizeOf(context).width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    // add two line here which has cash on Deliver and discount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cash on Delivery:',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          '\$120.00',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Discount:',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          '-\$30.00',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
