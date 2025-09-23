import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/trip_planner_cubit.dart';
import '../bloc/trip_planner_state.dart';
import '../../domain/entity/vehicle.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({super.key});

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Vehicle? _selectedVehicle;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    
    // Load available vehicles when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripPlannerCubit>().loadAvailableVehicles();
    });
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
      });
    }
  }

  Future<void> _createTrip() async {
    // Comprehensive validation
    final validationErrors = <String>[];
    
    if (_selectedDate == null) {
      validationErrors.add('Please select a date');
    }
    
    if (_selectedTime == null) {
      validationErrors.add('Please select a time');
    }
    
    if (_selectedVehicle == null) {
      validationErrors.add('Please select a vehicle');
    }
    
    // Validate date and time are not in the past
    if (_selectedDate != null && _selectedTime != null) {
      final selectedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      
      final now = DateTime.now();
      if (selectedDateTime.isBefore(now)) {
        validationErrors.add('Trip date and time cannot be in the past');
      }
    }
    
    if (validationErrors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationErrors.join('\n')),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
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

  // Add a helper method to check if all required fields are filled and valid
  bool get _isFormValid {
    if (_selectedDate == null || _selectedTime == null || _selectedVehicle == null) {
      return false;
    }
    
    // Check if date/time is not in the past
    final selectedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    
    return !selectedDateTime.isBefore(DateTime.now());
  }

  // Add a helper method to check if the selected date/time is in the past
  bool get _isDateTimeInPast {
    if (_selectedDate == null || _selectedTime == null) {
      return false;
    }
    
    final selectedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    
    return selectedDateTime.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Trip'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createTrip,
            child: _isCreating 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Create',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeaderSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Date & Time Selection
                  _buildDateTimeSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Vehicle Selection
                  _buildVehicleSection(availableVehicles),
                  
                  const SizedBox(height: 32),
                  
                  // Info Card
                  _buildInfoCard(),
                  
                  const SizedBox(height: 40),
                  
                  // Create Button
                  _buildCreateButton(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                  Ionicons.add_circle_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Trip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                  Text(
                      'Plan your delivery route',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Ionicons.calendar_outline,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Schedule',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
              child: _buildDateTimeCard(
                icon: Ionicons.calendar_outline,
                title: 'Date',
                subtitle: _formatDate(_selectedDate),
                onTap: _selectDate,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
              child: _buildDateTimeCard(
                icon: Ionicons.time_outline,
                title: 'Time',
                subtitle: _formatTime(_selectedTime),
                onTap: _selectTime,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isRequired = true,
  }) {
    final isSelected = subtitle != 'Select Date' && subtitle != 'Select Time';
    final hasError = isRequired && !isSelected;
    final isInPast = _isDateTimeInPast;
    
    return GestureDetector(
      onTap: _isCreating ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError 
                ? AppTheme.errorColor 
                : isInPast
                    ? AppTheme.warningColor
                    : isSelected 
                        ? AppTheme.primaryColor
                        : AppTheme.borderColor,
            width: hasError || isInPast || isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: hasError 
                  ? AppTheme.errorColor.withOpacity(0.1)
                  : isInPast
                      ? AppTheme.warningColor.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasError 
                    ? AppTheme.errorColor.withOpacity(0.1)
                    : isInPast
                        ? AppTheme.warningColor.withOpacity(0.1)
                        : isSelected 
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: hasError 
                    ? AppTheme.errorColor
                    : isInPast
                        ? AppTheme.warningColor
                        : isSelected 
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: hasError 
                    ? AppTheme.errorColor
                    : isInPast
                        ? AppTheme.warningColor
                        : AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasError) ...[
              const SizedBox(height: 4),
              Text(
                'Required',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else if (isInPast) ...[
              const SizedBox(height: 4),
              Text(
                'Cannot be in the past',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.warningColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSection(List<Vehicle> availableVehicles) {
    return Column(
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
              'Vehicle Selection',
              style: AppTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
        const SizedBox(height: 16),
        
        if (availableVehicles.isEmpty)
          _buildEmptyVehiclesCard()
        else
          _buildVehiclesList(availableVehicles),
      ],
    );
  }

  Widget _buildEmptyVehiclesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Ionicons.car_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No vehicles available',
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please add vehicles to the system first',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesList(List<Vehicle> vehicles) {
    return Column(
      children: vehicles.map((vehicle) {
        final isSelected = _selectedVehicle?.id == vehicle.id;
        final hasError = _selectedVehicle == null;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: _isCreating ? null : () {
              setState(() {
                _selectedVehicle = isSelected ? null : vehicle;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected 
                      ? AppTheme.primaryColor
                      : hasError 
                          ? AppTheme.errorColor.withOpacity(0.5)
                          : AppTheme.borderColor,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Ionicons.car_sport_outline,
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.plateNumber,
                          style: AppTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected ? AppTheme.primaryColor : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vehicle.driverName,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildVehicleInfo(
                              icon: Ionicons.scale_outline,
                              label: '${vehicle.capacity.toStringAsFixed(1)} kg',
                            ),
                            const SizedBox(width: 16),
                            _buildVehicleInfo(
                              icon: Ionicons.cube_outline,
                              label: '${vehicle.volumeCapacity.toStringAsFixed(1)} m³',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? AppTheme.primaryColor
                            : hasError 
                                ? AppTheme.errorColor.withOpacity(0.5)
                                : AppTheme.borderColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isSelected 
                          ? Ionicons.checkmark
                          : Ionicons.add,
                      color: isSelected 
                          ? Colors.white 
                          : hasError 
                              ? AppTheme.errorColor.withOpacity(0.5)
                              : AppTheme.textSecondary,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVehicleInfo({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Ionicons.information_circle_outline,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Steps',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'After creating the trip, you can assign orders and start the delivery process.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    final isFormValid = _isFormValid;
    final isDateTimeInPast = _isDateTimeInPast;
    
    return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
        onPressed: _isCreating || !isFormValid ? null : _createTrip,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid 
              ? AppTheme.primaryColor 
              : isDateTimeInPast
                  ? AppTheme.warningColor.withOpacity(0.3)
                  : AppTheme.primaryColor.withOpacity(0.3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
                      child: _isCreating
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                  width: 20,
                  height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                SizedBox(width: 12),
                Text(
                  'Creating Trip...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isFormValid 
                      ? Ionicons.add_circle_outline 
                      : isDateTimeInPast
                          ? Ionicons.time_outline
                          : Ionicons.alert_circle_outline, 
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isFormValid 
                      ? 'Create Trip' 
                      : isDateTimeInPast
                          ? 'Select Future Date/Time'
                          : 'Complete All Fields',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  // Helper methods
  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date';
    
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

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select Time';
    
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}