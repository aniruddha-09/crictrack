// lib/features/home/presentation/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/strings.dart';
import '../../../app/providers.dart';
import '../../../data/models/session.dart';
import '../widgets/quick_stat_card.dart';
import '../widgets/session_highlight_card.dart';
import '../widgets/mini_pitch_map.dart';
import '../../record/widgets/new_session_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final sessionsAsync = ref.watch(sessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            snap: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  auth.user?.name ?? 'Cricketer',
                  style: AppTextStyles.headlineSmall,
                ),
              ],
            ),
            actions: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.greenGlow,
                child: Text(
                  auth.user?.avatarInitials ?? 'U',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.md),

                // ── Start New Session Card ─────────────────────────────────
                _StartSessionCard(),

                const SizedBox(height: AppSpacing.lg),

                // ── Quick Stats ───────────────────────────────────────────
                sessionsAsync.when(
                  loading: () => const _QuickStatsShimmer(),
                  error: (e, _) => const SizedBox(),
                  data: (sessions) => _QuickStatsRow(sessions: sessions),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Last Session ──────────────────────────────────────────
                sessionsAsync.when(
                  loading: () => const SizedBox(
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (e, _) => const SizedBox(),
                  data: (sessions) {
                    if (sessions.isEmpty) return const SizedBox();
                    return _LastSessionCard(session: sessions.first);
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Highlights ───────────────────────────────────────────
                sessionsAsync.when(
                  loading: () => const SizedBox(),
                  error: (e, _) => const SizedBox(),
                  data: (sessions) {
                    if (sessions.isEmpty) return const SizedBox();
                    return _HighlightsSection(sessions: sessions);
                  },
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Start Session Card ────────────────────────────────────────────────────────
class _StartSessionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => NewSessionSheet.show(context),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F4C2A), Color(0xFF0B2D1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.videocam_rounded,
                color: Colors.black,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.startNewSession,
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.startNewSessionSubtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.green,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Stats Row ──────────────────────────────────────────────────────────
class _QuickStatsRow extends StatelessWidget {
  final List<CricketSession> sessions;

  const _QuickStatsRow({required this.sessions});

  @override
  Widget build(BuildContext context) {
    // Only count sessions from the last 7 days
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekSessions =
        sessions.where((s) => s.date.isAfter(weekAgo)).toList();

    final totalBalls = weekSessions.fold<int>(0, (acc, s) => acc + s.totalBalls);
    final topSpeed = sessions.isNotEmpty
        ? sessions.map((s) => s.maxSpeed).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final avgSpin = sessions.isNotEmpty
        ? sessions.map((s) => s.avgSpin).reduce((a, b) => a + b) /
            sessions.length
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(AppStrings.quickStats, style: AppTextStyles.headlineSmall),
            TextButton(
              onPressed: () => context.go('/sessions'),
              child: const Text(AppStrings.viewAll),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: QuickStatCard(
                label: 'Sessions\nThis Week',
                value: weekSessions.length.toString(),
                icon: Icons.calendar_today_rounded,
                color: AppColors.cyan,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: QuickStatCard(
                label: 'Balls\nBowled',
                value: totalBalls.toString(),
                icon: Icons.sports_cricket_rounded,
                color: AppColors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: QuickStatCard(
                label: 'Top Speed\n(km/h)',
                value: topSpeed.toStringAsFixed(1),
                icon: Icons.speed_rounded,
                color: AppColors.uncertain,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: QuickStatCard(
                label: 'Avg Spin\n(rpm)',
                value: avgSpin.toStringAsFixed(0),
                icon: Icons.rotate_right_rounded,
                color: AppColors.phasePostBounce,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Last Session Card ────────────────────────────────────────────────────────
class _LastSessionCard extends StatelessWidget {
  final CricketSession session;

  const _LastSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(AppStrings.lastSession, style: AppTextStyles.headlineSmall),
            TextButton(
              onPressed: () => context.push('/session/${session.id}'),
              child: const Text('Details'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => context.push('/session/${session.id}'),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Mini pitch map thumbnail
                SizedBox(
                  width: 90,
                  height: 90,
                  child: MiniPitchMap(deliveries: session.deliveries.take(15).toList()),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.title, style: AppTextStyles.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEE, d MMM y').format(session.date),
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          _MiniStat(
                            label: '${session.totalBalls} balls',
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _MiniStat(
                            label: '${session.avgSpeed.toStringAsFixed(1)} km/h',
                            color: AppColors.cyan,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniStat({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── Highlights Section ───────────────────────────────────────────────────────
class _HighlightsSection extends StatelessWidget {
  final List<CricketSession> sessions;

  const _HighlightsSection({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final deliveries = sessions.expand((s) => s.deliveries).take(10).toList()
      ..sort((a, b) => b.speedKmh.compareTo(a.speedKmh));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(AppStrings.highlights, style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: deliveries.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (ctx, i) {
              final d = deliveries[i];
              return SessionHighlightCard(
                delivery: d,
                sessionId: sessions
                    .firstWhere(
                      (s) => s.deliveries.any((del) => del.id == d.id),
                    )
                    .id,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickStatsShimmer extends StatelessWidget {
  const _QuickStatsShimmer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 140,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
