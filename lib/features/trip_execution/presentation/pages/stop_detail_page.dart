import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/stop.dart';
import '../../domain/entity/trip_execution.dart';
import '../bloc/trip_execution_cubit.dart';
import '../bloc/trip_execution_state.dart';
import '../widgets/order_item_card.dart';
import '../widgets/stop_card.dart';

class StopDetailPage extends StatelessWidget {
  final Stop stop;
  final TripExecution tripExecution;

  const StopDetailPage({
    super.key,
    required this.stop,
    required this.tripExecution,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stop Details - ${stop.customerName}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TripExecutionCubit, TripExecutionState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stop header
                _buildStopHeader(context),
                
                const SizedBox(height: 20),
                
                // Customer information
                _buildCustomerInfo(context),
                
                const SizedBox(height: 20),
                
                // Orders list
                Text(
                  'Orders (${stop.orders.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                SizedBox(
                  height: 300,
                  child: _buildOrdersList(context),
                ),
                
                const SizedBox(height: 20),
                
                // Info message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'To perform actions on this stop, go back to the trip execution page.',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer info
          Row(
            children: [
              _buildStatusIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.customerName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      stop.address,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stop stats
          Row(
            children: [
              _buildStatCard(
                icon: Ionicons.cube_outline,
                label: 'Orders',
                value: stop.totalOrders.toString(),
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Ionicons.scale_outline,
                label: 'Weight',
                value: '${stop.totalWeight.toStringAsFixed(1)} kg',
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Ionicons.cash_outline,
                label: 'COD',
                value: '₱${stop.totalCodAmount.toStringAsFixed(0)}',
                color: Colors.green,
              ),
            ],
          ),
          
          // Timestamps
          if (stop.startedAt != null || stop.completedAt != null) ...[
            const SizedBox(height: 16),
            _buildTimestamps(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData iconData;
    Color color;
    
    switch (stop.status) {
      case StopStatus.pending:
        iconData = Ionicons.time_outline;
        color = Colors.grey;
        break;
      case StopStatus.inTransit:
        iconData = Ionicons.play_circle_outline;
        color = Colors.blue;
        break;
      case StopStatus.completed:
        iconData = Ionicons.checkmark_circle_outline;
        color = Colors.green;
        break;
      case StopStatus.failed:
        iconData = Ionicons.close_circle_outline;
        color = Colors.red;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String label;
    
    switch (stop.status) {
      case StopStatus.pending:
        color = Colors.grey;
        label = 'Pending';
        break;
      case StopStatus.inTransit:
        color = Colors.blue;
        label = 'In Transit';
        break;
      case StopStatus.completed:
        color = Colors.green;
        label = 'Completed';
        break;
      case StopStatus.failed:
        color = Colors.red;
        label = 'Failed';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestamps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stop.startedAt != null)
          _buildTimestampRow(
            icon: Ionicons.play_outline,
            label: 'Started',
            time: stop.startedAt!,
            color: Colors.blue,
          ),
        if (stop.completedAt != null)
          _buildTimestampRow(
            icon: stop.status == StopStatus.completed 
                ? Ionicons.checkmark_outline 
                : Ionicons.close_outline,
            label: stop.status == StopStatus.completed ? 'Completed' : 'Failed',
            time: stop.completedAt!,
            color: stop.status == StopStatus.completed ? Colors.green : Colors.red,
          ),
      ],
    );
  }

  Widget _buildTimestampRow({
    required IconData icon,
    required String label,
    required DateTime time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ${_formatTime(time)}',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    if (stop.orders.isEmpty) {
      return const Center(
        child: Text('No orders for this stop'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stop.orders.length,
      itemBuilder: (context, index) {
        final order = stop.orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OrderItemCard(order: order),
        );
      },
    );
  }

  Widget _buildCustomerInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        StopCard(stop: stop, tripExecution: tripExecution),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
