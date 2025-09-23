import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/di/injection.dart';
import 'core/database/app_database.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize HydratedBloc storage FIRST (before any HydratedCubit is created)
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  
  // Initialize dependency injection AFTER HydratedStorage
  await configureInjection("prod");
  
  // Initialize database
  final database = getIt<AppDatabase>();
  await database.customStatement('PRAGMA foreign_keys = ON');
  
  runApp(const MyApp());
}