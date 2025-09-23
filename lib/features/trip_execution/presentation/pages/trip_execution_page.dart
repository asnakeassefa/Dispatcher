import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/state/app_state_manager.dart'; // Import the state manager
import '../../../order/domain/entity/order.dart';
import '../../domain/entity/trip_execution.dart';
import '../../domain/entity/stop.dart';
import '../bloc/trip_execution_cubit.dart';
import '../bloc/trip_execution_state.dart';
import '../widgets/stop_card.dart';
import '../widgets/trip_progress_widget.dart';
import 'stop_detail_page.dart';
import '../widgets/cod_verification_dialog.dart';

class TripExecutionPage extends StatelessWidget {
  final String tripId;

  const TripExecutionPage({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TripExecutionCubit>(),
      child: _TripExecutionPageContent(tripId: tripId),
    );
  }
}

class _TripExecutionPageContent extends StatefulWidget {
  final String tripId;

  const _TripExecutionPageContent({required this.tripId});

  @override
  State<_TripExecutionPageContent> createState() => _TripExecutionPageContentState();
}

class _TripExecutionPageContentState extends State<_TripExecutionPageContent> {
  bool _tripStatusChanged = false;

  @override
  void initState() {
    super.initState();
    
    // Save trip execution ID for state restoration
    context.read<AppStateManager>().updateCurrentTripExecution(widget.tripId);
    
    // Load or create trip execution
    _loadOrCreateTripExecution();
  }

  @override
  void dispose() {
    // Clear trip execution ID when leaving
    context.read<AppStateManager>().updateCurrentTripExecution(null);
    super.dispose();
  }

