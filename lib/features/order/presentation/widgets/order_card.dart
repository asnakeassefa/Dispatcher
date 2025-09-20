import 'package:dispatcher/core/theme/app_theme.dart';
import 'package:dispatcher/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                'Order #12345',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Pending',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 12),
          Text('Customer: ', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(
            'Location: 123 Main St, City, Country',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                'Size: 2.5 kg, 0.1 m³',
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(width: 24),
              Text(
                'COD: \$120.0',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),

          const SizedBox(height: 24),
          Center(
            child: CustomButton(
              onPressed: (){},
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
