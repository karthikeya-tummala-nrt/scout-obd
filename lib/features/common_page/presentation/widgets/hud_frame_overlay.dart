import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hud_date_time_label.dart';
import 'hud_battery_status_icon.dart';
import 'hud_link_status_icon.dart';
import 'hud_mode_label.dart';
import 'hud_uptime_label.dart';

class HudFrameOverlay extends StatelessWidget {
  const HudFrameOverlay({super.key, this.modeText = 'MODE: SAFE HOLD'});

  final String modeText;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          if (w <= 0 || h <= 0) {
            return const SizedBox.shrink();
          }

          final s = math.min(w, h);
          final m = s * 0.03;
          final inset = s * 0.007;

          final rect = Rect.fromLTWH(
            m + inset,
            m + inset,
            w - 2 * (m + inset),
            h - 2 * (m + inset),
          );

          final thin = (s * 0.002).clamp(1.0, 2.5).toDouble();

          final innerInset = s * 0.03;
          final innerTop = rect.top + innerInset;

          final topY = innerTop - thin * 0.15;
          final labelH = (s * 0.088).clamp(30.0, 86.0).toDouble();

          final left = rect.left + innerInset;
          final maxWidth = rect.width * 0.52;

          return Stack(
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: _HudFramePainter(
                    labelTop: topY,
                    labelHeight: labelH,
                    labelLeft: left,
                    labelMaxWidth: maxWidth,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned(
                left: left,
                top: topY,
                child: SizedBox(
                  width: rect.right - rect.width * 0.055 - left,
                  height: labelH,
                  child: Row(
                    children: [
                      HudModeLabel(
                        text: modeText,
                        height: labelH,
                        maxWidth: maxWidth,
                      ),
                      SizedBox(width: (labelH * 0.22).clamp(8.0, 22.0)),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: HudUptimeLabel(height: labelH),
                                  ),
                                  SizedBox(
                                    width: (labelH * 0.65).clamp(16.0, 92.0),
                                  ),
                                  Flexible(
                                    child: HudDateTimeLabel(height: labelH),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: (labelH * 0.22).clamp(8.0, 22.0)),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    HudLinkStatusIcon(size: labelH * 0.7),
                                    SizedBox(
                                      width: (labelH * 0.18).clamp(8.0, 18.0),
                                    ),
                                    HudBatteryStatusIcon(size: labelH * 0.7),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HudFramePainter extends CustomPainter {
  const _HudFramePainter({
    required this.labelTop,
    required this.labelHeight,
    required this.labelLeft,
    required this.labelMaxWidth,
  });

  final double labelTop;
  final double labelHeight;
  final double labelLeft;
  final double labelMaxWidth;

  static const _cyan = Color(0xFF2FD0FF);
  static const _cyanSoft = Color(0xFF8BE9FF);
  static const _steel = Color(0xFF93A9B5);

  static Color _a(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final s = math.min(w, h);
    final m = s * 0.03;
    final r = s * 0.03;
    final thin = (s * 0.002).clamp(1.0, 2.5).toDouble();
    final mid = (s * 0.0035).clamp(1.5, 4.0).toDouble();
    final glow = (s * 0.008).clamp(6.0, 14.0).toDouble();

    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(m, m, w - 2 * m, h - 2 * m),
      Radius.circular(r),
    );

    final outer2 = outer.deflate(s * 0.007);
    final inner = outer2.deflate(s * 0.03);

    _strokeRRect(canvas, outer, strokeWidth: thin, color: _a(_steel, 0.35));

    _glowRRect(
      canvas,
      outer2,
      strokeWidth: mid,
      glowWidth: glow,
      shaderRect: outer2.outerRect,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_a(_cyanSoft, 0.2), _a(_cyan, 0.85), _a(_cyanSoft, 0.15)],
      ),
    );

    _strokeRRect(canvas, inner, strokeWidth: thin, color: _a(_steel, 0.22));

    _topHeader(canvas, outer2, thin, mid, glow);
    _sideAccents(canvas, outer2, thin, mid, glow);
    _leftSlots(canvas, outer2, thin, mid, glow);
    _bottomNotch(canvas, outer2, thin, mid, glow);
  }

  void _topHeader(
    Canvas canvas,
    RRect frame,
    double thin,
    double mid,
    double glow,
  ) {
    final rect = frame.outerRect;

    final y = labelTop + labelHeight - thin * 0.15;

    final startX = rect.left + rect.width * 0.055;
    final endX = rect.right - rect.width * 0.055;
    final width = math.max(0.0, endX - startX);

    final lineRect = Rect.fromLTWH(startX, y, width, thin);

    _glowRect(
      canvas,
      lineRect,
      glowWidth: glow,
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          _a(_cyan, 0.0),
          _a(_cyan, 0.55),
          _a(_cyanSoft, 0.20),
          _a(_cyan, 0.0),
        ],
        stops: const [0.0, 0.18, 0.72, 1.0],
      ),
    );
  }

  void _sideAccents(
    Canvas canvas,
    RRect frame,
    double thin,
    double mid,
    double glow,
  ) {
    final rect = frame.outerRect;
    final barW = math.max(2.0, rect.width * 0.006);
    final inset = rect.width * 0.006;
    final top = rect.top + rect.height * 0.18;
    final bottom = rect.bottom - rect.height * 0.12;

    final leftBar = Rect.fromLTWH(rect.left + inset, top, barW, bottom - top);
    final rightBar = Rect.fromLTWH(
      rect.right - inset - barW,
      top,
      barW,
      bottom - top,
    );

    _glowRect(
      canvas,
      leftBar,
      glowWidth: glow,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_a(_cyan, 0.15), _a(_cyan, 0.85), _a(_cyan, 0.15)],
      ),
    );

