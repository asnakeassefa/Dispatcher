import 'package:injectable/injectable.dart' as injectable;

import '../entity/stop.dart';
import '../repository/trip_execution_repository.dart';

@injectable.injectable
class CompleteStopUseCase {
  final TripExecutionRepository _repository;

  CompleteStopUseCase(this._repository);

  Future<Stop> call(String stopId, {String? notes, Map<String, Map<String, dynamic>>? codData}) async {
    if (stopId.isEmpty) {
      throw Exception('Stop ID cannot be empty');
    }

    return await _repository.completeStop(stopId, notes: notes, codData: codData);
  }
}