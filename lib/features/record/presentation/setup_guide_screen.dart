// lib/features/record/presentation/setup_guide_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/strings.dart';

class SetupGuideScreen extends StatefulWidget {
  const SetupGuideScreen({super.key});

  @override
  State<SetupGuideScreen> createState() => _SetupGuideScreenState();
}

class _SetupGuideScreenState extends State<SetupGuideScreen>
    with SingleTickerProviderStateMixin {
  final _checklist = <bool>[false, false, false, false, false, false];

  final _steps = [
    (AppStrings.step1, Icons.sports_cricket_rounded),
    (AppStrings.step2, Icons.sports_cricket_rounded),
    (AppStrings.step3, Icons.camera_alt_rounded),
    (AppStrings.step4, Icons.location_on_rounded),
    (AppStrings.step5, Icons.screen_rotation_rounded),
    (AppStrings.step6, Icons.wb_sunny_rounded),
  ];

  bool get _allChecked => _checklist.every((c) => c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.setupGuide),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.setupTitle,
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    AppStrings.setupSubtitle,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Pitch diagram
                  _PitchDiagram(),
                  const SizedBox(height: AppSpacing.lg),

                  // Checklist
                  const Text(
                    'Checklist',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...List.generate(_steps.length, (i) {
                    return _ChecklistItem(
                      icon: _steps[i].$2,
                      label: _steps[i].$1,
                      stepNumber: i + 1,
                      checked: _checklist[i],
                      onTap: () => setState(() => _checklist[i] = !_checklist[i]),
                    );
                  }),
                  const SizedBox(height: AppSpacing.lg),
                  if (_allChecked)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.greenGlow,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.green.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppColors.green),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'All set! You\'re ready to record.',
                              style: TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton.icon(
                onPressed: _allChecked
                    ? () => context.push('/recording')
                    : null,
                icon: const Icon(Icons.videocam_rounded),
                label: Text(
                  _allChecked
                      ? AppStrings.startRecording
                      : 'Complete checklist to continue',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int stepNumber;
  final bool checked;
  final VoidCallback onTap;

  const _ChecklistItem({
    required this.icon,
    required this.label,
    required this.stepNumber,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: checked ? AppColors.greenGlow : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: checked ? AppColors.green : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: checked ? AppColors.green : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: checked
                    ? const Icon(Icons.check_rounded, color: Colors.black, size: 18)
                    : Text(
                        '$stepNumber',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Icon(
              icon,
              color: checked ? AppColors.green : AppColors.textMuted,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: checked ? AppColors.green : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pitch Diagram (CustomPainter) ────────────────────────────────────────────
class _PitchDiagram extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: CustomPaint(
        painter: _PitchDiagramPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _PitchDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Pitch rectangle (top-down view)
    final pitchLeft = w * 0.25;
    final pitchRight = w * 0.75;
    final pitchTop = h * 0.08;
    final pitchBottom = h * 0.85;
    final pitchWidth = pitchRight - pitchLeft;
    final pitchHeight = pitchBottom - pitchTop;

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF1A2A1A),
    );

    // Pitch surface
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pitchLeft, pitchTop, pitchWidth, pitchHeight),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF8B6914).withValues(alpha: 0.6),
    );

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Batting crease (top)
    canvas.drawLine(
      Offset(pitchLeft, pitchTop + pitchHeight * 0.12),
      Offset(pitchRight, pitchTop + pitchHeight * 0.12),
      linePaint,
    );
    // Bowling crease (bottom)
    canvas.drawLine(
      Offset(pitchLeft, pitchBottom - pitchHeight * 0.12),
      Offset(pitchRight, pitchBottom - pitchHeight * 0.12),
      linePaint,
    );

    // Stumps (top, 3 lines)
    _drawStumps(canvas, Offset(w * 0.5, pitchTop + pitchHeight * 0.08), 18.0);
    _drawStumps(canvas, Offset(w * 0.5, pitchBottom - pitchHeight * 0.08), 18.0);

    // Camera position marker
    final camY = pitchBottom + h * 0.06;
    final camX = w * 0.5;
    canvas.drawCircle(
      Offset(camX, camY),
      10,
      Paint()..color = AppColors.cyan.withValues(alpha: 0.8),
    );
    // Camera icon symbol
    final cameraPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(camX, camY), width: 14, height: 10),
      cameraPaint,
    );

    // Distance label
    final tp = _buildTextPainter('~4m', AppColors.cyan, 10);
    tp.layout();
    tp.paint(canvas, Offset(camX + 14, camY - 5));

    // Tripod label
    final tp2 = _buildTextPainter('Camera', AppColors.cyan, 9);
    tp2.layout();
    tp2.paint(canvas, Offset(camX - tp2.width / 2, camY + 14));

    // Labels
    final bowlerLabel = _buildTextPainter('Bowler End', Colors.white54, 10);
    bowlerLabel.layout();
    bowlerLabel.paint(
      canvas,
      Offset(pitchLeft - bowlerLabel.width - 6, pitchBottom - 12),
    );

    final batsmanLabel = _buildTextPainter("Batter's End", Colors.white54, 10);
    batsmanLabel.layout();
    batsmanLabel.paint(
      canvas,
      Offset(pitchLeft - batsmanLabel.width - 6, pitchTop + 4),
    );
  }

  void _drawStumps(Canvas canvas, Offset center, double width) {
    final stumpPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final gap = width / 3;
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(center.dx + i * gap, center.dy - 6),
        Offset(center.dx + i * gap, center.dy + 6),
        stumpPaint,
      );
    }
    // Bails
    canvas.drawLine(
      Offset(center.dx - gap, center.dy - 6),
      Offset(center.dx + gap, center.dy - 6),
      stumpPaint,
    );
  }

  TextPainter _buildTextPainter(String text, Color color, double size) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
