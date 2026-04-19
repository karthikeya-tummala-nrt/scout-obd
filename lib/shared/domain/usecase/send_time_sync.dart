import 'package:scout_display/shared/domain/repositories/time_sync_repository.dart';

class SendTimeSyncRequest {
  final TimeSyncRepository repo;

  SendTimeSyncRequest(this.repo);

  Future<void> call() => repo.sendRequest();
}