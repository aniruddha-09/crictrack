// lib/features/session_detail/widgets/pitch_map_tab.dart
// 2D top-down pitch with scatter of landing points colored by speed.
// Tap a dot to show that delivery's stats.

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/session.dart';
import '../../../data/models/delivery.dart';
import '../../../data/models/enums.dart';

class PitchMapTab extends StatefulWidget {
  final CricketSession session;

  const PitchMapTab({super.key, required this.session});

  @override
  State<PitchMapTab> createState() => _PitchMapTabState();
}

class _PitchMapTabState extends State<PitchMapTab> {
  Delivery? _selected;

  @override
  Widget build(BuildContext context) {
    final accepted = widget.session.deliveries
        .where((d) => d.status != DeliveryStatus.rejected)
        .toList();

    return Column(
      children: [
        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Text('Speed: ', style: AppTextStyles.labelMedium),
              _LegendDot(color: const Color(0xFF22C55E), label: '<125'),
              const SizedBox(width: 10),
              _LegendDot(color: const Color(0xFFF59E0B), label: '125–135'),
              const SizedBox(width: 10),
              _LegendDot(color: const Color(0xFFEF4444), label: '>135'),
              const Spacer(),
              _LegendDot(color: AppColors.uncertain, label: 'Uncertain', shape: BoxShape.rectangle),
            ],
          ),
        ),

        // Pitch map
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: GestureDetector(
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                _handleTap(details.localPosition, accepted, box.size);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: CustomPaint(
                    painter: _PitchMapPainter(
                      deliveries: accepted,
                      selected: _selected,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Selected delivery info
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _selected == null
              ? Padding(
                  key: const ValueKey('hint'),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: const Text(
                    'Tap a landing point to see delivery details',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                )
              : _DeliveryInfoCard(
                  key: ValueKey(_selected!.id),
                  delivery: _selected!,
                  onClose: () => setState(() => _selected = null),
                ),
        ),
      ],
    );
  }

  void _handleTap(Offset pos, List<Delivery> deliveries, Size size) {
    // Compute pitch area bounds (matches painter logic)
    const padding = AppSpacing.md;
    final pitchLeft = padding + size.width * 0.20;
    final pitchRight = size.width - padding - size.width * 0.20;
    final pitchTop = padding + size.height * 0.05;
    final pitchBottom = size.height - padding - size.height * 0.10;
    final pitchWidth = pitchRight - pitchLeft;
    final pitchHeight = pitchBottom - pitchTop;

    Delivery? closest;
    double minDist = 20;
    for (final d in deliveries) {
      final bz = d.trajectory.bounce.z;
      final bx = d.trajectory.bounce.x;
      final px = pitchLeft + pitchWidth * (0.5 + bx * 0.35);
      final py = pitchTop + (bz / 20.12) * pitchHeight;
      final dist = (Offset(px, py) - pos).distance;
      if (dist < minDist) {
        minDist = dist;
        closest = d;
      }
    }
    setState(() => _selected = closest);
  }
}

class _PitchMapPainter extends CustomPainter {
  final List<Delivery> deliveries;
  final Delivery? selected;

