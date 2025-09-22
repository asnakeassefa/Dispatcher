import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/trip_planner_cubit.dart';
import '../bloc/trip_planner_state.dart';
import '../../domain/entity/vehicle.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Vehicle? _selectedVehicle;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _updateDateController();
    
    // Load available vehicles when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripPlannerCubit>().loadAvailableVehicles();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _updateDateController() {
    if (_selectedDate != null && _selectedTime != null) {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      _dateController.text = _formatDateTime(dateTime);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (tripDate == today) {
      dateStr = 'Today';
    } else if (tripDate == today.add(const Duration(days: 1))) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr at $timeStr';
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _updateDateController();
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        _selectedTime = time;
        _updateDateController();
      });
    }
  }

  Future<void> _createTrip() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedTime == null) {
      return;
    }

    if (_isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await context.read<TripPlannerCubit>().createTrip(
        date: dateTime,
        assignedVehicle: _selectedVehicle,
      );
      
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip created successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create trip: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createTrip,
            child: _isCreating 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<TripPlannerCubit, TripPlannerState>(
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
            final availableVehicles = state is TripPlannerLoaded 
                ? state.availableVehicles 
                : <Vehicle>[];

            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),

                    // Date and Time Selection
                    CustomTextField(
                      controller: _dateController,
                      isObscure: false,
                      headerText: 'Date & Time',
                      hintText: 'Select date and time',
                      prefixIcon: Ionicons.calendar,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select date and time';
                        }
                        return null;
                      },
                      onChanged: (value) {},
                    ),

                    const SizedBox(height: 16),

                    // Date and Time Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isCreating ? null : _selectDate,
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Select Date'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isCreating ? null : _selectTime,
                            icon: const Icon(Icons.access_time),
                            label: const Text('Select Time'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Vehicle Selection
                    Text(
                      'Vehicle Selection',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    if (availableVehicles.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey),
                            SizedBox(width: 12),
                            Text('No vehicles available'),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: availableVehicles.map((vehicle) {
                            final isSelected = _selectedVehicle?.id == vehicle.id;
                            return ListTile(
                              leading: Icon(
                                Icons.local_shipping,
                                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                              ),
                              title: Text(
                                '${vehicle.plateNumber} - ${vehicle.driverName}',
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                'Capacity: ${vehicle.capacity}kg, Volume: ${vehicle.volumeCapacity}m³',
                              ),
                              trailing: isSelected 
                                  ? Icon(Icons.check_circle, color: AppTheme.primaryColor)
                                  : const Icon(Icons.radio_button_unchecked),
                              onTap: _isCreating ? null : () {
                                setState(() {
                                  _selectedVehicle = isSelected ? null : vehicle;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Ionicons.information_circle,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You can assign orders to this trip after creating it.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _createTrip,
                        child: _isCreating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Creating...'),
                              ],
                            )
                          : const Text('Create Trip'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}