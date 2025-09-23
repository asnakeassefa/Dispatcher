import 'package:dispatcher/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'features/order/presentation/bloc/order_cubit.dart';
import 'features/order/presentation/bloc/order_state.dart';
import 'features/trip_planner/presentation/bloc/trip_planner_cubit.dart';
import 'features/trip_planner/presentation/bloc/trip_planner_state.dart';
import 'features/trip_execution/presentation/bloc/trip_execution_cubit.dart';
import 'features/trip_execution/presentation/bloc/trip_execution_state.dart';
import 'features/trip_planner/presentation/pages/trips_page.dart';
import 'features/order/presentation/pages/order_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
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
        home: const MainNavigationPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TripsPage(),
    const OrderPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}