  Future<void> _loadOrCreateTripExecution() async {
    // First try to load existing trip execution
    await context.read<TripExecutionCubit>().loadTripExecution(widget.tripId);
    
    // If no trip execution exists, create one
    final currentState = context.read<TripExecutionCubit>().state;
    if (currentState is TripExecutionError && 
        currentState.message.contains('Trip execution not found')) {
      // Create trip execution from trip
      await context.read<TripExecutionCubit>().createTripExecutionFromTrip(widget.tripId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return true to indicate if trip status changed
        Navigator.of(context).pop(_tripStatusChanged);
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trip Execution'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _loadOrCreateTripExecution();
              },
            ),
          ],
        ),
        body: BlocConsumer<TripExecutionCubit, TripExecutionState>(
          listener: (context, state) {
            if (state is TripExecutionError) {
              // Only show error if it's not a "not found" error (we handle that automatically)
              if (!state.message.contains('Trip execution not found')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    action: SnackBarAction(
                      label: 'Dismiss',
                      textColor: Colors.white,
                      onPressed: () {
                        context.read<TripExecutionCubit>().clearError();
                      },
                    ),
                  ),
                );
              }
            }
            
            // Track when trip status changes
            if (state is TripExecutionLoaded) {
              final tripExecution = state.tripExecution;
              if (tripExecution.status == TripExecutionStatus.completed || 
                  tripExecution.status == TripExecutionStatus.cancelled) {
                _tripStatusChanged = true;
                
                if (tripExecution.status == TripExecutionStatus.completed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trip completed successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else if (tripExecution.status == TripExecutionStatus.cancelled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Trip has been cancelled'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            }
          },
          builder: (context, state) {
            if (state is TripExecutionLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading trip execution...'),
                  ],
                ),
              );
            }

            if (state is TripExecutionError) {
              // If it's a "not found" error, show the setup UI
              if (state.message.contains('Trip execution not found')) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Setting up Trip Execution',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Creating trip execution for this trip...',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<TripExecutionCubit>().createTripExecutionFromTrip(widget.tripId);
                        },
                        child: const Text('Setup Trip Execution'),
                      ),
                    ],
                  ),
                );
              }
              
              // For other errors, show error UI
              return Center(
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
                      'Error',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _loadOrCreateTripExecution();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is TripExecutionLoaded) {
              return _buildTripExecutionContent(context, state.tripExecution);
            }
            
            // Initial state - show loading
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing trip execution...'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTripExecutionContent(BuildContext context, TripExecution tripExecution) {
    return Column(
      children: [
        // Trip Progress Header
        TripProgressWidget(tripExecution: tripExecution),
        
        // Trip Actions (only show if there are orders)
        if (tripExecution.stops.isNotEmpty)
          _buildTripActions(context, tripExecution),
        
        // Stops List or No Orders Message
        Expanded(
          child: _buildStopsList(context, tripExecution),
        ),
      ],
    );
  }

  Widget _buildStopsList(BuildContext context, TripExecution tripExecution) {
    if (tripExecution.stops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Ionicons.alert_circle_outline,
                    size: 64,
                    color: AppTheme.warningColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Orders Assigned',
                    style: AppTheme.titleLarge.copyWith(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This trip has no orders assigned yet.\nYou cannot start a trip without orders.',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back to Trip Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tripExecution.stops.length,
      itemBuilder: (context, index) {
        final stop = tripExecution.stops[index];
        final isTripCancelled = tripExecution.status == TripExecutionStatus.cancelled;
        final isTripCompleted = tripExecution.status == TripExecutionStatus.completed;
        final isDisabled = isTripCancelled || isTripCompleted;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StopCard(
            stop: stop,
            tripExecution: tripExecution,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StopDetailPage(
                    stop: stop,
                    tripExecution: tripExecution,
                  ),
                ),
              );
            },
            onStartStop: isDisabled ? null : () => _showStartStopDialog(context, stop),
            onCompleteOrder: isDisabled ? null : (order) => _showCompleteOrderDialog(context, stop, order),
            onFailOrder: isDisabled ? null : (order) => _showFailOrderDialog(context, stop, order),
          ),
        );
      },
    );
  }

  Widget _buildTripActions(BuildContext context, TripExecution tripExecution) {
    // Only show Complete and Cancel buttons - no Start button
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (tripExecution.canComplete())
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showCompleteTripDialog(context, tripExecution);
                },
                icon: const Icon(Icons.check),
                label: const Text('Complete Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          
          if (tripExecution.canCancel())
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _showCancelTripDialog(context, tripExecution);
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel Trip'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showStartTripDialog(BuildContext context, TripExecution tripExecution) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Trip'),
        content: Text(
          'Are you sure you want to start this trip?\n\n'
          'Vehicle: ${tripExecution.vehicle.plateNumber}\n'
          'Total Stops: ${tripExecution.totalStops}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TripExecutionCubit>().startTripExecution(tripExecution.id);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showCompleteTripDialog(BuildContext context, TripExecution tripExecution) {
    final notesController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Complete Trip',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Trip completion info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Trip completion: ${tripExecution.completedStops}/${tripExecution.totalStops} stops',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Notes field
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Driver Notes (Optional)',
                      hintText: 'Add any notes about the trip completion...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      contentPadding: EdgeInsets.all(10),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 4,
                    minLines: 2,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.read<TripExecutionCubit>().completeTripExecution(
                              tripExecution.id,
                              driverNotes: notesController.text.trim().isEmpty 
                                  ? null 
                                  : notesController.text.trim(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Complete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCancelTripDialog(BuildContext context, TripExecution tripExecution) async {
    final reasonController = TextEditingController();
    
    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Trip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to cancel this trip?\n\n'
              'This will mark all remaining stops as failed.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Cancellation Reason (Required)',
                border: OutlineInputBorder(),
                hintText: 'Enter reason for cancellation...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Keep Trip'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a cancellation reason'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final reason = reasonController.text.trim();
              Navigator.of(context).pop({'reason': reason});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Trip'),
          ),
        ],
      ),
    );
    
    // Only call the cubit method if the user confirmed with a reason
    if (result != null && context.mounted) {
      final reason = result['reason'];
      if (reason != null && reason.isNotEmpty) {
        await context.read<TripExecutionCubit>().cancelTripExecution(
          tripExecution.id,
          reason: reason,
        );
      }
    }
  }

  Future<void> _showStartStopDialog(BuildContext context, Stop stop) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Stop'),
        content: Text(
          'Are you ready to start this stop?\n\n'
          'Customer: ${stop.customerName}\n'
          'Orders: ${stop.orders.length}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      await context.read<TripExecutionCubit>().startStop(stop.id);
    }
  }

  Future<void> _showCompleteStopDialog(BuildContext context, Stop stop) async {
    // Check if any orders have COD amounts
    final hasCODOrders = stop.orders.any((order) => order.codAmount > 0);
    
    if (hasCODOrders) {
      // Show COD verification bottom sheet
      final result = await showModalBottomSheet<Map<String, Map<String, dynamic>>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CODVerificationDialog(
          orders: stop.orders.where((order) => order.codAmount > 0).toList(),
        ),
      );
      
      if (result != null && context.mounted) {
        // Complete the stop with COD data
        await context.read<TripExecutionCubit>().completeStop(
          stop.id, 
          codData: result,
        );
      }
    } else {
      // No COD orders, show regular completion dialog
      final notesController = TextEditingController();
      
      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Complete Stop'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Complete stop for ${stop.customerName}?'),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop({
                'notes': notesController.text.trim(),
              }),
              child: const Text('Complete'),
            ),
          ],
        ),
      );
      
      if (result != null && context.mounted) {
        final notes = result['notes']?.isEmpty == true ? null : result['notes'];
        await context.read<TripExecutionCubit>().completeStop(stop.id, notes: notes);
      }
    }
  }

  Future<void> _showFailStopDialog(BuildContext context, Stop stop) async {
    final reasonController = TextEditingController();
    
    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Stop as Failed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mark this stop as failed?\n\n'
              'Customer: ${stop.customerName}\n'
              'Orders: ${stop.orders.length}\n\n'
              'This will mark all orders in this stop as failed.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Failure Reason (Required)',
                border: OutlineInputBorder(),
                hintText: 'Enter reason for failure...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a failure reason'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final reason = reasonController.text.trim();
              Navigator.of(context).pop({'reason': reason});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark as Failed'),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      final reason = result['reason'];
      if (reason != null && reason.isNotEmpty) {
        await context.read<TripExecutionCubit>().failStop(stop.id, reason: reason);
      }
    }
  }

  Future<void> _showCompleteOrderDialog(BuildContext context, Stop stop, Order order) async {
    // Show warning for discounted orders
    if (order.isDiscounted) {
      final confirmFullDelivery = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discounted Order Notice'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              Text('Order ${order.id} is discounted.'),
              const SizedBox(height: 8),
              const Text(
                'Partial delivery is not allowed for discounted orders. Please ensure all items are delivered.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm Full Delivery'),
            ),
          ],
        ),
      );
      
      if (confirmFullDelivery != true) return;
    }

    // Check if order has COD amount
    if (order.codAmount > 0) {
      // Show COD verification dialog
      final result = await showDialog<Map<String, Map<String, dynamic>>?>(
        context: context,
        builder: (context) => CODVerificationDialog(
          orders: [order], // Only this specific order
        ),
      );
      
      if (result != null && context.mounted) {
        final codData = result[order.id];
        if (codData != null) {
          await context.read<TripExecutionCubit>().completeOrder(
            stop.id,
            order.id,
            collectedAmount: codData['collectedAmount'] as double?,
            collectionNotes: codData['collectionNotes'] as String?,
            isPartialDelivery: false, // Always full delivery for now
          );
        }
      }
    } else {
      // No COD, just complete the order
      await context.read<TripExecutionCubit>().completeOrder(
        stop.id,
        order.id,
        isPartialDelivery: false, // Always full delivery for now
      );
    }
  }

  Future<void> _showFailOrderDialog(BuildContext context, Stop stop, Order order) async {
    final reasonController = TextEditingController();
    
    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fail Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to fail Order ${order.id}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Failure Reason',
                hintText: 'Enter reason for failure...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                Navigator.of(context).pop({'reason': reason});
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Fail Order'),
          ),
        ],
      ),
    );
    
    if (result != null && context.mounted) {
      final reason = result['reason'];
      if (reason != null) {
        await context.read<TripExecutionCubit>().failOrder(
          stop.id,
          order.id,
          reason: reason,
        );
      }
    }
  }
}