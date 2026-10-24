// lib/features/trajectory/widgets/trajectory_3d_viewer.dart
// Interactive 3D trajectory viewer using CustomPainter with perspective projection.
// - Drag to rotate (yaw + pitch)
// - Pinch to zoom
// - Toggle stumps, landing point, uncertainty band
// - Playback slider animates ball along path

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/strings.dart';
import '../../../data/models/trajectory_point.dart';
import '../../../data/models/enums.dart';

class Trajectory3DViewer extends StatefulWidget {
  final FinalTrajectory trajectory;
  final int deliveryNumber;

  const Trajectory3DViewer({
    super.key,
    required this.trajectory,
    required this.deliveryNumber,
  });

  @override
  State<Trajectory3DViewer> createState() => _Trajectory3DViewerState();
}

class _Trajectory3DViewerState extends State<Trajectory3DViewer>
    with SingleTickerProviderStateMixin {
  // ─── Camera rotation state ────────────────────────────────────────────────
  double _yaw = 0.4;    // horizontal rotation (radians)
  double _pitch = 0.3;  // vertical rotation (radians)
  double _zoom = 1.0;

  // ─── Playback state ───────────────────────────────────────────────────────
  double _playbackT = 1.0; // 0→1, fraction of trajectory to show
  bool _playing = false;
  late AnimationController _animCtrl;

  // ─── Toggle state ─────────────────────────────────────────────────────────
  bool _showStumps = true;
  bool _showLandingPoint = true;
  bool _showUncertainty = true;

  // Drag state
  Offset? _lastDragPos;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() => _playbackT = _animCtrl.value);
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _playing = false);
        }
      });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_playing) {
      _animCtrl.stop();
      setState(() => _playing = false);
    } else {
      if (_playbackT >= 1.0) {
        _playbackT = 0;
        _animCtrl.forward(from: 0);
      } else {
        _animCtrl.forward(from: _playbackT);
      }
      setState(() => _playing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRejected =
        widget.trajectory.status == DeliveryStatus.rejected;
    final isUncertain =
        widget.trajectory.status == DeliveryStatus.uncertain;

    return Column(
      children: [
        // ── Viewer ──────────────────────────────────────────────────────────
        Expanded(
          child: GestureDetector(
            onScaleStart: (d) {
              _lastDragPos = d.focalPoint;
            },
            onScaleUpdate: (d) {
              final delta = d.focalPoint - (_lastDragPos ?? d.focalPoint);
              _lastDragPos = d.focalPoint;
              setState(() {
                _yaw += delta.dx * 0.008;
                _pitch = (_pitch - delta.dy * 0.008).clamp(-pi / 2.5, pi / 2.5);
                if (d.scale != 1.0) {
                  _zoom = (_zoom * d.scale).clamp(0.5, 3.0);
                }
              });
            },
            onScaleEnd: (_) => _lastDragPos = null,
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0F14),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isRejected
                      ? AppColors.rejected.withValues(alpha: 0.4)
                      : isUncertain
                          ? AppColors.uncertain.withValues(alpha: 0.4)
                          : AppColors.border,
                ),
              ),
              child: Stack(
                children: [
                  // 3D trajectory painter
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: CustomPaint(
                      painter: _TrajectoryPainter(
                        trajectory: widget.trajectory,
                        yaw: _yaw,
                        pitch: _pitch,
                        zoom: _zoom,
                        playbackT: _playbackT,
                        showStumps: _showStumps,
                        showLandingPoint: _showLandingPoint,
                        showUncertainty: _showUncertainty,
                      ),
                      size: Size.infinite,
                    ),
                  ),

                  // Hint text
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        '↔ Drag to rotate  ·  Pinch to zoom',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),

                  // Status indicator
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _StatusBadge(status: widget.trajectory.status),
                  ),

                  // Metrics overlay
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _MetricsOverlay(trajectory: widget.trajectory),
                  ),

                  // Uncertainty notice
                  if (isUncertain)
                    Positioned(
                      bottom: 28,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.uncertain.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.uncertain.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          'UNCERTAIN: trajectory may not be fully accurate',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.uncertain,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // ── Toggles ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              _ToggleChip(
                label: AppStrings.showStumps,
                icon: Icons.grid_on_rounded,
                active: _showStumps,
                onTap: () => setState(() => _showStumps = !_showStumps),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ToggleChip(
                label: AppStrings.showLandingPoint,
                icon: Icons.place_rounded,
                active: _showLandingPoint,
                onTap: () => setState(() => _showLandingPoint = !_showLandingPoint),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ToggleChip(
                label: AppStrings.showUncertainty,
                icon: Icons.blur_on_rounded,
                active: _showUncertainty,
                onTap: () => setState(
                  () => _showUncertainty = !_showUncertainty,
                ),
              ),
            ],
          ),
        ),

        // ── Playback controls ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: AppColors.green,
                ),
                onPressed: _togglePlay,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  child: Slider(
                    value: _playbackT,
                    onChanged: (v) {
                      _animCtrl.stop();
                      setState(() {
                        _playing = false;
                        _playbackT = v;
                      });
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.replay_rounded, color: AppColors.textMuted),
                onPressed: () {
                  _animCtrl.stop();
                  setState(() {
                    _playing = false;
                    _playbackT = 0;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

// ─── 3D Perspective Projection Painter ───────────────────────────────────────
class _TrajectoryPainter extends CustomPainter {
  final FinalTrajectory trajectory;
  final double yaw;
  final double pitch;
  final double zoom;
  final double playbackT;
  final bool showStumps;
  final bool showLandingPoint;
  final bool showUncertainty;

  _TrajectoryPainter({
    required this.trajectory,
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.playbackT,
    required this.showStumps,
    required this.showLandingPoint,
    required this.showUncertainty,
  });

  // Perspective projection
  Offset project(Offset3D p, Offset center, double scale) {
    // Rotate around Y axis (yaw)
    final cosY = cos(yaw);
    final sinY = sin(yaw);
    final x1 = p.x * cosY - p.z * sinY;
    final z1 = p.x * sinY + p.z * cosY;

    // Rotate around X axis (pitch)
    final cosP = cos(pitch);
    final sinP = sin(pitch);
    final y1 = p.y * cosP - z1 * sinP;
    final z2 = p.y * sinP + z1 * cosP;

    // Perspective divide
    const fov = 600.0;
    final perspScale = fov / (fov + z2 + 5);
    final sx = center.dx + x1 * scale * perspScale;
    final sy = center.dy - y1 * scale * perspScale;
    return Offset(sx, sy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.55);
    final scale = min(size.width, size.height) * 0.04 * zoom;

    // Normalize points (pitch is 20.12 m long; center it)
    final normalized = trajectory.points.map((p) {
      return _NormalizedPoint(
        point: p,
        n: Offset3D(
          x: (p.x) * 3,
          y: p.y * 2,
          z: (p.z - 10.06) * 1.2, // center on pitch midpoint
        ),
      );
    }).toList();

    // Draw pitch plane (wireframe)
    _drawPitchPlane(canvas, center, scale);

    // Draw stumps wireframe
    if (showStumps) {
      _drawStumps(canvas, center, scale, batter: true);
      _drawStumps(canvas, center, scale, batter: false);
    }

    // Filter points by playback progress
    final totalPts = normalized.length;
    final visibleCount = (totalPts * playbackT).ceil().clamp(1, totalPts);
    final visiblePts = normalized.take(visibleCount).toList();

    // Draw uncertainty band (tubes)
    if (showUncertainty && trajectory.status != DeliveryStatus.rejected) {
      _drawUncertaintyBand(canvas, visiblePts, center, scale);
    }

    // Draw trajectory path (red line)
    _drawTrajectoryPath(canvas, visiblePts, center, scale);

    // Draw phase markers
    _drawPhaseMarkers(canvas, visiblePts, center, scale);

    // Draw release marker (cyan circle)
    if (visiblePts.isNotEmpty) {
      final rp = project(normalized.first.n, center, scale);
      canvas.drawCircle(
        rp,
        6,
        Paint()..color = AppColors.phaseRelease,
      );
      canvas.drawCircle(
        rp,
        3,
        Paint()..color = Colors.white,
      );
    }

    // Draw landing/bounce point (cross marker)
    if (showLandingPoint) {
      final bounceIdx = normalized.indexWhere(
        (np) => np.point.phase == TrajectoryPhase.bounce,
      );
      if (bounceIdx != -1 && bounceIdx < visibleCount) {
        final bp = project(normalized[bounceIdx].n, center, scale);
        _drawCrossMarker(canvas, bp, AppColors.phaseBounce, 10);
      }
    }

    // Draw ball at current position (animated)
    if (visiblePts.isNotEmpty) {
      final ballPt = visiblePts.last;
      final ballPos = project(ballPt.n, center, scale);
      // Glow
      canvas.drawCircle(
        ballPos,
        12,
        Paint()
          ..color = AppColors.rejected.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // Ball
      canvas.drawCircle(
        ballPos,
        7,
        Paint()..color = AppColors.rejected,
      );
      canvas.drawCircle(
        ballPos,
        5,
        Paint()..color = Colors.white,
      );
    }

    // Draw wicket plane impact (target circle)
    if (showStumps) {
      final wp = trajectory.wicketPlane;
      final impactN = Offset3D(
        x: wp.impactX * 3,
        y: wp.impactY * 2,
        z: (20.12 - 10.06) * 1.2,
      );
      final ip = project(impactN, center, scale);
      final targetColor = wp.stumpsHit ? AppColors.rejected : AppColors.green;
      _drawTargetCircle(canvas, ip, targetColor);
    }
  }

  void _drawPitchPlane(Canvas canvas, Offset center, double scale) {
    final corners = [
      Offset3D(x: -1.5, y: 0, z: (-10.06) * 1.2),
      Offset3D(x: 1.5, y: 0, z: (-10.06) * 1.2),
      Offset3D(x: 1.5, y: 0, z: (10.06) * 1.2),
      Offset3D(x: -1.5, y: 0, z: (10.06) * 1.2),
    ];
    final pts = corners.map((c) => project(c, center, scale)).toList();
    final path = Path()
      ..moveTo(pts[0].dx, pts[0].dy)
      ..lineTo(pts[1].dx, pts[1].dy)
      ..lineTo(pts[2].dx, pts[2].dy)
      ..lineTo(pts[3].dx, pts[3].dy)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF4A3010).withValues(alpha: 0.4)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  void _drawStumps(
    Canvas canvas,
    Offset center,
    double scale, {
    required bool batter,
  }) {
    final z = batter ? (20.12 - 10.06) * 1.2 : (-10.06) * 1.2;
    const stumpXs = [-0.355, 0.0, 0.355];
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (final sx in stumpXs) {
      final base = project(Offset3D(x: sx * 3, y: 0, z: z), center, scale);
      final top = project(Offset3D(x: sx * 3, y: 1.422, z: z), center, scale);
      canvas.drawLine(base, top, paint);
    }

    // Bails
    final topLeft = project(
      Offset3D(x: stumpXs.first * 3, y: 1.422, z: z),
      center,
      scale,
    );
    final topRight = project(
      Offset3D(x: stumpXs.last * 3, y: 1.422, z: z),
      center,
      scale,
    );
    canvas.drawLine(
      topLeft,
      topRight,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..strokeWidth = 1.5,
    );
  }

  void _drawUncertaintyBand(
    Canvas canvas,
    List<_NormalizedPoint> pts,
    Offset center,
    double scale,
  ) {
    if (pts.length < 2) return;
    for (int i = 0; i < pts.length - 1; i++) {
      final p1 = project(pts[i].n, center, scale);
      final p2 = project(pts[i + 1].n, center, scale);
      final u = (pts[i].point.uncertaintyM * scale * 8).clamp(2.0, 20.0);

      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = AppColors.rejected.withValues(alpha: 0.12)
          ..strokeWidth = u.toDouble()
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawTrajectoryPath(
    Canvas canvas,
    List<_NormalizedPoint> pts,
    Offset center,
    double scale,
  ) {
    if (pts.isEmpty) return;
    for (int i = 0; i < pts.length - 1; i++) {
      final p1 = project(pts[i].n, center, scale);
      final p2 = project(pts[i + 1].n, center, scale);
      final phase = pts[i].point.phase;
      final color = _phaseColor(phase);

      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = color
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawPhaseMarkers(
    Canvas canvas,
    List<_NormalizedPoint> pts,
    Offset center,
    double scale,
  ) {
    // Dots at phase transitions
    TrajectoryPhase? lastPhase;
    for (final np in pts) {
      if (np.point.phase != lastPhase) {
        lastPhase = np.point.phase;
        if (np.point.phase == TrajectoryPhase.bounce ||
            np.point.phase == TrajectoryPhase.postBounce) {
          // Already handled separately
        }
      }
    }
  }

  void _drawCrossMarker(Canvas canvas, Offset pos, Color color, double size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(pos.dx - size, pos.dy),
      Offset(pos.dx + size, pos.dy),
      p,
    );
    canvas.drawLine(
      Offset(pos.dx, pos.dy - size),
      Offset(pos.dx, pos.dy + size),
      p,
    );
    canvas.drawCircle(pos, 4, Paint()..color = color.withValues(alpha: 0.5));
  }

  void _drawTargetCircle(Canvas canvas, Offset pos, Color color) {
    for (int r in [12, 7, 3]) {
      canvas.drawCircle(
        pos,
        r.toDouble(),
        Paint()
          ..color = color.withValues(alpha: r == 3 ? 0.9 : 0.3)
          ..style = r == 3 ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  Color _phaseColor(TrajectoryPhase phase) {
    switch (phase) {
      case TrajectoryPhase.release:
        return AppColors.phaseRelease;
      case TrajectoryPhase.flight:
        return AppColors.phaseFlight;
      case TrajectoryPhase.bounce:
        return AppColors.phaseBounce;
      case TrajectoryPhase.postBounce:
        return AppColors.phasePostBounce;
    }
  }

  @override
  bool shouldRepaint(covariant _TrajectoryPainter old) =>
      old.yaw != yaw ||
      old.pitch != pitch ||
      old.zoom != zoom ||
      old.playbackT != playbackT ||
      old.showStumps != showStumps ||
      old.showLandingPoint != showLandingPoint ||
      old.showUncertainty != showUncertainty ||
      old.trajectory.deliveryId != trajectory.deliveryId;
}

// ─── Helper types ─────────────────────────────────────────────────────────────
class Offset3D {
  final double x;
  final double y;
  final double z;
  const Offset3D({required this.x, required this.y, required this.z});
}

class _NormalizedPoint {
  final TrajectoryPoint point;
  final Offset3D n;
  _NormalizedPoint({required this.point, required this.n});
}

// ─── Widgets ──────────────────────────────────────────────────────────────────
class _ToggleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.greenGlow : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: active ? AppColors.green : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: active ? AppColors.green : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.green : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DeliveryStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      DeliveryStatus.accepted => (AppColors.accepted, 'ACCEPTED'),
      DeliveryStatus.uncertain => (AppColors.uncertain, 'UNCERTAIN'),
      DeliveryStatus.rejected => (AppColors.rejected, 'REJECTED'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MetricsOverlay extends StatelessWidget {
  final FinalTrajectory trajectory;
  const _MetricsOverlay({required this.trajectory});

  @override
  Widget build(BuildContext context) {
    final m = trajectory.metrics;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _metricRow('${m.speedKmh.toStringAsFixed(1)} km/h', AppColors.cyan),
          _metricRow('${m.spinRpm.toStringAsFixed(0)} rpm', AppColors.phasePostBounce),
          _metricRow('${m.swingDeg.toStringAsFixed(1)}° swing', AppColors.textSecondary),
          _metricRow(m.line, AppColors.textSecondary),
          _metricRow(m.length, AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _metricRow(String text, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      );
}
