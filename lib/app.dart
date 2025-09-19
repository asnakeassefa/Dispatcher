import 'package:flutter/material.dart';
import 'core/flavor/flavor.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dispatcher (${FlavorConfig.instance.name})'),
        ),
        body: Center(
          child: Text('Base URL: ${FlavorConfig.instance.baseUrl}'),
        ),
      ),
    );
  }
}


