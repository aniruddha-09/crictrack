// lib/features/record/widgets/pitch_guide_overlay.dart
// Semi-transparent pitch guide overlay drawn on top of camera preview.

import 'package:flutter/material.dart';

class PitchGuideOverlay extends StatelessWidget {
  const PitchGuideOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PitchGuidePainter(),
      size: Size.infinite,
    );
  }
}

class _PitchGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Pitch perspective trapezoid
    // In a side/behind view, the pitch looks like a trapezoid converging towards top
    final topLeft = Offset(w * 0.4, h * 0.3);
    final topRight = Offset(w * 0.6, h * 0.3);
    final bottomLeft = Offset(w * 0.2, h * 0.85);
    final bottomRight = Offset(w * 0.8, h * 0.85);

    final path = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();

    canvas.drawPath(path, paint);

    // Crease lines
    // Batting crease
    _drawLine(
      canvas,
      Offset(topLeft.dx - 10, topLeft.dy + 10),
      Offset(topRight.dx + 10, topRight.dy + 10),
      paint,
    );
    // Bowling crease
    _drawLine(
      canvas,
      Offset(bottomLeft.dx + 10, bottomLeft.dy - 10),
      Offset(bottomRight.dx - 10, bottomRight.dy - 10),
      paint,
    );

    // Stumps at batter end (top of trapezoid)
    final stumpPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final centerX = (topLeft.dx + topRight.dx) / 2;
    final stumpY = topLeft.dy;
    const stumpH = 16.0;
    const stumpGap = 8.0;
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(centerX + i * stumpGap, stumpY - stumpH),
        Offset(centerX + i * stumpGap, stumpY),
        stumpPaint,
      );
    }
    // Bail
    canvas.drawLine(
      Offset(centerX - stumpGap, stumpY - stumpH),
      Offset(centerX + stumpGap, stumpY - stumpH),
      stumpPaint..strokeWidth = 1.5,
    );

    // Center guide line
    _drawDashedLine(
      canvas,
      Offset((topLeft.dx + topRight.dx) / 2, topLeft.dy),
      Offset((bottomLeft.dx + bottomRight.dx) / 2, bottomLeft.dy),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..strokeWidth = 1.0,
    );
  }

  void _drawLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    canvas.drawLine(a, b, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    const dashLen = 8.0;
    const gapLen = 8.0;
    final total = (dx * dx + dy * dy);
    if (total == 0) return;
    final len = total.clamp(0, double.infinity).toDouble();
    final nx = dx / (len < 1 ? 1 : (len));
    final ny = dy / (len < 1 ? 1 : (len));
    final pathLen = len;
    var pos = 0.0;
    var drawing = true;
    while (pos < pathLen) {
      final seg = drawing ? dashLen : gapLen;
      final end = pos + seg;
      if (drawing) {
        final s = Offset(a.dx + nx * pos, a.dy + ny * pos);
        final e = Offset(a.dx + nx * end.clamp(0, pathLen), a.dy + ny * end.clamp(0, pathLen));
        canvas.drawLine(s, e, paint);
      }
      pos = end;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
