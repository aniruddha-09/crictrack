// lib/features/record/widgets/rec_overlay.dart

import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../core/strings.dart';

class RecOverlay extends StatefulWidget {
  final bool isRecording;
  final int elapsed;
  final int ballsDetected;

  const RecOverlay({
    super.key,
    required this.isRecording,
    required this.elapsed,
    required this.ballsDetected,
  });

  @override
  State<RecOverlay> createState() => _RecOverlayState();
}

class _RecOverlayState extends State<RecOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkCtrl;

  @override
  void initState() {
    super.initState();
    _blinkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkCtrl.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 48,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Blinking REC dot
              AnimatedBuilder(
                animation: _blinkCtrl,
                builder: (_, __) => Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.rejected.withValues(
                      alpha: _blinkCtrl.value,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.rec,
                style: const TextStyle(
                  color: AppColors.rejected,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatTime(widget.elapsed),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 12),
              const VerticalDivider(color: Colors.white24, thickness: 1, width: 1),
              const SizedBox(width: 12),
              const Icon(
                Icons.sports_cricket_rounded,
                color: AppColors.green,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.ballsDetected} ${AppStrings.ballsDetected}',
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
