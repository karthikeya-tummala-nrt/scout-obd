import 'package:flutter/material.dart';

class HudBatteryStatusIcon extends StatelessWidget {
  const HudBatteryStatusIcon({super.key, required this.size, this.level = 1.0});

  final double size;
  final double level;

  @override
  Widget build(BuildContext context) {
    final h = size;
    final unit = h / 20.0;
    final w = 40.0 * unit;
    final clampedLevel = level.clamp(0.0, 1.0);

    var batteryColor = Colors.green;
    if (clampedLevel < 0.2) {
      batteryColor = Colors.red;
    } else if (clampedLevel < 0.5) {
      batteryColor = Colors.orange;
    }

    final borderW = 2.0 * unit;
    final borderRadius = 3.0 * unit;
    final inset = 1.0 * unit;
    final fillRadius = 1.0 * unit;

    final terminalW = 3.0 * unit;
    final terminalH = 8.0 * unit;
    final terminalTop = 6.0 * unit;
    final terminalRadius = 2.0 * unit;

    final fillMaxW = 36.0 * unit;
    final fillW = (fillMaxW * clampedLevel).clamp(0.0, fillMaxW);

    return SizedBox(
      width: w + terminalW,
      height: h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: borderW),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: inset,
                  top: inset,
                  bottom: inset,
                  child: Container(
                    width: fillW,
                    decoration: BoxDecoration(
                      color: batteryColor,
                      borderRadius: BorderRadius.circular(fillRadius),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -terminalW,
            top: terminalTop,
            child: Container(
              width: terminalW,
              height: terminalH,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(terminalRadius),
                  bottomRight: Radius.circular(terminalRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