  _PitchMapPainter({required this.deliveries, this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    const hPad = AppSpacing.md;
    final pitchLeft = hPad + w * 0.20;
    final pitchRight = w - hPad - w * 0.20;
    final pitchTop = hPad + h * 0.05;
    final pitchBottom = h - hPad - h * 0.10;
    final pitchWidth = pitchRight - pitchLeft;
    final pitchHeight = pitchBottom - pitchTop;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = AppColors.card,
    );

    // Outfield (oval)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h / 2),
        width: w * 0.95,
        height: h * 0.95,
      ),
      Paint()..color = const Color(0xFF1A2A1A).withValues(alpha: 0.6),
    );

    // Pitch surface
    final pitchRect = Rect.fromLTWH(pitchLeft, pitchTop, pitchWidth, pitchHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(pitchRect, const Radius.circular(3)),
      Paint()..color = const Color(0xFF8B6914).withValues(alpha: 0.4),
    );

    // Pitch lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Creases
    _drawLine(
      canvas,
      Offset(pitchLeft, pitchTop + pitchHeight * 0.10),
      Offset(pitchRight, pitchTop + pitchHeight * 0.10),
      linePaint,
    );
    _drawLine(
      canvas,
      Offset(pitchLeft, pitchBottom - pitchHeight * 0.10),
      Offset(pitchRight, pitchBottom - pitchHeight * 0.10),
      linePaint,
    );

    // Center line
    _drawDashed(
      canvas,
      Offset(w / 2, pitchTop),
      Offset(w / 2, pitchBottom),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..strokeWidth = 1.0,
    );

    // Stumps
    _drawStumps(canvas, Offset(w / 2, pitchTop + pitchHeight * 0.06), 22);
    _drawStumps(canvas, Offset(w / 2, pitchBottom - pitchHeight * 0.06), 22);

    // Length zones (labels)
    _drawZoneLabel(canvas, 'YORKER', w / 2, pitchTop + pitchHeight * 0.13, Colors.white24);
    _drawZoneLabel(canvas, 'FULL', w / 2, pitchTop + pitchHeight * 0.30, Colors.white24);
    _drawZoneLabel(canvas, 'GOOD', w / 2, pitchTop + pitchHeight * 0.55, Colors.white24);
    _drawZoneLabel(canvas, 'SHORT', w / 2, pitchTop + pitchHeight * 0.78, Colors.white24);

    // Landing dots
    for (final d in deliveries) {
      final bz = d.trajectory.bounce.z;
      final bx = d.trajectory.bounce.x;
      final px = pitchLeft + pitchWidth * (0.5 + bx * 0.35);
      final py = pitchTop + (bz / 20.12) * pitchHeight;

      final color = d.status == DeliveryStatus.uncertain
          ? AppColors.uncertain
          : _speedColor(d.speedKmh);

      final isSelected = selected?.id == d.id;
      final radius = isSelected ? 8.0 : 5.5;

      if (isSelected) {
        canvas.drawCircle(
          Offset(px, py),
          radius + 4,
          Paint()..color = color.withValues(alpha: 0.3),
        );
      }

      canvas.drawCircle(
        Offset(px, py),
        radius,
        Paint()..color = color,
      );

      if (isSelected) {
        canvas.drawCircle(
          Offset(px, py),
          radius,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  Color _speedColor(double speed) {
    if (speed >= 135) return const Color(0xFFEF4444);
    if (speed >= 125) return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  void _drawLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    canvas.drawLine(a, b, paint);
  }

  void _drawDashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 6.0;
    // ignore: unused_local_variable
    final dy = b.dy - a.dy;
    var y = a.dy;
    bool draw = true;
    while (y < b.dy) {
      final end = min(y + dash, b.dy);
      if (draw) canvas.drawLine(Offset(a.dx, y), Offset(b.dx, end), paint);
      y = end;
      draw = !draw;
    }
  }

  void _drawStumps(Canvas canvas, Offset center, double width) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final gap = width / 3;
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(center.dx + i * gap, center.dy - 7),
        Offset(center.dx + i * gap, center.dy + 7),
        p,
      );
    }
    canvas.drawLine(
      Offset(center.dx - gap, center.dy - 7),
      Offset(center.dx + gap, center.dy - 7),
      p..strokeWidth = 1.5,
    );
  }

  void _drawZoneLabel(Canvas canvas, String text, double x, double y, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _PitchMapPainter old) =>
      old.selected?.id != selected?.id;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final BoxShape shape;
  const _LegendDot({
    required this.color,
    required this.label,
    this.shape = BoxShape.circle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: shape),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _DeliveryInfoCard extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback onClose;

  const _DeliveryInfoCard({super.key, required this.delivery, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery ${delivery.number}',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _chip('${delivery.speedKmh.toStringAsFixed(1)} km/h', AppColors.cyan),
                    const SizedBox(width: 8),
                    _chip(delivery.line.label, AppColors.textSecondary),
                    const SizedBox(width: 8),
                    _chip(delivery.length.label, AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Spin: ${delivery.spinRpm.toStringAsFixed(0)} rpm  ·  '
                  'Confidence: ${(delivery.trajectory.confidence * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
