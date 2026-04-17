import 'package:flutter/material.dart';

class HudLinkStatusIcon extends StatelessWidget {
  const HudLinkStatusIcon({super.key, required this.size, this.connected});

  final double size;
  final bool? connected;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color base, Color glow) = switch (connected) {
      null => (
        Icons.link_rounded,
        const Color(0xFF2FD0FF),
        const Color(0xFF8BE9FF),
      ),
      true => (
        Icons.link_rounded,
        const Color(0xFF36FF7A),
        const Color(0xFF00FF66),
      ),
      false => (
        Icons.link_off_rounded,
        const Color(0xFFFF3B3B),
        const Color(0xFFFF2A2A),
      ),
    };

    return Icon(
      icon,
      size: size,
      color: base,
      shadows: [
        Shadow(color: glow, blurRadius: size * 0.55, offset: Offset.zero),
        Shadow(color: glow, blurRadius: size * 0.25, offset: Offset.zero),
      ],
    );
  }
}
