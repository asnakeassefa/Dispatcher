import 'package:dispatcher/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'features/order/presentation/pages/order_detail_page.dart';
import 'features/order/presentation/pages/order_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: OrderDetailPage(),
    );
  }
}
