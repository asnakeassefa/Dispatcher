import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/trip.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;

  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Trip ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Trip #${trip.id}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 12),

              // Date
              Row(
                children: [
                  Icon(
                    Ionicons.calendar,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(trip.date),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Vehicle Information
              if (trip.assignedVehicle != null) ...[
                Row(
                  children: [
                    Icon(
                      Ionicons.car,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${trip.assignedVehicle!.plateNumber} - ${trip.assignedVehicle!.driverName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Orders Information
              Row(
                children: [
                  Icon(
                    Ionicons.bag,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${trip.totalOrders} orders',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Ionicons.scale,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${trip.totalWeight.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // COD Amount
              Row(
                children: [
                  Icon(
                    Ionicons.cash,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'COD: \$${trip.totalCodAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    String statusText;
    IconData statusIcon;

    switch (trip.status) {
      case TripStatus.planned:
        chipColor = AppTheme.warningColor;
        statusText = 'Planned';
        statusIcon = Ionicons.time;
        break;
      case TripStatus.inProgress:
        chipColor = AppTheme.primaryColor;
        statusText = 'In Progress';
        statusIcon = Ionicons.play;
        break;
      case TripStatus.completed:
        chipColor = AppTheme.successColor;
        statusText = 'Completed';
        statusIcon = Ionicons.checkmark;
        break;
      case TripStatus.cancelled:
        chipColor = AppTheme.errorColor;
        statusText = 'Cancelled';
        statusIcon = Ionicons.close;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 12,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripDate = DateTime(date.year, date.month, date.day);
    
    if (tripDate == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (tripDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${_formatTime(date)}';
    } else if (tripDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
