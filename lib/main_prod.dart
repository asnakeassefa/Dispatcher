import 'package:dispatcher/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'app.dart';
import 'core/flavor/flavor.dart';

void main() async {
  const AppFlavor flavor = AppFlavor.production;
  WidgetsFlutterBinding.ensureInitialized();
  const String baseUrl = 'https://api.example.com';

  FlavorConfig.initialize(flavor: flavor, name: 'PROD', baseUrl: baseUrl);
  await configureInjection(flavor.name);
  runApp(const MyApp());
}


