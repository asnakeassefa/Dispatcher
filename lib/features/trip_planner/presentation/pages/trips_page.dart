import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entity/trip.dart';
import '../bloc/trip_planner_cubit.dart';
import '../bloc/trip_planner_state.dart';
import '../widgets/trip_card.dart';
import 'create_trip_page.dart';
import 'trip_detail_page.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TripStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<TripPlannerCubit>().loadTrips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _onStatusFilterChanged(TripStatus? status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  List<Trip> _filterTrips(List<Trip> trips) {
    var filteredTrips = trips;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredTrips = filteredTrips.where((trip) {
        return trip.id.toLowerCase().contains(_searchQuery) ||
               (trip.assignedVehicle?.plateNumber.toLowerCase().contains(_searchQuery) ?? false) ||
               (trip.assignedVehicle?.driverName.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    // Filter by status
    if (_selectedStatus != null) {
      filteredTrips = filteredTrips.where((trip) => trip.status == _selectedStatus).toList();
    }

    return filteredTrips;
  }

  Future<void> _refreshTrips() async {
    await context.read<TripPlannerCubit>().refreshTrips();
  }

  void _navigateToCreateTrip() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<TripPlannerCubit>(),
          child: const CreateTripPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trip Planner',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTrips,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomTextField(
                controller: _searchController,
                isObscure: false,
                headerText: '',
                hintText: 'Search by trip ID, vehicle, driver...',
                prefixIcon: Ionicons.search,
                keyboardType: TextInputType.text,
                maxLines: 1,
                onChanged: _onSearchChanged,
                validator: (value) => null,
              ),
            ),
            const Divider(height: 1, color: Colors.grey),

            // Status filter chips
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip(context, 'All', null),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Planned', TripStatus.planned),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'In Progress', TripStatus.inProgress),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Completed', TripStatus.completed),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Cancelled', TripStatus.cancelled),
                ],
              ),
            ),

            // Trips list
            Expanded(
              child: BlocBuilder<TripPlannerCubit, TripPlannerState>(
                builder: (context, state) {
                  if (state is TripPlannerLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is TripPlannerError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Ionicons.alert_circle,
                            size: 64,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading trips',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshTrips,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is TripPlannerLoaded) {
                    final filteredTrips = _filterTrips(state.trips);

                    if (filteredTrips.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Ionicons.car_outline,
                              size: 64,
                              color: AppTheme.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty || _selectedStatus != null
                                  ? 'No trips found'
                                  : 'No trips yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty || _selectedStatus != null
                                  ? 'Try adjusting your search or filters'
                                  : 'Create your first trip to get started',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_searchQuery.isEmpty && _selectedStatus == null) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _navigateToCreateTrip,
                                icon: const Icon(Icons.add),
                                label: const Text('Create Trip'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refreshTrips,
                      child: ListView.builder(
                        itemCount: filteredTrips.length,
                        itemBuilder: (context, index) {
                          final trip = filteredTrips[index];
                          return TripCard(
                            trip: trip,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TripDetailPage(tripId: trip.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const Center(
                    child: Text('Unknown state'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTrip,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, TripStatus? status) {
    final isSelected = _selectedStatus == status;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _onStatusFilterChanged(selected ? status : null);
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }
}

