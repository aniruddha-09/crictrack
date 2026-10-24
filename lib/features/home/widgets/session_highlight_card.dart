// lib/features/home/widgets/session_highlight_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../data/models/delivery.dart';
import '../../../data/models/enums.dart';

class SessionHighlightCard extends StatelessWidget {
  final Delivery delivery;
  final String sessionId;

  const SessionHighlightCard({
    super.key,
    required this.delivery,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/session/$sessionId?tab=0'),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder with speed overlay
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surfaceVariant,
                          AppColors.background.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppColors.textMuted,
                        size: 36,
                      ),
                    ),
                  ),
                  // Speed chip
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '${delivery.speedKmh.toStringAsFixed(0)} km/h',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // Status chip
                  if (delivery.status != DeliveryStatus.accepted)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: delivery.status == DeliveryStatus.uncertain
                              ? AppColors.uncertain
                              : AppColors.rejected,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Del. ${delivery.number}',
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${delivery.line.label} · ${delivery.length.label}',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
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
