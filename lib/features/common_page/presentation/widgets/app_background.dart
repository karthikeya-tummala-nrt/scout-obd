import 'package:flutter/material.dart';

import 'hud_frame_overlay.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  static const String assetPath = 'assets/backgrounds/Background.png';

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Image.asset(
              assetPath,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const Positioned.fill(child: HudFrameOverlay()),
        child,
      ],
    );
  }
}
