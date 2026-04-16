import 'dart:math' as math;

import 'package:flutter/material.dart';

class HudModeLabel extends StatelessWidget {
  const HudModeLabel({
    super.key,
    required this.text,
    required this.height,
    required this.maxWidth,
  });

  final String text;
  final double height;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: height,
          maxHeight: height,
          maxWidth: maxWidth,
        ),
        child: CustomPaint(
          painter: _HudModeLabelPainter(),
          child: Padding(
            padding: EdgeInsets.only(
              left: height * 0.50,
              right: height * 1.05,
              top: height * 0.16,
              bottom: height * 0.16,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: height * 0.44,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HudModeLabelPainter extends CustomPainter {
  static const _cyan = Color(0xFF2FD0FF);
  static const _cyanSoft = Color(0xFF8BE9FF);

  static Color _a(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final cut = math.min(w * 0.11, h * 0.85);

    final p = Path()
      ..moveTo(0, 0)
      ..lineTo(w - cut, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w - cut, h)
      ..lineTo(0, h)
      ..close();

    // Opaque backplate to fully hide any HUD lines behind this label.
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF05080A), Color(0xFF000000)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..isAntiAlias = true;

    canvas.drawPath(p, fill);

    final strokeWidth = math.max(1.2, h * 0.06);
    final glowWidth = (h * 0.45).clamp(5.0, 16.0);

    final shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [_a(_cyan, 0.95), _a(_cyanSoft, 0.60), _a(_cyan, 0.10)],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

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

    // Draw the stroke/glow only outside the label shape so no bright lines show
    // inside under the text.
    final pad = glowWidth + strokeWidth;
    final full = Path()
      ..addRect(Rect.fromLTWH(-pad, -pad, w + 2 * pad, h + 2 * pad));
    final outsideOnly = Path.combine(PathOperation.difference, full, p);

    canvas.save();
    canvas.clipPath(outsideOnly);
    canvas.drawPath(p, glowPaint);
    canvas.drawPath(p, corePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
