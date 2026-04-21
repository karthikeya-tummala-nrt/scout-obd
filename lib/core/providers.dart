import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comm_module/transport/udp_transport.dart';
import 'package:mavlink_nrt/dialects/ardupilotmega.dart';
import 'package:mavlink_nrt/mavlink.dart';
import 'package:scout_display/core/logger/logger.dart';

import 'package:scout_display/core/mavlink_service.dart';
import 'package:scout_display/shared/data/repositories/time_sync_repository_impl.dart';

final transportProvider = FutureProvider<UdpTransport>((ref) async {
  final logger = Logger('TransportProvider');

  final transport = UdpTransport(
    address: InternetAddress.anyIPv4,
    port: 7500,
    remoteAddress: InternetAddress("192.168.168.98"),
    remotePort: 7000,
  );

  // logger.i('Remote IP: $')

  await transport.connect();
  return transport;
});


final mavlinkServiceProvider = FutureProvider<MavlinkService>((ref) async {

  final transport = await ref.watch(transportProvider.future);

  final service = MavlinkService(
    transport: transport,
    parser: MavlinkParser(MavlinkDialectArdupilotmega()),
  )..init();

  return service;
});

final timeSyncRepoProvider = FutureProvider<void>((ref) async {
  final mavlinkService = await ref.watch(mavlinkServiceProvider.future);

  final repo = TimeSyncRepositoryImpl(
    mavlinkService,
    ref.read(timeNowProvider),
  );

  ref.onDispose(repo.dispose);

  repo.stream.listen((sync) {
    ref.read(timeStateProvider.notifier)
        .setOffset(sync.offset);
  });

  repo.sendRequest(); // Fire timesync request once to avoid 10 seconds delay

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