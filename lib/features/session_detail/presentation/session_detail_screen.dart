// lib/features/session_detail/presentation/session_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/strings.dart';
import '../../../app/providers.dart';
import '../../../data/models/session.dart';
import '../../../data/models/enums.dart';
import '../widgets/deliveries_tab.dart';
import '../widgets/pitch_map_tab.dart';
import '../widgets/stats_tab.dart';
import '../widgets/outputs_tab.dart';
import '../../trajectory/presentation/trajectory_tab.dart';

class SessionDetailScreen extends ConsumerWidget {
  final String sessionId;
  final int initialTab;

  const SessionDetailScreen({
    super.key,
    required this.sessionId,
    this.initialTab = 0,
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
      data: (session) => _SessionDetailView(
        session: session,
        initialTab: initialTab,
      ),
    );
  }
}

class _SessionDetailView extends StatefulWidget {
  final CricketSession session;
  final int initialTab;

  const _SessionDetailView({
    required this.session,
    required this.initialTab,
  });

  @override
  State<_SessionDetailView> createState() => _SessionDetailViewState();
}

class _SessionDetailViewState extends State<_SessionDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _tabLabels = [
    AppStrings.deliveries,
    AppStrings.pitchMap,
    AppStrings.trajectory3D,
    AppStrings.stats,
    AppStrings.outputs,
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _showShare(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _SessionHeader(session: s),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            DeliveriesTab(session: widget.session),
            PitchMapTab(session: widget.session),
            TrajectoryTab(session: widget.session),
            StatsTab(session: widget.session),
            OutputsTab(session: widget.session),
          ],
        ),
      ),
    );
  }

  void _showShare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (_) => _ShareBottomSheet(session: widget.session),
    );
  }
}

// ─── Session Header ───────────────────────────────────────────────────────────
class _SessionHeader extends StatelessWidget {
  final CricketSession session;
  const _SessionHeader({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.background,
            AppColors.surface.withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 56,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TypeBadge(type: session.type),
              const SizedBox(width: AppSpacing.sm),
              Text(
                DateFormat('d MMM y').format(session.date),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(session.title, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(session.location, style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Summary stats row
          Row(
            children: [
              _SummaryChip(
                label: '${session.totalBalls}',
                sublabel: 'Balls',
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              _SummaryChip(
                label: session.avgSpeed.toStringAsFixed(1),
                sublabel: 'Avg km/h',
                color: AppColors.cyan,
              ),
              const SizedBox(width: AppSpacing.sm),
              _SummaryChip(
                label: session.maxSpeed.toStringAsFixed(1),
                sublabel: 'Max km/h',
                color: AppColors.uncertain,
              ),
              const SizedBox(width: AppSpacing.sm),
              // Status counts
              _StatusMini(
                accepted: session.acceptedCount,
                uncertain: session.uncertainCount,
                rejected: session.rejectedCount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final SessionType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final isMatch = type == SessionType.match;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isMatch ? AppColors.greenGlow : AppColors.cyanGlow,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        isMatch ? 'MATCH' : 'PRACTICE',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: isMatch ? AppColors.green : AppColors.cyan,
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  const _SummaryChip({
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(sublabel, style: AppTextStyles.bodySmall),
      ],
    );
  }
}

class _StatusMini extends StatelessWidget {
  final int accepted;
  final int uncertain;
  final int rejected;
  const _StatusMini({
    required this.accepted,
    required this.uncertain,
    required this.rejected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(AppColors.accepted, '$accepted A'),
        const SizedBox(width: 6),
        _dot(AppColors.uncertain, '$uncertain U'),
        const SizedBox(width: 6),
        _dot(AppColors.rejected, '$rejected R'),
      ],
    );
  }

  Widget _dot(Color color, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
}

class _ShareBottomSheet extends StatefulWidget {
  final CricketSession session;
  const _ShareBottomSheet({required this.session});

  @override
  State<_ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<_ShareBottomSheet> {
  bool _copied = false;
  final _selected = <String>{};

  final _teammates = [
    ('t1', 'Arjun Sharma', 'AS'),
    ('t2', 'Priya Mehta', 'PM'),
    ('t3', 'Rohan Patel', 'RP'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(AppStrings.shareSession, style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          ..._teammates.map((t) => CheckboxListTile(
                value: _selected.contains(t.$1),
                onChanged: (_) => setState(() {
                  _selected.contains(t.$1)
                      ? _selected.remove(t.$1)
                      : _selected.add(t.$1);
                }),
                title: Text(t.$2, style: AppTextStyles.titleMedium),
                secondary: CircleAvatar(
                  backgroundColor: AppColors.greenGlow,
                  child: Text(
                    t.$3,
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                activeColor: AppColors.green,
                checkColor: Colors.black,
                contentPadding: EdgeInsets.zero,
              )),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _copied = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _copied = false);
                    });
                  },
                  icon: Icon(_copied ? Icons.check : Icons.copy),
                  label: Text(_copied ? 'Copied!' : AppStrings.copyLink),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.send),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
