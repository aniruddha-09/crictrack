// lib/features/sessions/widgets/session_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../data/models/session.dart';
import '../../../data/models/enums.dart';

class SessionCard extends StatelessWidget {
  final CricketSession session;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: session.type == SessionType.practice
                        ? AppColors.cyanGlow
                        : AppColors.greenGlow,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    session.type == SessionType.practice ? 'PRACTICE' : 'MATCH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: session.type == SessionType.practice
                          ? AppColors.cyan
                          : AppColors.green,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('d MMM y').format(session.date),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(session.title, style: AppTextStyles.titleLarge),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 12,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(session.location, style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _StatPill(
                  label: '${session.totalBalls} balls',
                  icon: Icons.sports_cricket_rounded,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatPill(
                  label: '${session.avgSpeed.toStringAsFixed(1)} km/h avg',
                  icon: Icons.speed_rounded,
                  color: AppColors.cyan,
                ),
                const SizedBox(width: AppSpacing.sm),
                // Status counts
                _StatusCount(
                  accepted: session.acceptedCount,
                  uncertain: session.uncertainCount,
                  rejected: session.rejectedCount,
                ),
                const Spacer(),
                IconButton(
                  onPressed: onShare,
                  icon: const Icon(
                    Icons.share_rounded,
                    color: AppColors.textMuted,
                  ),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatPill({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusCount extends StatelessWidget {
  final int accepted;
  final int uncertain;
  final int rejected;

  const _StatusCount({
    required this.accepted,
    required this.uncertain,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(AppColors.accepted),
        const SizedBox(width: 2),
        Text(
          '$accepted',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.accepted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        _dot(AppColors.uncertain),
        const SizedBox(width: 2),
        Text(
          '$uncertain',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.uncertain,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        _dot(AppColors.rejected),
        const SizedBox(width: 2),
        Text(
          '$rejected',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.rejected,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _dot(Color color) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
