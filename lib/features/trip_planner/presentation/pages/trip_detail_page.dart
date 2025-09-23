import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/timezone_helper.dart';
import '../../../../core/state/app_state_manager.dart'; // Import the state manager
import '../bloc/trip_planner_cubit.dart';
import '../bloc/trip_planner_state.dart';
import '../../domain/entity/trip.dart';
import '../../domain/entity/vehicle.dart';
import '../pages/assign_orders_page.dart';
import '../../../trip_execution/presentation/pages/trip_execution_page.dart';

class TripDetailPage extends StatefulWidget {
  final String tripId;

  const TripDetailPage({
    super.key,
    required this.tripId,
  });

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  String _depotTimezone = 'UTC';

  @override
  void initState() {
    super.initState();
    _loadDepotTimezone();
  }

  Future<void> _loadDepotTimezone() async {
    try {
      final timezone = await TimezoneHelper.getDepotTimezone();
      if (mounted) {
        setState(() {
          _depotTimezone = timezone;
        });
      }
    } catch (e) {
      // Keep default UTC
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripPlannerCubit, TripPlannerState>(
      builder: (context, state) {
        if (state is TripPlannerLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Trip Details'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading trip details...'),
                ],
              ),
            ),
          );
        }

        if (state is TripPlannerError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Trip Details'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading trip',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Go Back'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<TripPlannerCubit>().loadTrips();
                        },
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        if (state is TripPlannerLoaded) {
          // Find the trip with robust search
          Trip? trip;
          try {
            // Try exact match first
            trip = state.trips.firstWhere(
              (t) => t.id == widget.tripId,
              orElse: () => throw Exception('Trip not found'),
            );
          } catch (e) {
            // Try case-insensitive match
            try {
              trip = state.trips.firstWhere(
                (t) => t.id.toLowerCase() == widget.tripId.toLowerCase(),
                orElse: () => throw Exception('Trip not found'),
              );
            } catch (e2) {
              // Try trimmed match
              try {
                trip = state.trips.firstWhere(
                  (t) => t.id.trim() == widget.tripId.trim(),
                  orElse: () => throw Exception('Trip not found'),
                );
              } catch (e3) {
                // Try partial match
                trip = state.trips.firstWhere(
                  (t) => t.id.contains(widget.tripId) || widget.tripId.contains(t.id),
                  orElse: () => throw Exception('Trip not found'),
                );
              }
            }
          }

          if (trip == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Trip Details'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Trip not found',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The trip you\'re looking for doesn\'t exist or has been removed.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildTripDetailContent(context, trip);
        }

        return const Scaffold(
          body: Center(
            child: Text('No trip data available'),
          ),
        );
      },
    );
  }

  Widget _buildTripDetailContent(BuildContext context, Trip trip) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TripPlannerCubit>().loadTrips();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Trip Header Card
            _buildTripHeaderCard(context, trip),
            
            // Trip Information Card
            _buildTripInfoCard(context, trip),
            
            // Vehicle Information Card
            if (trip.assignedVehicle != null)
              _buildVehicleCard(context, trip.assignedVehicle!),
            
            // Orders Information Card
            _buildOrdersCard(context, trip),
            
            // Action Buttons
            _buildActionButtons(context, trip),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTripHeaderCard(BuildContext context, Trip trip) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStatusColor(trip.status),
            _getStatusColor(trip.status).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(trip.status).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Ionicons.car_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip #${trip.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<String>(
                        future: TimezoneHelper.getDepotTimezone(),
                        builder: (context, snapshot) {
                          final timezone = snapshot.data ?? 'UTC';
                          return Text(
                            'Scheduled: ${TimezoneHelper.formatDepotDate(trip.date, timezone)} at ${TimezoneHelper.formatDepotTime(trip.date, timezone)} ($timezone)',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(trip.status),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Trip Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Ionicons.bag_outline,
                    label: 'Orders',
                    value: '${trip.assignedOrders.length}',
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Ionicons.scale_outline,
                    label: 'Weight',
                    value: '${trip.totalWeight.toStringAsFixed(1)} kg',
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Ionicons.cash_outline,
                    label: 'COD',
                    value: '\$${trip.totalCodAmount.toStringAsFixed(0)}',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInfoCard(BuildContext context, Trip trip) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Ionicons.information_circle_outline,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Trip Information',
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildInfoRow(
                icon: Ionicons.calendar_outline,
                label: 'Date',
                value: _formatDate(trip.date),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Ionicons.time_outline,
                label: 'Time',
                value: _formatTime(trip.date),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Ionicons.flag_outline,
                label: 'Status',
                value: _getStatusText(trip.status),
                valueColor: _getStatusColor(trip.status),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Vehicle vehicle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Ionicons.car_outline,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Assigned Vehicle',
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Ionicons.car_sport_outline,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle.plateNumber,
                                style: AppTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                vehicle.driverName,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildVehicleInfo(
                            icon: Ionicons.scale_outline,
                            label: 'Capacity',
                            value: '${vehicle.capacity.toStringAsFixed(1)} kg',
                          ),
                        ),
                        Expanded(
                          child: _buildVehicleInfo(
                            icon: Ionicons.cube_outline,
                            label: 'Volume',
                            value: '${vehicle.volumeCapacity.toStringAsFixed(1)} m³',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersCard(BuildContext context, Trip trip) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Ionicons.bag_outline,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Assigned Orders (${trip.assignedOrders.length})',
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (trip.assignedOrders.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.borderColor,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Ionicons.bag_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No orders assigned',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add orders to this trip to get started',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...trip.assignedOrders.take(3).map((order) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Ionicons.receipt_outline,
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.id}',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '\$${order.codAmount.toStringAsFixed(0)} • ${order.totalWeight.toStringAsFixed(1)} kg',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              
              if (trip.assignedOrders.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${trip.assignedOrders.length - 3} more orders',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Trip trip) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Add Orders button - different behavior based on trip status
          if (trip.status == TripStatus.planned)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _navigateToAssignOrders(context, trip);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Orders'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else if (trip.status == TripStatus.inProgress)
            Container(
              width: double.infinity,
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
                      'Trip is in progress. Orders cannot be added while driver is on route.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          if (trip.status == TripStatus.planned || trip.status == TripStatus.inProgress)
            const SizedBox(height: 12),
          
          // Main action button
          SizedBox(
            width: double.infinity,
            child: _buildMainActionButton(context, trip),
          ),
        ],
      ),
    );
  }

  // Helper method to navigate to assign orders and handle return
  Future<void> _navigateToAssignOrders(BuildContext context, Trip trip) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AssignOrdersPage(trip: trip),
      ),
    );
    
    // Refresh the trip data when returning from assign orders
    if (context.mounted) {
      // Show a brief loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Updating trip orders...'),
            ],
          ),
          duration: Duration(seconds: 1),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      
      // Refresh the trips data
      context.read<TripPlannerCubit>().loadTrips();
    }
  }

  Widget _buildMainActionButton(BuildContext context, Trip trip) {
    // Don't allow starting trips without orders
    if (trip.assignedOrders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.warningColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.warningColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Ionicons.alert_circle_outline,
              color: AppTheme.warningColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Cannot Start Trip',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.warningColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add orders to this trip before starting',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    switch (trip.status) {
      case TripStatus.planned:
        return ElevatedButton.icon(
          onPressed: () {
            _navigateToTripExecution();
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Trip'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      
      case TripStatus.inProgress:
        return ElevatedButton.icon(
          onPressed: () {
            _navigateToTripExecution();
          },
          icon: const Icon(Icons.directions_car),
          label: const Text('Continue Trip'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      
      case TripStatus.completed:
        return ElevatedButton.icon(
          onPressed: () {
            _navigateToTripExecution();
          },
          icon: const Icon(Icons.visibility),
          label: const Text('View Trip'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      
      case TripStatus.cancelled:
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.cancel),
          label: const Text('Trip Cancelled'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    }
  }

  // Helper method to navigate to trip execution and handle return
  Future<void> _navigateToTripExecution() async {
    // Save detail page state
    context.read<AppStateManager>().updateDetailPage(
      DetailPageType.tripExecution,
      tripExecutionId: widget.tripId,
    );

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TripExecutionPage(tripId: widget.tripId),
      ),
    );

    // Clear detail page state when returning
    context.read<AppStateManager>().updateDetailPage(
      DetailPageType.tripDetail,
      tripId: widget.tripId,
    );

    if (mounted) {
      // Show loading snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refreshing trip data...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Refresh trip data
      await context.read<TripPlannerCubit>().loadTrips();
    }
  }

  // Helper widgets
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
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
            color: color.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: valueColor ?? AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(TripStatus status) {
    final statusData = _getStatusData(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusData.icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            statusData.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  StatusData _getStatusData(TripStatus status) {
    switch (status) {
      case TripStatus.planned:
        return StatusData(
          color: AppTheme.warningColor,
          text: 'Planned',
          icon: Ionicons.time_outline,
        );
      case TripStatus.inProgress:
        return StatusData(
          color: AppTheme.primaryColor,
          text: 'Active',
          icon: Ionicons.play_circle_outline,
        );
      case TripStatus.completed:
        return StatusData(
          color: AppTheme.successColor,
          text: 'Completed',
          icon: Ionicons.checkmark_circle_outline,
        );
      case TripStatus.cancelled:
        return StatusData(
          color: AppTheme.errorColor,
          text: 'Cancelled',
          icon: Ionicons.close_circle_outline,
        );
    }
  }

  Color _getStatusColor(TripStatus status) {
    return _getStatusData(status).color;
  }

  String _getStatusText(TripStatus status) {
    return _getStatusData(status).text;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripDate = DateTime(date.year, date.month, date.day);
    
    if (tripDate == today) {
      return 'Today';
    } else if (tripDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (tripDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class StatusData {
  final Color color;
  final String text;
  final IconData icon;

  StatusData({
    required this.color,
    required this.text,
    required this.icon,
  });
}
