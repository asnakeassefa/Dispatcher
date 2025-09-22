import 'package:injectable/injectable.dart' as injectable;

import '../database/app_database.dart';

@injectable.module
abstract class DatabaseModule {
  @injectable.singleton
  AppDatabase get appDatabase => AppDatabase();
}
