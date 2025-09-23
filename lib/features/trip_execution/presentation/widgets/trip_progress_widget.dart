import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/trip_execution.dart';

class TripProgressWidget extends StatelessWidget {
  final TripExecution tripExecution;

  const TripProgressWidget({
    super.key,
    required this.tripExecution,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Ionicons.car_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip ${tripExecution.trip.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      tripExecution.vehicle.plateNumber,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${tripExecution.completedStops}/${tripExecution.totalStops} stops',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: tripExecution.completionPercentage / 100,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
              const SizedBox(height: 4),
              Text(
                '${tripExecution.completionPercentage.toStringAsFixed(1)}% Complete',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stats row
          Row(
            children: [
              _buildStatItem(
                icon: Ionicons.time_outline,
                label: 'Pending',
                value: tripExecution.pendingStops.toString(),
                color: Colors.white.withOpacity(0.8),
              ),
              _buildStatItem(
                icon: Ionicons.play_outline,
                label: 'In Transit',
                value: tripExecution.inTransitStops.toString(),
                color: Colors.white.withOpacity(0.8),
              ),
              _buildStatItem(
                icon: Ionicons.checkmark_outline,
                label: 'Completed',
                value: tripExecution.completedStops.toString(),
                color: Colors.white.withOpacity(0.8),
              ),
              if (tripExecution.failedStops > 0)
                _buildStatItem(
                  icon: Ionicons.close_outline,
                  label: 'Failed',
                  value: tripExecution.failedStops.toString(),
                  color: Colors.red[300]!,
                ),
            ],
          ),
          
          // Trip duration
          if (tripExecution.startedAt != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Ionicons.timer_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Duration: ${_formatDuration(tripExecution.startedAt!, tripExecution.completedAt)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String label;
    
    switch (tripExecution.status) {
      case TripExecutionStatus.notStarted:
        color = Colors.grey[300]!;
        label = 'Not Started';
        break;
      case TripExecutionStatus.inProgress:
        color = Colors.blue[300]!;
        label = 'In Progress';
        break;
      case TripExecutionStatus.completed:
        color = Colors.green[300]!;
        label = 'Completed';
        break;
      case TripExecutionStatus.cancelled:
        color = Colors.red[300]!;
        label = 'Cancelled';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
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
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(DateTime start, DateTime? end) {
    final endTime = end ?? DateTime.now();
    final duration = endTime.difference(start);
    
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
