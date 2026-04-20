import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scout_display/core/providers.dart';
import 'package:scout_display/core/utils/date_time_format.dart';

class HudDateTimeLabel extends ConsumerWidget {
  const HudDateTimeLabel({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tickerProvider).value;

    final offsetMicros = ref.watch(timeStateProvider).offsetMicros;
    final now = DateTime.now().microsecondsSinceEpoch;
    final corrected = DateTime.fromMicrosecondsSinceEpoch(now + offsetMicros);

    final h = height;
    final fontSize = (h * 0.44).clamp(10.0, 18.0);

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        formatDdMmYyyyHm(corrected),
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