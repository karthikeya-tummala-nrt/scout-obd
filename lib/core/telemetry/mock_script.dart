import 'dart:collection';

/// TIMESYNC message
class MsgTimesync {
  int tc1; // echoed client timestamp (used in response)
  int ts1; // sender timestamp

  MsgTimesync({required this.tc1, required this.ts1});
}

/// Get current time in microseconds (used by both client and server)
int nowMicros() => DateTime.now().microsecondsSinceEpoch;

/// SERVER SIDE

class TimesyncServer {
  final int clockOffsetMicros; // simulated offset from client clock

  TimesyncServer({required this.clockOffsetMicros});

  /// Server clock = client clock + offset
  int get serverTime => nowMicros() + clockOffsetMicros;

  /// Server receives request and sends response
  Future<MsgTimesync> handle(MsgTimesync msg) async {
    // msg.ts1 contains client timestamp (t0)

    return MsgTimesync(
      tc1: msg.ts1,     // echo back client timestamp
      ts1: serverTime,  // include server timestamp (t1)
    );
  }
}

/// CLIENT SIDE
class TimesyncClient {
  final Queue<double> _offsets = Queue();
  final int maxSamples;

  TimesyncClient({this.maxSamples = 20});

  Future<Map<String, double>> sync(TimesyncServer server) async {
    // Step 1: Client sends request
    int t0 = nowMicros(); // client send time

    MsgTimesync req = MsgTimesync(
      tc1: 0,
      ts1: t0,
    );

    // Simulated send to server
    MsgTimesync resp = await server.handle(req);

    // Step 2: Client receives response
    int t2 = nowMicros(); // client receive time

    // Extract timestamps
    double clientSent = req.ts1.toDouble();  // t0
    double serverTime = resp.ts1.toDouble(); // t1

    // Step 3: Calculate round-trip time
    double rtt = (t2 - t0).toDouble();

    // Step 4: Estimate clock offset
    double offset = (serverTime - clientSent) - (rtt / 2.0);

    // Store values for smoothing
    _offsets.add(offset);
    if (_offsets.length > maxSamples) {
      _offsets.removeFirst();
    }

    // Step 5: Compute average offset
    double smoothed =
        _offsets.reduce((a, b) => a + b) / _offsets.length;

    return {
      "offset": offset,
      "rtt": rtt,
      "smoothedOffset": smoothed,
    };
  }
}

/// ----------------------
/// MAIN EXECUTION
/// ----------------------
Future<void> main() async {
  final server = TimesyncServer(clockOffsetMicros: 120000);
  final client = TimesyncClient();

  print("MAVLink TIMESYNC v2 simulation (NO DELAY)\n");

  for (int i = 1; i <= 30; i++) {
    // Client initiates sync
    final result = await client.sync(server);

    // Print results
    print(
      "Sample ${i.toString().padLeft(2, '0')} | "
      "RTT: ${(result["rtt"]! / 1000).toStringAsFixed(3)} ms | "
      "Offset: ${(result["offset"]! / 1000).toStringAsFixed(3)} ms | "
      "Smoothed: ${(result["smoothedOffset"]! / 1000).toStringAsFixed(3)} ms",
    );

    await Future.delayed(Duration(milliseconds: 100));
  }
}