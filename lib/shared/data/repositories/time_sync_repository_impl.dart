import 'dart:async';

import 'package:mavlink_nrt/dialects/ardupilotmega.dart';
import 'package:scout_display/core/mavlink_service.dart';
import 'package:scout_display/shared/domain/models/time_sync.dart';
import 'package:scout_display/shared/domain/repositories/time_sync_repository.dart';

class TimeSyncRepositoryImpl implements TimeSyncRepository {
  final MavlinkService _service;
  final int Function() _now;

  late final StreamSubscription<Timesync> _sub;
  late final Timer _timer;

  final _controller = StreamController<TimeSync>.broadcast();

  int? _t1;

  TimeSyncRepositoryImpl(
      this._service,
      this._now,
      ) {
    _sub = _service.messagesOf<Timesync>().listen(_handleTimesync);

    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      sendRequest();
    });
  }

  @override
  Stream<TimeSync> get stream => _controller.stream;

  void _handleTimesync(Timesync msg) {
    print('''
[TIMESYNC RAW MSG]
tc1: ${msg.tc1}
ts1: ${msg.ts1}
targetSystem: ${msg.targetSystem}
targetComponent: ${msg.targetComponent}
''');
    final now = _now();

    // request → reply
    if (msg.tc1 == 0) {
      _service.send(
        Timesync(
          tc1: msg.ts1,
          ts1: now,
          targetSystem: 0,
          targetComponent: 0,
        ),
      );
      return;
    }

    // response → compute
    if (_t1 != null) {
      final t3 = now;
      final t2 = msg.tc1;

      final offset = t2 - ((_t1! + t3) ~/ 2);
      final rtt = t3 - _t1!;

      _controller.add(TimeSync(offset: offset, rtt: rtt));
    }
  }

  @override
  Future<void> sendRequest() async {
    _t1 = _now();

    print("Sent timestamp: $_t1");

    await _service.send(
      Timesync(
        tc1: 0,
        ts1: _t1!,
        targetSystem: 1,
        targetComponent: 191,
      ),
    );
  }

  Future<void> dispose() async {
    await _sub.cancel();
    await _controller.close();
  }
}