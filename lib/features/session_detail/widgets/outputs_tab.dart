// lib/features/session_detail/widgets/outputs_tab.dart
// Stage 6 Outputs: Analysis Video, Pitch Map/3D View links, Diagnostics, JSON preview.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../../../core/theme.dart';
import '../../../core/strings.dart';
import '../../../data/models/session.dart';
import '../../../data/models/enums.dart';

class OutputsTab extends StatelessWidget {
  final CricketSession session;

  const OutputsTab({super.key, required this.session});

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Analysis Video'),
              Tab(text: 'Pitch/3D'),
              Tab(text: 'Diagnostics'),
              if (true) Tab(text: 'JSON'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // ─── Analysis Video ──────────────────────────────────────
                _AnalysisVideoTab(session: session),
                // ─── Pitch/3D ────────────────────────────────────────────
                _PitchThreeDTab(session: session),
                // ─── Diagnostics ─────────────────────────────────────────
                _DiagnosticsTab(session: session),
                // ─── JSON Preview ─────────────────────────────────────────
                _JsonPreviewTab(session: session),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Analysis Video Tab ───────────────────────────────────────────────────────
class _AnalysisVideoTab extends StatefulWidget {
  final CricketSession session;
  const _AnalysisVideoTab({required this.session});

  @override
  State<_AnalysisVideoTab> createState() => _AnalysisVideoTabState();
}

class _AnalysisVideoTabState extends State<_AnalysisVideoTab> {
  int _selectedIdx = 0;
  double _videoPos = 0;
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final accepted = widget.session.acceptedDeliveries;
    if (accepted.isEmpty) {
      return const Center(
        child: Text('No accepted deliveries to display', style: AppTextStyles.bodyMedium),
      );
    }
    final d = accepted[_selectedIdx];
    final m = d.trajectory.metrics;

    return Column(
      children: [
        // Video player mock
        Container(
          height: 200,
          margin: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.sports_cricket_rounded, color: AppColors.border, size: 72),
              // Red trajectory overlay
              CustomPaint(
                painter: _VideoOverlayPainter(progress: _videoPos),
                size: Size.infinite,
              ),
              // Metrics panel
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _metricRow('${m.speedKmh.toStringAsFixed(1)} km/h', AppColors.cyan),
                      _metricRow('${m.spinRpm.toStringAsFixed(0)} rpm', AppColors.phasePostBounce),
                      _metricRow('${m.swingDeg.toStringAsFixed(1)}°', AppColors.phaseBounce),
                      _metricRow(m.line, AppColors.textSecondary),
                      _metricRow(m.length, AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Playback controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _playing ? Icons.pause : Icons.play_arrow,
                  color: AppColors.green,
                ),
                onPressed: () => setState(() => _playing = !_playing),
              ),
              Expanded(
                child: Slider(
                  value: _videoPos,
                  onChanged: (v) => setState(() => _videoPos = v),
                ),
              ),
            ],
          ),
        ),
        // Delivery selector
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: accepted.length,
            itemBuilder: (_, i) {
              final del = accepted[i];
              return ListTile(
                selected: i == _selectedIdx,
                selectedTileColor: AppColors.greenGlow,
                onTap: () => setState(() {
                  _selectedIdx = i;
                  _videoPos = 0;
                }),
                title: Text('Delivery ${del.number}'),
                subtitle: Text(
                  '${del.speedKmh.toStringAsFixed(1)} km/h  ·  ${del.line.label}  ·  ${del.length.label}',
                ),
                trailing: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _statusColor(del.status),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _metricRow(String text, Color color) => Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      );

  Color _statusColor(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.accepted:
        return AppColors.accepted;
      case DeliveryStatus.uncertain:
        return AppColors.uncertain;
      case DeliveryStatus.rejected:
        return AppColors.rejected;
    }
  }
}

