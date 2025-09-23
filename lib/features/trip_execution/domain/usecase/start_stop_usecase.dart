import 'package:injectable/injectable.dart' as injectable;

import '../entity/stop.dart';
import '../repository/trip_execution_repository.dart';

@injectable.injectable
class StartStopUseCase {
  final TripExecutionRepository _repository;

  StartStopUseCase(this._repository);

  Future<Stop> call(String stopId) async {
    if (stopId.isEmpty) {
      throw Exception('Stop ID cannot be empty');
    }

    return await _repository.startStop(stopId);
  }
}