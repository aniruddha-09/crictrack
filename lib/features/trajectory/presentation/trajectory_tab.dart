// lib/features/trajectory/presentation/trajectory_tab.dart
// Container for selecting a delivery and viewing its 3D trajectory.

import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/session.dart';
import '../../../data/models/delivery.dart';
import '../../../data/models/enums.dart';
import '../widgets/trajectory_3d_viewer.dart';

class TrajectoryTab extends StatefulWidget {
  final CricketSession session;

  const TrajectoryTab({super.key, required this.session});

  @override
  State<TrajectoryTab> createState() => _TrajectoryTabState();
}

class _TrajectoryTabState extends State<TrajectoryTab> {
  late Delivery _selectedDelivery;

  @override
  void initState() {
    super.initState();
    _selectedDelivery = widget.session.deliveries.firstWhere(
      (d) => d.status == DeliveryStatus.accepted,
      orElse: () => widget.session.deliveries.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Delivery selector
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            itemCount: widget.session.deliveries.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (ctx, i) {
              final d = widget.session.deliveries[i];
              final isSelected = d.id == _selectedDelivery.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedDelivery = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.green : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.green
                          : _deliveryBorderColor(d.status),
                    ),
                  ),
                  child: Text(
                    '${d.number}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.black
                          : _deliveryTextColor(d.status),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 3D viewer
        Expanded(
          child: Trajectory3DViewer(
            trajectory: _selectedDelivery.trajectory,
            deliveryNumber: _selectedDelivery.number,
          ),
        ),
      ],
    );
  }

  Color _deliveryBorderColor(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.accepted:
        return AppColors.border;
      case DeliveryStatus.uncertain:
        return AppColors.uncertain.withValues(alpha: 0.5);
      case DeliveryStatus.rejected:
        return AppColors.rejected.withValues(alpha: 0.4);
    }
  }

  Color _deliveryTextColor(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.accepted:
        return AppColors.textSecondary;
      case DeliveryStatus.uncertain:
        return AppColors.uncertain;
      case DeliveryStatus.rejected:
        return AppColors.rejected;
    }
  }
}
