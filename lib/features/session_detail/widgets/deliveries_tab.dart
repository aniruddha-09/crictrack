// lib/features/session_detail/widgets/deliveries_tab.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/strings.dart';
import '../../../data/models/session.dart';
import '../../../data/models/delivery.dart';
import '../../../data/models/enums.dart';

class DeliveriesTab extends StatelessWidget {
  final CricketSession session;

  const DeliveriesTab({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final deliveries = session.deliveries;

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: deliveries.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (ctx, i) {
        return DeliveryListItem(
          delivery: deliveries[i],
          sessionId: session.id,
        );
      },
    );
  }
}

class DeliveryListItem extends StatelessWidget {
  final Delivery delivery;
  final String sessionId;

  const DeliveryListItem({
    super.key,
    required this.delivery,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final isRejected = delivery.status == DeliveryStatus.rejected;

    return Opacity(
      opacity: isRejected ? 0.55 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _borderColor(delivery.status),
            width: delivery.status == DeliveryStatus.uncertain ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_rounded,
                  color: isRejected ? AppColors.textMuted : AppColors.green,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Delivery ${delivery.number}',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StatusChip(status: delivery.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MetaChip(
                        label: '${delivery.speedKmh.toStringAsFixed(1)} km/h',
                        color: AppColors.cyan,
                      ),
                      const SizedBox(width: 6),
                      _MetaChip(
                        label: delivery.line.label,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      _MetaChip(
                        label: delivery.length.label,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (!isRejected)
                    Text(
                      '${delivery.spinRpm.toStringAsFixed(0)} rpm  ·  ${delivery.swingDeg.toStringAsFixed(1)}° swing',
                      style: AppTextStyles.bodySmall,
                    ),
                  if (isRejected && delivery.trajectory.rejectReason != null)
                    Text(
                      delivery.trajectory.rejectReason!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.rejected,
                      ),
                    ),
                ],
              ),
            ),

            // Action buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isRejected)
                  IconButton(
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    color: AppColors.green,
                    onPressed: () => _showVideoPlayer(context, delivery),
                  ),
                if (delivery.isLbwCandidate)
                  GestureDetector(
                    onTap: () => context.push(
                      '/lbw?deliveryId=${delivery.id}&sessionId=$sessionId',
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lbwOut.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: AppColors.lbwOut.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Text(
                        'LBW',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.lbwOut,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                if (delivery.status == DeliveryStatus.uncertain)
                  TextButton(
                    onPressed: () => _showWhyUncertain(context, delivery),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      AppStrings.review,
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _borderColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.accepted:
        return AppColors.border;
      case DeliveryStatus.uncertain:
        return AppColors.uncertain.withValues(alpha: 0.5);
      case DeliveryStatus.rejected:
        return AppColors.rejected.withValues(alpha: 0.4);
    }
  }

  void _showVideoPlayer(BuildContext context, Delivery delivery) {
    showDialog(
      context: context,
      builder: (_) => _FakeVideoDialog(delivery: delivery),
    );
  }

  void _showWhyUncertain(BuildContext context, Delivery delivery) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.whyUncertain),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confidence: ${(delivery.trajectory.confidence * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'The ball tracking algorithm detected partial occlusion or '
              'reduced track quality during this delivery. The trajectory '
              'shown may have higher uncertainty, especially post-bounce.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Metrics from UNCERTAIN deliveries are excluded from session averages.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.uncertain,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DeliveryStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      DeliveryStatus.accepted => (AppColors.accepted, 'A'),
      DeliveryStatus.uncertain => (AppColors.uncertain, 'U'),
      DeliveryStatus.rejected => (AppColors.rejected, 'R'),
    };

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MetaChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Fake Video Player Dialog ─────────────────────────────────────────────────
class _FakeVideoDialog extends StatefulWidget {
  final Delivery delivery;
  const _FakeVideoDialog({required this.delivery});

  @override
  State<_FakeVideoDialog> createState() => _FakeVideoDialogState();
}

class _FakeVideoDialogState extends State<_FakeVideoDialog> {
  double _pos = 0.0;
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mock video frame
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.sports_cricket_rounded,
                    color: AppColors.border,
                    size: 64,
                  ),
                  // Speed overlay
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${widget.delivery.speedKmh.toStringAsFixed(1)} km/h',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // Trajectory overlay line (simplified)
                  CustomPaint(
                    painter: _TrajectoryLinePainter(progress: _pos),
                    size: const Size(double.infinity, 180),
                  ),
                ],
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: _pos,
                      onChanged: (v) => setState(() => _pos = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_5_rounded),
                        color: AppColors.textSecondary,
                        onPressed: () =>
                            setState(() => _pos = (_pos - 0.1).clamp(0, 1)),
                      ),
                      IconButton(
                        icon: Icon(
                          _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 36,
                        ),
                        color: AppColors.green,
                        onPressed: () => setState(() => _playing = !_playing),
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_5_rounded),
                        color: AppColors.textSecondary,
                        onPressed: () =>
                            setState(() => _pos = (_pos + 0.1).clamp(0, 1)),
                      ),
                    ],
                  ),
                  // Metrics row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _VideoStat(
                        label: 'Speed',
                        value: '${widget.delivery.speedKmh.toStringAsFixed(1)} km/h',
                      ),
                      _VideoStat(
                        label: 'Spin',
                        value: '${widget.delivery.spinRpm.toStringAsFixed(0)} rpm',
                      ),
                      _VideoStat(
                        label: 'Line',
                        value: widget.delivery.line.label,
                      ),
                      _VideoStat(
                        label: 'Length',
                        value: widget.delivery.length.label,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoStat extends StatelessWidget {
  final String label;
  final String value;
  const _VideoStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleMedium),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _TrajectoryLinePainter extends CustomPainter {
  final double progress;
  _TrajectoryLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.rejected.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (progress <= 0) return;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.2);

    // Parabolic path to bounce point
    final bounceX = size.width * 0.6;
    final bounceY = size.height * 0.75;

    // Draw partial path based on progress
    const steps = 50;
    final endStep = (steps * progress).toInt();

    for (int i = 1; i <= endStep && i <= steps; i++) {
      final t = i / steps;
      final x = size.width * 0.1 + (bounceX - size.width * 0.1) * t;
      final y = size.height * 0.2 +
          (bounceY - size.height * 0.2) * t +
          -30 * t * (1 - t); // upward arc

      if (i == 1) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrajectoryLinePainter old) =>
      old.progress != progress;
}
