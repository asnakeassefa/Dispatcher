import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/state/app_state_manager.dart';
import 'features/order/presentation/bloc/order_cubit.dart';
import 'features/order/presentation/pages/order_page.dart';
import 'features/trip_planner/presentation/bloc/trip_planner_cubit.dart';
import 'features/trip_planner/presentation/pages/trips_page.dart';
import 'features/trip_execution/presentation/bloc/trip_execution_cubit.dart';
import 'core/services/navigation_restoration_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppStateManager>(
          create: (context) => getIt<AppStateManager>(),
        ),
        BlocProvider<OrderCubit>(
          create: (context) => getIt<OrderCubit>(),
        ),
        BlocProvider<TripPlannerCubit>(
          create: (context) => getIt<TripPlannerCubit>(),
        ),
        BlocProvider<TripExecutionCubit>(
          create: (context) => getIt<TripExecutionCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Dispatcher',
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late PageController _pageController;
  bool _hasRestoredNavigation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize page controller with saved state
    final savedTabIndex = context.read<AppStateManager>().state.currentTabIndex;
    _pageController = PageController(initialPage: savedTabIndex);
    
    // Load saved data for all cubits
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedStates();
      _restoreDetailPages();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Save current page state when app goes to background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _saveCurrentState();
    }
  }

  void _loadSavedStates() {
    // Load orders
    context.read<OrderCubit>().loadOrdersWithCustomers();
    
    // Load trips
    context.read<TripPlannerCubit>().loadTrips();
    
    // Restore any ongoing trip execution
    final currentTripExecutionId = context.read<AppStateManager>().state.currentTripExecutionId;
    if (currentTripExecutionId != null) {
      // Load the specific trip execution
      context.read<TripExecutionCubit>().refreshTripExecution(currentTripExecutionId);
    }
  }

  void _restoreDetailPages() async {
    if (_hasRestoredNavigation) return;
    _hasRestoredNavigation = true;

    final appStateManager = context.read<AppStateManager>();
    final navigationService = getIt<NavigationRestorationService>();
    
    await navigationService.restoreNavigationState(context, appStateManager);
  }

  void _saveCurrentState() {
    final currentIndex = _pageController.hasClients 
        ? _pageController.page?.round() ?? 0 
        : 0;
    
    context.read<AppStateManager>().updateTabIndex(currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppStateManager, AppStateData>(
      listener: (context, state) {
        // React to app state changes
        if (_pageController.hasClients && _pageController.page?.round() != state.currentTabIndex) {
          _pageController.animateToPage(
            state.currentTabIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      builder: (context, appState) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              context.read<AppStateManager>().updateTabIndex(index);
            },
            children: const [
              OrderPage(),
              TripsPage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: appState.currentTabIndex,
            onTap: (index) {
              context.read<AppStateManager>().updateTabIndex(index);
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping),
                label: 'Trips',
              ),
            ],
          ),
        );
      },
    );
  }
}