    _glowRect(
      canvas,
      rightBar,
      glowWidth: glow,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_a(_cyan, 0.15), _a(_cyan, 0.85), _a(_cyan, 0.15)],
      ),
    );

    final innerR = frame.deflate(rect.width * 0.02).outerRect;
    final rightTick = Rect.fromLTWH(
      innerR.right + rect.width * 0.01,
      rect.top + rect.height * 0.48,
      barW,
      rect.height * 0.15,
    );
    _glowRect(
      canvas,
      rightTick,
      glowWidth: glow,
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x002FD0FF), Color(0xFF2FD0FF), Color(0x002FD0FF)],
      ),
    );
  }

  void _leftSlots(
    Canvas canvas,
    RRect frame,
    double thin,
    double mid,
    double glow,
  ) {
    final rect = frame.outerRect;

    final panelLeft = rect.left + rect.width * 0.032;
    final panelTop = rect.top + rect.height * 0.19;
    final panelH = rect.height * 0.70;

    final desiredSlotCount = 8;
    final gap = math.max(panelH * 0.020, 6.0);
    const minSlotH = 18.0;

    final maxCount = ((panelH - gap) / (minSlotH + gap)).floor();
    final slotCount = math.max(1, math.min(desiredSlotCount, maxCount));
    final slotH = math.max(0.0, (panelH - gap * (slotCount + 1)) / slotCount);

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

    final panel = RRect.fromRectAndRadius(
      Rect.fromLTWH(panelLeft, panelTop, panelW, panelH),
      Radius.circular(rect.width * 0.014),
    );

    _strokeRRect(canvas, panel, strokeWidth: thin, color: _a(_steel, 0.22));

    final slotMid = math.max(thin, math.min(mid, slotH * 0.22));
    final slotGlow = math.min(glow, math.max(3.0, slotH * 0.85));

    for (var i = 0; i < slotCount; i++) {
      final y = panel.outerRect.top + gap + i * (slotH + gap);
      final slot = RRect.fromRectAndRadius(
        Rect.fromLTWH(slotX, y, slotW, slotH),
        Radius.circular(slotH * 0.18),
      );

      _glowRRect(
        canvas,
        slot,
        strokeWidth: slotMid,
        glowWidth: slotGlow,
        shaderRect: slot.outerRect,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_a(_cyan, 0.65), _a(_cyanSoft, 0.15), _a(_cyan, 0.65)],
        ),
      );

      _strokeRRect(
        canvas,
        slot.deflate(slotH * 0.12),
        strokeWidth: thin,
        color: _a(_steel, 0.18),
      );
    }

    final lineX = panel.outerRect.right + rect.width * 0.012;
    final lineW = math.max(thin, rect.width * 0.0022);

    final extend = rect.height * 0.045;
    final yTop = math.max(rect.top + rect.height * 0.10, panelTop - extend);
    final yBottom = math.min(
      rect.bottom - rect.height * 0.06,
      panelTop + panelH + extend,
    );
    final lineRect = Rect.fromLTWH(
      lineX,
      yTop,
      lineW,
      math.max(0.0, yBottom - yTop),
    );

    _glowRect(
      canvas,
      lineRect,
      glowWidth: glow,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _a(_cyan, 0.0),
          _a(_cyan, 0.55),
          _a(_cyanSoft, 0.22),
          _a(_cyan, 0.0),
        ],
        stops: const [0.0, 0.20, 0.78, 1.0],
      ),
    );
  }

  void _bottomNotch(
    Canvas canvas,
    RRect frame,
    double thin,
    double mid,
    double glow,
  ) {
    final rect = frame.outerRect;
    final s = math.min(rect.width, rect.height);

    final notchW = rect.width * 0.20;
    final notchH = rect.height * 0.028;
    final x0 = rect.center.dx - notchW / 2;
    final y0 = rect.bottom - rect.height * 0.036;
    final cut = s * 0.018;

    final p = Path()
      ..moveTo(x0, y0)
      ..lineTo(x0 + notchW * 0.26, y0)
      ..lineTo(x0 + notchW * 0.26 + cut, y0 - notchH)
      ..lineTo(x0 + notchW * 0.74 - cut, y0 - notchH)
      ..lineTo(x0 + notchW * 0.74, y0)
      ..lineTo(x0 + notchW, y0)
      ..close();

    _glowPath(
      canvas,
      p,
      strokeWidth: mid,
      glowWidth: glow,
      shaderRect: rect,
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          _a(_cyan, 0.0),
          _a(_cyan, 0.82),
          _a(_cyanSoft, 0.22),
          _a(_cyan, 0.0),
        ],
        stops: const [0.0, 0.30, 0.70, 1.0],
      ),
    );

    final base1 = Rect.fromLTWH(
      rect.left + rect.width * 0.055,
      rect.bottom - rect.height * 0.052,
      rect.width * 0.89,
      thin,
    );

    final base2 = Rect.fromLTWH(
      rect.left + rect.width * 0.09,
      rect.bottom - rect.height * 0.062,
      rect.width * 0.82,
      thin,
    );

    _glowRect(
      canvas,
      base1,
      glowWidth: glow,
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [_a(_cyan, 0.0), _a(_cyan, 0.38), _a(_cyan, 0.0)],
      ),
    );

    _glowRect(
      canvas,
      base2,
      glowWidth: glow,
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [_a(_cyan, 0.0), _a(_cyanSoft, 0.22), _a(_cyan, 0.0)],
      ),
    );
  }

  void _strokeRRect(
    Canvas canvas,
    RRect rrect, {
    required double strokeWidth,
    required Color color,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color
      ..isAntiAlias = true;
    canvas.drawRRect(rrect, paint);
  }

  void _glowRRect(
    Canvas canvas,
    RRect rrect, {
    required double strokeWidth,
    required double glowWidth,
    required Rect shaderRect,
    required Gradient gradient,
  }) {
    final shader = gradient.createShader(shaderRect);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = shader
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowWidth)
      ..isAntiAlias = true;

    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = shader
      ..isAntiAlias = true;

    canvas.drawRRect(rrect, glowPaint);
    canvas.drawRRect(rrect, corePaint);
  }

  void _glowRect(
    Canvas canvas,
    Rect rect, {
    required double glowWidth,
    required Gradient gradient,
  }) {
    final shader = gradient.createShader(rect);

    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = shader
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowWidth)
      ..isAntiAlias = true;

    final corePaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = shader
      ..isAntiAlias = true;

    canvas.drawRect(rect, glowPaint);
    canvas.drawRect(rect, corePaint);
  }

  void _glowPath(
    Canvas canvas,
    Path path, {
    required double strokeWidth,
    required double glowWidth,
    required Rect shaderRect,
    required Gradient gradient,
  }) {
    final shader = gradient.createShader(shaderRect);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = shader
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowWidth)
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = shader
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _HudFramePainter) return true;
    return oldDelegate.labelTop != labelTop ||
        oldDelegate.labelHeight != labelHeight ||
        oldDelegate.labelLeft != labelLeft ||
        oldDelegate.labelMaxWidth != labelMaxWidth;
  }
}
