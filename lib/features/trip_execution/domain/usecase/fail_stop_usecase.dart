import 'package:injectable/injectable.dart' as injectable;

import '../entity/stop.dart';
import '../repository/trip_execution_repository.dart';

@injectable.injectable
class FailStopUseCase {
  final TripExecutionRepository _repository;

  FailStopUseCase(this._repository);

  Future<Stop> call(String stopId, {required String reason, String? notes}) async {
    if (stopId.isEmpty) {
      throw Exception('Stop ID cannot be empty');
    }

    if (reason.isEmpty) {
      throw Exception('Failure reason cannot be empty');
    }

    return await _repository.failStop(stopId, reason: reason, notes: notes);
  }
}
