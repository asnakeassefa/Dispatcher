import 'package:flutter/material.dart';
import 'app.dart';
import 'core/flavor/flavor.dart';

void main() {
  const AppFlavor flavor = AppFlavor.production;
  const String baseUrl = 'https://api.example.com';

  FlavorConfig.initialize(flavor: flavor, name: 'PROD', baseUrl: baseUrl);

  runApp(const MyApp());
}


