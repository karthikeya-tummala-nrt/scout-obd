import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comm_module/transport/udp_transport.dart';
import 'package:mavlink_nrt/dialects/ardupilotmega.dart';
import 'package:mavlink_nrt/mavlink.dart';

import 'package:scout_display/core/mavlink_service.dart';
import 'package:scout_display/shared/data/repositories/time_sync_repository_impl.dart';

final transportProvider = Provider<UdpTransport>((ref) {

  final transport = UdpTransport(
    address: InternetAddress.anyIPv4,
    port: 7500,
    remoteAddress: InternetAddress("172.17.0.2"),
    remotePort: 7500,
  );

  transport.connect();

  transport.onData.listen((data) {
    print("RX BYTES[Transport]: $data");
  });
  return transport;
});

final parserProvider = Provider<MavlinkParser>((ref) {
  return MavlinkParser(MavlinkDialectArdupilotmega());
});

final mavlinkServiceProvider = Provider<MavlinkService>((ref) {

  final service = MavlinkService(
    transport: ref.read(transportProvider),
    parser: ref.read(parserProvider),
  )..init();

  return service;
});

final timeSyncRepoProvider = Provider<void>((ref) {
  final repo = TimeSyncRepositoryImpl(
    ref.read(mavlinkServiceProvider),
    ref.read(timeNowProvider),
  );

  ref.onDispose(repo.dispose);

  repo.stream.listen((sync) {
    ref.read(timeStateProvider.notifier)
        .setOffset(sync.offset);
  });

  Timer.run(() => repo.sendRequest()); // Fire timesync request once to avoid 10 seconds delay

  return null;
});

final timeNowProvider = Provider<int Function()>((ref) {
  return () => DateTime.now().microsecondsSinceEpoch;
});

class TimeState {
  final int offsetMicros;

  const TimeState({required this.offsetMicros});
}

class TimeStateNotifier extends Notifier<TimeState> {
  @override
  TimeState build() {
    return const TimeState(offsetMicros: 0);
  }

  void setOffset(int offsetMicros) {
    state = TimeState(offsetMicros: offsetMicros);
  }
}

final timeStateProvider =
NotifierProvider<TimeStateNotifier, TimeState>(
  TimeStateNotifier.new,
);

final tickerProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i);
});