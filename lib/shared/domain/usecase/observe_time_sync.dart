import 'package:scout_display/shared/domain/models/time_sync.dart';
import 'package:scout_display/shared/domain/repositories/time_sync_repository.dart';

class ObserveTimeSync {
  final TimeSyncRepository repo;

  ObserveTimeSync(this.repo);

  Stream<TimeSync> call() => repo.stream;
}