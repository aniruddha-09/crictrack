// lib/features/record/presentation/processing_screen.dart
// Shown after stopping recording. Animates through 6 V4 pipeline stages.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/strings.dart';
import '../../../data/models/enums.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  final String sessionId;
  const ProcessingScreen({super.key, required this.sessionId});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  int _currentStage = 0;
  final _stageStatuses = List.filled(6, ProcessingStageStatus.pending);
  Timer? _timer;
  bool _done = false;

  final _stageLabels = [
    AppStrings.stage1,
    AppStrings.stage2,
    AppStrings.stage3,
    AppStrings.stage4,
    AppStrings.stage5,
    AppStrings.stage6,
  ];

  @override
  void initState() {
    super.initState();
    _advanceStage();
  }

  void _advanceStage() {
    if (_currentStage >= 6) {
      setState(() => _done = true);
      // Auto-navigate to session detail after 1s
      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          // TODO(backend): Navigate to the actual processed session ID
          context.go('/session/session_001');
        }
      });
      return;
    }

    setState(() {
      _stageStatuses[_currentStage] = ProcessingStageStatus.running;
    });

    final delay = Duration(milliseconds: 1200 + (_currentStage * 200));
    _timer = Timer(delay, () {
      if (!mounted) return;
      setState(() {
        _stageStatuses[_currentStage] = ProcessingStageStatus.done;
        _currentStage++;
      });
      _advanceStage();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Animated logo
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (_, v, child) => Opacity(opacity: v, child: child),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.green.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.analytics_rounded,
                    color: Colors.black,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _done ? 'Analysis Complete!' : AppStrings.processing,
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _done
                    ? 'Your session is ready to view.'
                    : _currentStage < 6
                        ? _stageLabels[_currentStage]
                        : '',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: LinearProgressIndicator(
                  value: _currentStage / 6,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.green),
                ),
              ),
              Text(
                '${(_currentStage / 6 * 100).toInt()}%',
                style: AppTextStyles.bodySmall,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Stage stepper
              Expanded(
                child: ListView.separated(
                  itemCount: 6,
                  separatorBuilder: (_, idx) => _StageLine(
                    active: _stageStatuses[idx < 5 ? idx : 4] == ProcessingStageStatus.done,
                  ),
                  itemBuilder: (_, i) => _StageItem(
                    label: _stageLabels[i],
                    stageNum: i + 1,
                    status: _stageStatuses[i],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageItem extends StatelessWidget {
  final String label;
  final int stageNum;
  final ProcessingStageStatus status;

  const _StageItem({
    required this.label,
    required this.stageNum,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon, bg) = switch (status) {
      ProcessingStageStatus.done => (AppColors.green, Icons.check_rounded, AppColors.greenGlow),
      ProcessingStageStatus.running => (AppColors.cyan, Icons.circle, AppColors.cyanGlow),
      ProcessingStageStatus.failed => (AppColors.rejected, Icons.close_rounded, const Color(0x33EF4444)),
      ProcessingStageStatus.pending => (AppColors.textMuted, null, AppColors.surfaceVariant),
    };

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: status == ProcessingStageStatus.running
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : icon != null
                    ? Icon(icon, color: color, size: 16)
                    : Text(
                        '$stageNum',
                        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: status == ProcessingStageStatus.pending
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
              ),
              if (status == ProcessingStageStatus.running)
                Text(
                  'Processing...',
                  style: TextStyle(fontSize: 11, color: color),
                ),
              if (status == ProcessingStageStatus.done)
                const Text(
                  'Completed',
                  style: TextStyle(fontSize: 11, color: AppColors.green),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StageLine extends StatelessWidget {
  final bool active;
  const _StageLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 17),
      child: Container(
        width: 2,
        height: 20,
        color: active ? AppColors.green : AppColors.border,
      ),
    );
  }
}
