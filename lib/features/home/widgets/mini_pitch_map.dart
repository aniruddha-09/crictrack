// lib/features/home/widgets/mini_pitch_map.dart
// Small 2D pitch map thumbnail for the Home screen last session card.

import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/delivery.dart';
import '../../../data/models/enums.dart';

class MiniPitchMap extends StatelessWidget {
  final List<Delivery> deliveries;

  const MiniPitchMap({super.key, required this.deliveries});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: CustomPaint(
        painter: _MiniPitchPainter(deliveries: deliveries),
        size: Size.infinite,
      ),
    );
  }
}

class _MiniPitchPainter extends CustomPainter {
  final List<Delivery> deliveries;
  _MiniPitchPainter({required this.deliveries});

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF1A2232),
    );

    // Pitch area
    final pitchRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.05,
      size.width * 0.6,
      size.height * 0.90,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pitchRect, const Radius.circular(2)),
      Paint()..color = const Color(0xFF2A3547),
    );

    // Crease lines
    final creasePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Batting crease (top)
    canvas.drawLine(
      Offset(pitchRect.left, pitchRect.top + pitchRect.height * 0.15),
      Offset(pitchRect.right, pitchRect.top + pitchRect.height * 0.15),
      creasePaint,
    );
    // Bowling crease (bottom)
    canvas.drawLine(
      Offset(pitchRect.left, pitchRect.bottom - pitchRect.height * 0.15),
      Offset(pitchRect.right, pitchRect.bottom - pitchRect.height * 0.15),
      creasePaint,
    );

    // Landing dots (only accepted)
    for (final d in deliveries.where((d) => d.status == DeliveryStatus.accepted)) {
      final bz = d.trajectory.bounce.z;
      final bx = d.trajectory.bounce.x;
      // Normalize: z 0→20.12 maps to top→bottom, x -1→1 maps to left→right
      final py = pitchRect.top +
          (bz / 20.12) * pitchRect.height;
      final px = pitchRect.left +
          pitchRect.width * (0.5 + bx * 0.5);

      final speed = d.speedKmh;
      final color = _speedColor(speed);

      canvas.drawCircle(
        Offset(px.clamp(pitchRect.left + 2, pitchRect.right - 2),
            py.clamp(pitchRect.top + 2, pitchRect.bottom - 2)),
        2.5,
        Paint()..color = color,
      );
    }
  }

  Color _speedColor(double speed) {
    if (speed >= 135) return const Color(0xFFEF4444);
    if (speed >= 125) return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
