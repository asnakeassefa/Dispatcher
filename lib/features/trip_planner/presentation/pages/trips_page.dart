import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/filter_chip_button.dart';
import '../../domain/entity/trip.dart';
import '../bloc/trip_planner_cubit.dart';
import '../bloc/trip_planner_state.dart';
import '../widgets/trip_card.dart';
import 'create_trip_page.dart';
import 'trip_detail_page.dart';
import '../../../../core/state/app_state_manager.dart';

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
    // Load trips when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripPlannerCubit>().loadTrips();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load trips when the page becomes visible
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
    return trips.where((trip) {
      final matchesSearch = _searchQuery.isEmpty ||
          trip.id.toLowerCase().contains(_searchQuery) ||
          trip.assignedVehicle?.plateNumber.toLowerCase().contains(_searchQuery) == true;
      
      final matchesStatus = _selectedStatus == null || trip.status == _selectedStatus;
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _navigateToTripDetail(String tripId) {
    // Save detail page state
    context.read<AppStateManager>().updateDetailPage(
      DetailPageType.tripDetail,
      tripId: tripId,
    );
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TripDetailPage(tripId: tripId),
      ),
    ).then((_) {
      // Clear detail page state when returning
      context.read<AppStateManager>().updateDetailPage(DetailPageType.none);
      context.read<TripPlannerCubit>().loadTrips();
    });
  }

  void _navigateToCreateTrip() {
    // Save detail page state
    context.read<AppStateManager>().updateDetailPage(DetailPageType.createTrip);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<TripPlannerCubit>(),
          child: const CreateTripPage(),
        ),
      ),
    ).then((_) {
      // Clear detail page state when returning
      context.read<AppStateManager>().updateDetailPage(DetailPageType.none);
      context.read<TripPlannerCubit>().loadTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
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
      body: BlocConsumer<TripPlannerCubit, TripPlannerState>(
        listener: (context, state) {
          if (state is TripPlannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TripPlannerLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading trips...'),
                ],
              ),
            );
          }

          if (state is TripPlannerLoaded) {
            final filteredTrips = _filterTrips(state.trips);
            
            return Column(
              children: [
                // Search and filter section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search bar
                      CustomTextField(
                        controller: _searchController,
                        hintText: 'Search trips...',
                        prefixIcon: Icons.search,
                        onChanged: _onSearchChanged,
                        isObscure: false,
                        headerText: 'Search trips...',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            TripFilterChip(
                              label: 'All Trips',
                              isSelected: _selectedStatus == null,
                              onTap: () => _onStatusFilterChanged(null),
                              status: null,
                            ),
                            const SizedBox(width: 12),
                            TripFilterChip(
                              label: 'Planned',
                              isSelected: _selectedStatus == TripStatus.planned,
                              onTap: () => _onStatusFilterChanged(TripStatus.planned),
                              status: TripStatus.planned,
                            ),
                            const SizedBox(width: 12),
                            TripFilterChip(
                              label: 'Active',
                              isSelected: _selectedStatus == TripStatus.inProgress,
                              onTap: () => _onStatusFilterChanged(TripStatus.inProgress),
                              status: TripStatus.inProgress,
                            ),
                            const SizedBox(width: 12),
                            TripFilterChip(
                              label: 'Completed',
                              isSelected: _selectedStatus == TripStatus.completed,
                              onTap: () => _onStatusFilterChanged(TripStatus.completed),
                              status: TripStatus.completed,
                            ),
                            const SizedBox(width: 12),
                            TripFilterChip(
                              label: 'Cancelled',
                              isSelected: _selectedStatus == TripStatus.cancelled,
                              onTap: () => _onStatusFilterChanged(TripStatus.cancelled),
                              status: TripStatus.cancelled,
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Trips list
                Expanded(
                  child: filteredTrips.isEmpty
                      ? Center(
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
                                'No trips found',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isNotEmpty || _selectedStatus != null
                                    ? 'Try adjusting your search or filter'
                                    : 'Create your first trip to get started',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredTrips.length,
                          itemBuilder: (context, index) {
                            final trip = filteredTrips[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TripCard(
                                trip: trip,
                                onTap: () {
                                  _navigateToTripDetail(trip.id);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('No trip data available'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToCreateTrip();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

