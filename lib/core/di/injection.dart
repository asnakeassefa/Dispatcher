import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' as injectable;

import '../state/app_state_manager.dart';
import '../services/navigation_restoration_service.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@injectable.injectableInit
Future<void> configureInjection(String environment) async {
  getIt.init(environment: environment);
  
  // Manually register services that might not be auto-generated yet
  if (!getIt.isRegistered<AppStateManager>()) {
    getIt.registerSingleton<AppStateManager>(AppStateManager());
  }
  
  if (!getIt.isRegistered<NavigationRestorationService>()) {
    getIt.registerSingleton<NavigationRestorationService>(NavigationRestorationService());
  }
}