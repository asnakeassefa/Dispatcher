import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/trip.dart';
import '../../domain/entity/vehicle.dart';
import '../../../order/domain/entity/order.dart';
import '../../../order/domain/entity/customer.dart';
import '../bloc/trip_planner_cubit.dart';
import '../bloc/trip_planner_state.dart';
import 'assign_orders_page.dart';

class TripDetailPage extends StatelessWidget {
  final String tripId;

  const TripDetailPage({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TripPlannerCubit, TripPlannerState>(
      listener: (context, state) {
        if (state is TripPlannerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        // Get the current trip from the state
        Trip? currentTrip;
        if (state is TripPlannerLoaded) {
          currentTrip = state.trips.where((trip) => trip.id == tripId).firstOrNull;
        }

        if (currentTrip == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Trip $tripId'),
            ),
            body: const Center(
              child: Text('Trip not found'),
            ),
          );
        }

        return _buildTripDetailContent(context, currentTrip);
      },
    );
  }

  Widget _buildTripDetailContent(BuildContext context, Trip trip) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip ${trip.id}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  // TODO: Navigate to edit trip page
                  break;
                case 'assign_orders':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AssignOrdersPage(trip: trip),
                    ),
                  );
                  break;
                case 'assign_vehicle':
                  // TODO: Navigate to assign vehicle page
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Trip'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'assign_orders',
                child: ListTile(
                  leading: Icon(Icons.shopping_bag),
                  title: Text('Assign Orders'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'assign_vehicle',
                child: ListTile(
                  leading: Icon(Icons.local_shipping),
                  title: Text('Assign Vehicle'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Status Card
                  _buildStatusCard(context, trip),
                  const SizedBox(height: 16),

                  // Trip Information
                  _buildTripInfoCard(context, trip),
                  const SizedBox(height: 16),

                  // Vehicle Information
                  _buildVehicleCard(context, trip),
                  const SizedBox(height: 16),

                  // Orders Information
                  _buildOrdersCard(context, trip),
                  const SizedBox(height: 16),

                  // Trip Statistics
                  _buildStatisticsCard(context, trip),
                ],
              ),
            ),
          ),
          // Bottom Action Button
          _buildBottomActionButton(context, trip),
        ],
      ),
    );
  }

  Widget _buildBottomActionButton(BuildContext context, Trip trip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add Orders Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AssignOrdersPage(trip: trip),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Add Orders'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Main Action Button
            SizedBox(
              width: double.infinity,
              child: _getActionButton(context, trip),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getActionButton(BuildContext context, Trip trip) {
    switch (trip.status) {
      case TripStatus.planned:
        return ElevatedButton.icon(
          onPressed: () => _startTrip(context, trip),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Trip'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        );
      case TripStatus.inProgress:
        return ElevatedButton.icon(
          onPressed: () => _completeTrip(context, trip),
          icon: const Icon(Icons.check_circle),
          label: const Text('Complete Trip'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        );
      case TripStatus.completed:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor),
              const SizedBox(width: 8),
              Text(
                'Trip Completed',
                style: TextStyle(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      case TripStatus.cancelled:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel, color: AppTheme.errorColor),
              const SizedBox(width: 8),
              Text(
                'Trip Cancelled',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildStatusCard(BuildContext context, Trip trip) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (trip.status) {
      case TripStatus.planned:
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        statusText = 'Planned';
        break;
      case TripStatus.inProgress:
        statusColor = Colors.orange;
        statusIcon = Icons.local_shipping;
        statusText = 'In Progress';
        break;
      case TripStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completed';
        break;
      case TripStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInfoCard(BuildContext context, Trip trip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Trip Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Trip ID', trip.id),
            _buildInfoRow('Date', _formatDate(trip.date)),
            _buildInfoRow('Time', _formatTime(trip.date)),
            _buildInfoRow('Total Orders', '${trip.totalOrders}'),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Trip trip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Vehicle Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (trip.assignedVehicle == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No vehicle assigned to this trip',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              _buildInfoRow('Plate Number', trip.assignedVehicle!.plateNumber),
              _buildInfoRow('Driver', trip.assignedVehicle!.driverName),
              _buildInfoRow('Capacity', '${trip.assignedVehicle!.capacity}kg'),
              _buildInfoRow('Volume', '${trip.assignedVehicle!.volumeCapacity}m³'),
              _buildInfoRow('Status', _getVehicleStatusText(trip.assignedVehicle!.status)),
              const SizedBox(height: 12),
              // Vehicle capacity usage
              _buildCapacityUsageBar(context, trip),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityUsageBar(BuildContext context, Trip trip) {
    if (trip.assignedVehicle == null) return const SizedBox.shrink();

    final weightUsage = trip.totalWeight / trip.assignedVehicle!.capacity;
    final volumeUsage = trip.totalVolume / trip.assignedVehicle!.volumeCapacity;
    final maxUsage = weightUsage > volumeUsage ? weightUsage : volumeUsage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Capacity Usage',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weight: ${(weightUsage * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: weightUsage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      weightUsage > 0.8 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Volume: ${(volumeUsage * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: volumeUsage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      volumeUsage > 0.8 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrdersCard(BuildContext context, Trip trip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Assigned Orders (${trip.assignedOrders.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (trip.assignedOrders.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 12),
                    Text('No orders assigned to this trip'),
                  ],
                ),
              )
            else
              ...trip.assignedOrders.map((order) => _buildOrderItem(context, order)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.codAmount > 0 ? Colors.orange[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.codAmount > 0 ? 'COD: \$${order.codAmount.toStringAsFixed(2)}' : 'Prepaid',
                  style: TextStyle(
                    fontSize: 12,
                    color: order.codAmount > 0 ? Colors.orange[800] : Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Customer ID: ${order.customerId}'),
          Text('Items: ${order.items.length}'),
          Text('Weight: ${order.totalWeight.toStringAsFixed(2)}kg'),
          Text('Volume: ${order.totalVolume.toStringAsFixed(3)}m³'),
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
    );
  }

  Widget _buildStatisticsCard(BuildContext context, Trip trip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Trip Statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Weight',
                    '${trip.totalWeight.toStringAsFixed(2)}kg',
                    Icons.scale,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Volume',
                    '${trip.totalVolume.toStringAsFixed(3)}m³',
                    Icons.inventory,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total COD',
                    '\$${trip.totalCodAmount.toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Orders',
                    '${trip.totalOrders}',
                    Icons.shopping_bag,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getVehicleStatusText(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return 'Available';
      case VehicleStatus.assigned:
        return 'Assigned';
      case VehicleStatus.inUse:
        return 'In Use';
      case VehicleStatus.maintenance:
        return 'Maintenance';
      case VehicleStatus.outOfService:
        return 'Out of Service';
    }
  }

  void _startTrip(BuildContext context, Trip trip) {
    context.read<TripPlannerCubit>().updateTripStatus(
      tripId: trip.id,
      status: TripStatus.inProgress,
    );
  }

  void _completeTrip(BuildContext context, Trip trip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Trip'),
        content: const Text('Are you sure you want to mark this trip as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TripPlannerCubit>().updateTripStatus(
                tripId: trip.id,
                status: TripStatus.completed,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}
