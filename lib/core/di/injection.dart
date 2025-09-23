import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart' as injectable;

import 'injection.config.dart';

final getIt = GetIt.instance;

@injectable.injectableInit
Future<void> configureInjection(String environment) async {
  getIt.init(environment: environment);
}
