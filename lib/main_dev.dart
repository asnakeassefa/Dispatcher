import 'package:flutter/material.dart';
import 'app.dart';
import 'core/flavor/flavor.dart';

void main() {
  const AppFlavor flavor = AppFlavor.development;
  const String baseUrl = 'https://api.dev.example.com';

  FlavorConfig.initialize(flavor: flavor, name: 'DEV', baseUrl: baseUrl);

  runApp(const MyApp());
}
