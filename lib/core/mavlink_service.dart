import 'dart:async';

import 'package:comm_module/comm_module.dart';
import 'package:mavlink_nrt/mavlink.dart';

class MavlinkService {
  final Transport transport;
  final MavlinkParser parser;

  final _frameController = StreamController<MavlinkFrame>.broadcast();

  Stream<MavlinkFrame> get stream => _frameController.stream;

  Stream<T> messagesOf<T extends MavlinkMessage>() {
    return stream
        .map((f) => f.message)
        .where((m) => m is T)
        .cast<T>();
  }

  int _seq = 0;
  StreamSubscription<List<int>>? _transportSub;
  StreamSubscription<MavlinkFrame>? _parserSub;

  MavlinkService({
    required this.transport,
    required this.parser,
  });

  void init() {
    _transportSub = transport.onData.listen((data) {
      parser.parse(data);
    });

    _parserSub = parser.stream.listen((frame) {
      _frameController.add(frame);
    });
  }

  Future<void> send(MavlinkMessage message) {
    final frame = MavlinkFrame.v2(
      _nextSeq(),
      255, // system id (consider injecting if variable)
      157, // component id (consider injecting if variable)
      message,
    );

    print("Sent frames: ${frame.serialize()}");
    return transport.send(frame.serialize());
  }

  int _nextSeq() => _seq = (_seq + 1) & 0xFF;

  Future<void> dispose() async {
    await _transportSub?.cancel();
    await _parserSub?.cancel();
    await _frameController.close();
  }
}