// ─── Pitch/3D Tab ─────────────────────────────────────────────────────────────
class _PitchThreeDTab extends StatelessWidget {
  final CricketSession session;
  const _PitchThreeDTab({required this.session});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.view_in_ar_rounded, color: AppColors.cyan, size: 64),
            const SizedBox(height: AppSpacing.md),
            const Text('Pitch Map & 3D View', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Switch to the Pitch Map or 3D Trajectory tabs above for interactive views.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.map_rounded),
                    label: const Text('Pitch Map'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.view_in_ar_rounded),
                    label: const Text('3D View'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Diagnostics Tab ──────────────────────────────────────────────────────────
class _DiagnosticsTab extends StatelessWidget {
  final CricketSession session;
  const _DiagnosticsTab({required this.session});

  @override
  Widget build(BuildContext context) {
    final mockTimings = [
      (AppStrings.stage1, '0.42s'),
      (AppStrings.stage2, '1.23s'),
      (AppStrings.stage3, '2.87s'),
      (AppStrings.stage4, '3.14s'),
      (AppStrings.stage5, '1.95s'),
      (AppStrings.stage6, '0.31s'),
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Download buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showMockDownload(context, 'CSV'),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download CSV'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showMockDownload(context, 'JSON'),
                icon: const Icon(Icons.code_rounded, size: 18),
                label: const Text('Download JSON'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Stage timings
        const Text('Pipeline Stage Timings', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        ...mockTimings.map(
          (t) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.xs),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 14),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(t.$1, style: AppTextStyles.bodyMedium),
                ),
                Text(
                  t.$2,
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
        // Logs panel
        const Text('Processing Log', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0F0A),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LogLine('[INFO] Session: ${session.id}', AppColors.textSecondary),
              _LogLine('[INFO] Total deliveries: ${session.totalBalls}', AppColors.textSecondary),
              _LogLine('[OK] Accepted: ${session.acceptedCount}', AppColors.green),
              _LogLine('[WARN] Uncertain: ${session.uncertainCount}', AppColors.uncertain),
              _LogLine('[ERR] Rejected: ${session.rejectedCount}', AppColors.rejected),
              _LogLine('[INFO] Pipeline v4.0 completed successfully', AppColors.cyan),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  void _showMockDownload(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$format export ready (mock) — no file written in UI prototype'),
        backgroundColor: AppColors.card,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _LogLine extends StatelessWidget {
  final String text;
  final Color color;
  const _LogLine(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: color,
        ),
      ),
    );
  }
}

// ─── JSON Preview Tab ─────────────────────────────────────────────────────────
class _JsonPreviewTab extends StatefulWidget {
  final CricketSession session;
  const _JsonPreviewTab({required this.session});

  @override
  State<_JsonPreviewTab> createState() => _JsonPreviewTabState();
}

class _JsonPreviewTabState extends State<_JsonPreviewTab> {
  int _selectedIdx = 0;
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final accepted = widget.session.acceptedDeliveries;
    if (accepted.isEmpty) {
      return const Center(child: Text('No data', style: AppTextStyles.bodyMedium));
    }

    final trajectory = accepted[_selectedIdx].trajectory;
    final jsonStr = const JsonEncoder.withIndent('  ').convert(trajectory.toJson());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Text('Delivery: ', style: AppTextStyles.labelMedium),
              const SizedBox(width: AppSpacing.sm),
              DropdownButton<int>(
                value: _selectedIdx,
                dropdownColor: AppColors.card,
                items: accepted.asMap().entries.map((e) {
                  return DropdownMenuItem(
                    value: e.key,
                    child: Text('Del. ${e.value.number}',
                        style: AppTextStyles.bodyMedium),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedIdx = v ?? 0),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _copied ? Icons.check : Icons.copy,
                  color: AppColors.green,
                  size: 20,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonStr));
                  setState(() => _copied = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) setState(() => _copied = false);
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0F0A),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: SelectableText(
                jsonStr,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: AppColors.green,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─── Video overlay painter ────────────────────────────────────────────────────
class _VideoOverlayPainter extends CustomPainter {
  final double progress;
  _VideoOverlayPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = AppColors.rejected.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    const steps = 40;
    final endStep = (steps * progress).toInt().clamp(1, steps);

    final startX = size.width * 0.1;
    final startY = size.height * 0.2;

    for (int i = 1; i <= endStep; i++) {
      final t = i / steps;
      final x = startX + (size.width * 0.8) * t;
      final y = startY + (size.height * 0.5) * t - 40 * (t - t * t) * 4;

      if (i == 1) {
        path.moveTo(x, y.clamp(0.0, size.height));
      } else {
        path.lineTo(x, y.clamp(0.0, size.height));
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _VideoOverlayPainter old) => old.progress != progress;
}
