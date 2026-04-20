import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scout_display/core/utils/duration_format.dart';

class HudUptimeLabel extends StatefulWidget {
  const HudUptimeLabel({super.key, required this.height});

  final double height;

  @override
  State<HudUptimeLabel> createState() => _HudUptimeLabelState();
}

class _HudUptimeLabelState extends State<HudUptimeLabel> {
  late final Stopwatch _stopwatch;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    final fontSize = (h * 0.44).clamp(10.0, 18.0);

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        'UP TIME : ${formatHms(_stopwatch.elapsed)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          height: 1,
          decoration: TextDecoration.none,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 1)),
          ],
        ),
      ),
    );  }
}
