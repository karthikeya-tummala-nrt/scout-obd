import 'dart:math' as math;

import 'package:flutter/material.dart';

class HudSidebar extends StatelessWidget {
  const HudSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  static const _steel = Color(0xFF93A9B5);

  static Color _a(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        if (w <= 0 || h <= 0) return const SizedBox.shrink();

        final s = math.min(w, h);
        final m = s * 0.03;

        final outer = Rect.fromLTWH(m, m, w - 2 * m, h - 2 * m);
        final outer2 = outer.deflate(s * 0.007);

        final rect = outer2;

        final panelLeft = rect.left + rect.width * 0.032;
        final panelTop = rect.top + rect.height * 0.140;
        final panelH = rect.height * 0.79;

        final desiredSlotCount = 8;
        final gap = math.max(panelH * 0.028, 6.0);
        const minSlotH = 18.0;

        final maxCount = ((panelH - gap) / (minSlotH + gap)).floor();
        final slotCount = math.max(1, math.min(desiredSlotCount, maxCount));
        final slotH = math.max(
          0.0,
          (panelH - gap * (slotCount + 1)) / slotCount,
        );

        final horizontalPad = (slotH * 0.35).clamp(10.0, 22.0).toDouble();

        final maxSlotW = rect.width * 0.18;
        final minSlotW = math.min(90.0, maxSlotW);
        final targetSlotW = (rect.width * 0.13)
            .clamp(minSlotW, maxSlotW)
            .toDouble();

        final maxPanelW = rect.width * 0.22;
        final minPanelW = math.min(110.0, maxPanelW);
        final panelW = (targetSlotW + 2 * horizontalPad)
            .clamp(minPanelW, maxPanelW)
            .toDouble();

        final slotW = math.max(0.0, panelW - 2 * horizontalPad);
        final slotX = panelLeft + (panelW - slotW) / 2;

        final borderR = Radius.circular(rect.width * 0.014);

        final visibleItemCount = math.min(items.length, slotCount);

        return Stack(
          children: [
            Positioned(
              left: panelLeft,
              top: panelTop,
              width: panelW,
              height: panelH,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(borderR),
                  border: Border.all(color: _a(_steel, 0.22), width: 1),
                ),
                child: Stack(
                  children: [
                    for (var i = 0; i < slotCount; i++)
                      Positioned(
                        left: slotX - panelLeft,
                        top: gap + i * (slotH + gap),
                        width: slotW,
                        height: slotH,
                        child: _HudSidebarItem(
                          // label: i < visibleItemCount ? items[i] : '',
                          // Hidden for now; re-enable when you want labels back.
                          label: '',
                          selected: i == selectedIndex,
                          enabled: i < visibleItemCount,
                          onTap: i < visibleItemCount
                              ? () => onSelect(i)
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HudSidebarItem extends StatelessWidget {
  const _HudSidebarItem({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  static const _cyan = Color(0xFF2FD0FF);
  static const _cyanSoft = Color(0xFF8BE9FF);
  static const _steel = Color(0xFF93A9B5);

  static Color _a(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }

  @override
  Widget build(BuildContext context) {
    final bg = selected ? _a(_cyan, 0.10) : Colors.transparent;
    final border = selected ? _a(_cyan, 0.85) : _a(_cyan, 0.65);
    final glow = selected ? _a(_cyan, 0.55) : _a(_cyan, 0.35);

    final textColor = selected ? _a(_cyanSoft, 0.95) : _a(_cyanSoft, 0.75);

    final child = LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final radius = (h * 0.18).clamp(6.0, 22.0).toDouble();

        return DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: enabled ? border : _a(_steel, 0.18),
              width: 1.3,
            ),
            boxShadow: enabled
                ? [BoxShadow(color: glow, blurRadius: 10, spreadRadius: 1)]
                : const [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: enabled ? textColor : _a(_steel, 0.40),
                    fontSize: 12,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!enabled) return IgnorePointer(child: child);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
