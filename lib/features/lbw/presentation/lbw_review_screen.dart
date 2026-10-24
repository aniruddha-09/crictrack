// lib/features/lbw/presentation/lbw_review_screen.dart
// LBW / DRS Review screen - uses FinalTrajectory.wicketPlane data.
// Verdict: OUT (confidence >= 0.8 AND stumpsHit), UMPIRE'S CALL (uncertain),
//          NOT OUT (stumps not hit).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/strings.dart';
import '../../../app/providers.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/trajectory_point.dart';
import '../../../data/models/delivery.dart';
import '../../trajectory/widgets/trajectory_3d_viewer.dart';

class LbwReviewScreen extends ConsumerWidget {
  final String deliveryId;
  final String sessionId;

  const LbwReviewScreen({
    super.key,
    required this.deliveryId,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider(sessionId));

    return sessionAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text(e.toString())),
      ),
      data: (session) {
        final delivery = session.deliveries.firstWhere(
          (d) => d.id == deliveryId,
          orElse: () => session.deliveries.first,
        );
        return _LbwReviewView(delivery: delivery);
      },
    );
  }
}

class _LbwReviewView extends StatelessWidget {
  final Delivery delivery;

  const _LbwReviewView({required this.delivery});

  LbwVerdict _computeVerdict() {
    final wp = delivery.trajectory.wicketPlane;
    final status = delivery.trajectory.status;

    if (status == DeliveryStatus.uncertain) return LbwVerdict.umpiresCall;
    if (!wp.stumpsHit) return LbwVerdict.notOut;
    if (wp.confidence >= 0.8) return LbwVerdict.out;
    return LbwVerdict.umpiresCall;
  }

  @override
  Widget build(BuildContext context) {
    final verdict = _computeVerdict();
    final wp = delivery.trajectory.wicketPlane;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.lbwAnalysis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 3D Trajectory Viewer (read-only from FinalTrajectory) ──────
            SizedBox(
              height: 300,
              child: Trajectory3DViewer(
                trajectory: delivery.trajectory,
                deliveryNumber: delivery.number,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Wicket Plane impact visualization ─────────────────────────
            const Text('Impact Point', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            _WicketPlaneView(wp: wp),

            const SizedBox(height: AppSpacing.lg),

            // ── Verdict card ───────────────────────────────────────────────
            _VerdictCard(verdict: verdict, wp: wp),

            const SizedBox(height: AppSpacing.lg),

            // ── Honesty notice ─────────────────────────────────────────────
            if (delivery.trajectory.status == DeliveryStatus.uncertain)
              _UncertaintyNotice(trajectory: delivery.trajectory),

            const SizedBox(height: AppSpacing.lg),

            // ── Actions ────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text(AppStrings.accept),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: verdict != LbwVerdict.out
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('DRS review requested (mock)'),
                              ),
                            );
                          },
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text(AppStrings.requestReview),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rejected,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ─── Wicket Plane Visualiser ──────────────────────────────────────────────────
class _WicketPlaneView extends StatelessWidget {
  final WicketPlaneData wp;

  const _WicketPlaneView({required this.wp});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: CustomPaint(
        painter: _WicketPlanePainter(wp: wp),
        size: Size.infinite,
      ),
    );
  }
}

class _WicketPlanePainter extends CustomPainter {
  final WicketPlaneData wp;
  _WicketPlanePainter({required this.wp});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;
    final groundY = h * 0.85;

    // Draw ground line
    canvas.drawLine(
      Offset(0, groundY),
      Offset(w, groundY),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..strokeWidth = 1,
    );

    // Draw 3 stumps
    const stumpH = 80.0;
    const stumpGap = 22.0;
    const stumpW = 4.0;
    final stumpColor = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stumpW;

    for (int i = -1; i <= 1; i++) {
      final sx = centerX + i * stumpGap;
      canvas.drawLine(
        Offset(sx, groundY - stumpH),
        Offset(sx, groundY),
        stumpColor,
      );
    }

    // Bails
    canvas.drawLine(
      Offset(centerX - stumpGap, groundY - stumpH),
      Offset(centerX + stumpGap, groundY - stumpH),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..strokeWidth = 2.5,
    );

    // Stump-hitting zone (shaded rect)
    final zoneRect = Rect.fromLTRB(
      centerX - stumpGap - stumpW / 2,
      groundY - stumpH,
      centerX + stumpGap + stumpW / 2,
      groundY,
    );
    canvas.drawRect(
      zoneRect,
      Paint()..color = AppColors.rejected.withValues(alpha: 0.1),
    );

    // Impact point
    // Map impactX (-1 to 1) → canvas x; impactY (0 to 1) → canvas y from ground
    final impactX = centerX + wp.impactX * stumpGap * 1.5;
    final impactY = groundY - wp.impactY * stumpH * 1.1;

    final impactColor = wp.stumpsHit ? AppColors.rejected : AppColors.green;

    // Target rings
    for (final r in [20.0, 12.0, 6.0]) {
      canvas.drawCircle(
        Offset(impactX, impactY),
        r,
        Paint()
          ..color = impactColor.withValues(alpha: r == 6 ? 0.9 : 0.25)
          ..style = r == 6 ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Labels
    _text(
      canvas,
      wp.stumpsHit ? 'HITTING' : 'MISSING',
      Offset(impactX, impactY + 28),
      impactColor,
      10,
    );
  }

  void _text(
    Canvas canvas,
    String text,
    Offset pos,
    Color color,
    double fontSize,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Verdict Card ─────────────────────────────────────────────────────────────
class _VerdictCard extends StatelessWidget {
  final LbwVerdict verdict;
  final WicketPlaneData wp;

  const _VerdictCard({required this.verdict, required this.wp});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (verdict) {
      LbwVerdict.out => (AppColors.lbwOut, AppStrings.out, Icons.error_rounded),
      LbwVerdict.notOut => (AppColors.lbwNotOut, AppStrings.notOut, Icons.check_circle_rounded),
      LbwVerdict.umpiresCall => (AppColors.lbwUmpire, AppStrings.umpiresCall, Icons.gavel_rounded),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.verdict, style: AppTextStyles.bodySmall),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.confidence}: ${(wp.confidence * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  wp.stumpsHit ? 'Ball hitting stumps' : 'Ball missing stumps',
                  style: TextStyle(
                    fontSize: 12,
                    color: wp.stumpsHit ? AppColors.rejected : AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Uncertainty notice ───────────────────────────────────────────────────────
class _UncertaintyNotice extends StatelessWidget {
  final FinalTrajectory trajectory;

  const _UncertaintyNotice({required this.trajectory});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.uncertain.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.uncertain.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.uncertain, size: 18),
              const SizedBox(width: AppSpacing.sm),
              const Text(AppStrings.whyUncertain, style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'The ball tracking algorithm flagged this delivery as UNCERTAIN. '
            'The trajectory shown is a best estimate. When status is UNCERTAIN, '
            'the verdict is automatically set to UMPIRE\'S CALL regardless of '
            'the predicted impact point.',
            style: AppTextStyles.bodyMedium,
          ),
          if (trajectory.rejectReason != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Diagnostics: ${trajectory.rejectReason}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.uncertain,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
