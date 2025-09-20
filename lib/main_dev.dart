import 'package:dispatcher/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'app.dart';
import 'core/flavor/flavor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AppFlavor flavor = AppFlavor.development;
  const String baseUrl = 'https://api.dev.example.com';

  FlavorConfig.initialize(flavor: flavor, name: 'DEV', baseUrl: baseUrl);
  await configureInjection(flavor.name);
  runApp(const MyApp());
}
