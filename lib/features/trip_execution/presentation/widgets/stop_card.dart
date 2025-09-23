import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/stop.dart';
import '../../domain/entity/trip_execution.dart';
import '../../../order/domain/entity/order.dart';
import 'order_item_card.dart';

class StopCard extends StatelessWidget {
  final Stop stop;
  final TripExecution tripExecution;
  final VoidCallback? onTap;
  final VoidCallback? onStartStop;
  final Function(Order)? onCompleteOrder;
  final Function(Order)? onFailOrder;

  const StopCard({
    super.key,
    required this.stop,
    required this.tripExecution,
    this.onTap,
    this.onStartStop,
    this.onCompleteOrder,
    this.onFailOrder,
  });

  @override
  Widget build(BuildContext context) {
    final isTripCancelled = tripExecution.status == TripExecutionStatus.cancelled;
    final isTripCompleted = tripExecution.status == TripExecutionStatus.completed;
    final isDisabled = isTripCancelled || isTripCompleted;

    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDisabled ? Colors.grey.withOpacity(0.1) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with customer info and status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.customerName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDisabled ? Colors.grey : null,
                          ),
                        ),
                        Text(
                          stop.address,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDisabled ? Colors.grey : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Trip status indicators
                  if (isTripCancelled)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Trip Cancelled',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (isTripCompleted)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Trip Completed',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Stop action button (Start stop)
              if (stop.canStart()) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isDisabled ? null : onStartStop,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Start Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDisabled ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Individual Orders
              if (stop.orders.isNotEmpty) ...[
                Text(
                  'Orders (${stop.orders.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDisabled ? Colors.grey : null,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Display each order individually
                ...stop.orders.map((order) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OrderItemCard(
                      order: order,
                      isDisabled: isDisabled || stop.status == StopStatus.pending,
                      onCompleteOrder: (isDisabled || stop.status == StopStatus.pending) 
                          ? null 
                          : () => onCompleteOrder?.call(order),
                      onFailOrder: (isDisabled || stop.status == StopStatus.pending) 
                          ? null 
                          : () => onFailOrder?.call(order),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (stop.status) {
      case StopStatus.pending:
        return Colors.orange;
      case StopStatus.inTransit:
        return Colors.blue;
      case StopStatus.completed:
        return Colors.green;
      case StopStatus.failed:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (stop.status) {
      case StopStatus.pending:
        return Icons.pending;
      case StopStatus.inTransit:
        return Icons.local_shipping;
      case StopStatus.completed:
        return Icons.check_circle;
      case StopStatus.failed:
        return Icons.error;
    }
  }

  String _getStatusText() {
    switch (stop.status) {
      case StopStatus.pending:
        return 'Pending';
      case StopStatus.inTransit:
        return 'In Transit';
      case StopStatus.completed:
        return 'Completed';
      case StopStatus.failed:
        return 'Failed';
    }
  }
}
