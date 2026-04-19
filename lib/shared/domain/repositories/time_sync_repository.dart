import 'package:scout_display/shared/domain/models/time_sync.dart';

abstract class TimeSyncRepository {
  Stream<TimeSync> get stream;

  Future<void> sendRequest();
}