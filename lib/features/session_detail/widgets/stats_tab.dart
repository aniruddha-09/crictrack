// lib/features/session_detail/widgets/stats_tab.dart
// fl_chart line chart of speed across deliveries + bar chart of line/length distribution.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme.dart';
import '../../../data/models/session.dart';
import '../../../data/models/enums.dart';

class StatsTab extends StatelessWidget {
  final CricketSession session;

  const StatsTab({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final accepted = session.acceptedDeliveries;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Speed chart
        _SectionTitle('Speed Across Deliveries'),
        const SizedBox(height: AppSpacing.sm),
        _SpeedChart(deliveries: accepted),
        const SizedBox(height: AppSpacing.lg),

        // Line distribution
        _SectionTitle('Line Distribution'),
        const SizedBox(height: AppSpacing.sm),
        _LineBarChart(deliveries: accepted),
        const SizedBox(height: AppSpacing.lg),

        // Length distribution
        _SectionTitle('Length Distribution'),
        const SizedBox(height: AppSpacing.sm),
        _LengthBarChart(deliveries: accepted),
        const SizedBox(height: AppSpacing.lg),

        // Track health
        _SectionTitle('Track Health Overview'),
        const SizedBox(height: AppSpacing.sm),
        _TrackHealthChart(session: session),
        const SizedBox(height: AppSpacing.lg),

        // Summary stats grid
        _SectionTitle('Summary'),
        const SizedBox(height: AppSpacing.sm),
        _SummaryGrid(session: session),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(title, style: AppTextStyles.headlineSmall);
}

// ─── Speed Line Chart ─────────────────────────────────────────────────────────
class _SpeedChart extends StatelessWidget {
  final List<dynamic> deliveries;

  const _SpeedChart({required this.deliveries});

  @override
  Widget build(BuildContext context) {
    if (deliveries.isEmpty) {
      return const Center(child: Text('No accepted deliveries', style: AppTextStyles.bodyMedium));
    }

    final spots = deliveries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.speedKmh);
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: LineChart(
        LineChartData(
          minY: 100,
          maxY: 150,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.border,
              strokeWidth: 0.8,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt() + 1}',
                  style: AppTextStyles.bodySmall,
                ),
                interval: (deliveries.length / 5).ceilToDouble().clamp(1, double.infinity),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: AppTextStyles.bodySmall,
                ),
                interval: 10,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.cyan,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.cyan,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.cyan.withValues(alpha: 0.2),
                    AppColors.cyan.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                return LineTooltipItem(
                  '${s.y.toStringAsFixed(1)} km/h',
                  const TextStyle(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Line Bar Chart ───────────────────────────────────────────────────────────
class _LineBarChart extends StatelessWidget {
  final List<dynamic> deliveries;

  const _LineBarChart({required this.deliveries});

  @override
  Widget build(BuildContext context) {
    final offCount = deliveries.where((d) => d.line == DeliveryLine.off).length;
    final midCount = deliveries.where((d) => d.line == DeliveryLine.middle).length;
    final legCount = deliveries.where((d) => d.line == DeliveryLine.leg).length;
    final total = deliveries.length.toDouble();
    if (total == 0) return const SizedBox();

    return Container(
      height: 140,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: total,
          barGroups: [
            _makeBar(0, offCount.toDouble(), AppColors.phaseRelease),
            _makeBar(1, midCount.toDouble(), AppColors.green),
            _makeBar(2, legCount.toDouble(), AppColors.phasePostBounce),
          ],
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final labels = ['Off', 'Middle', 'Leg'];
                  return Text(
                    v.toInt() < labels.length ? labels[v.toInt()] : '',
                    style: AppTextStyles.bodySmall,
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final labels = ['Off', 'Middle', 'Leg'];
                return BarTooltipItem(
                  '${labels[groupIndex]}: ${rod.toY.toInt()}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}

// ─── Length Bar Chart ─────────────────────────────────────────────────────────
class _LengthBarChart extends StatelessWidget {
  final List<dynamic> deliveries;

  const _LengthBarChart({required this.deliveries});

  @override
  Widget build(BuildContext context) {
    final counts = {
      'Yorker': deliveries.where((d) => d.length == DeliveryLength.yorker).length,
      'Full': deliveries.where((d) => d.length == DeliveryLength.full).length,
      'Good': deliveries.where((d) => d.length == DeliveryLength.good).length,
      'Short': deliveries.where((d) => d.length == DeliveryLength.short).length,
    };
    final total = deliveries.length.toDouble();
    if (total == 0) return const SizedBox();

    final colors = [
      AppColors.rejected,
      AppColors.uncertain,
      AppColors.green,
      AppColors.cyan,
    ];

    return Container(
      height: 140,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: total,
          barGroups: counts.entries.toList().asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  color: colors[e.key],
                  width: 22,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final labels = counts.keys.toList();
                  return Text(
                    v.toInt() < labels.length ? labels[v.toInt()] : '',
                    style: AppTextStyles.bodySmall,
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
}

// ─── Track Health Chart ───────────────────────────────────────────────────────
class _TrackHealthChart extends StatelessWidget {
  final CricketSession session;

  const _TrackHealthChart({required this.session});

  @override
  Widget build(BuildContext context) {
    // Aggregate average track health per frame across accepted deliveries
    final accepted = session.acceptedDeliveries;
    if (accepted.isEmpty) return const SizedBox();

    final avgHealth = <FlSpot>[];
    const frames = 30;
    for (int f = 0; f < frames; f++) {
      double sum = 0;
      int count = 0;
      for (final d in accepted) {
        if (f < d.trajectory.trackHealth.length) {
          sum += d.trajectory.trackHealth[f];
          count++;
        }
      }
      if (count > 0) {
        avgHealth.add(FlSpot(f.toDouble(), sum / count));
      }
    }

    return Container(
      height: 140,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 1.0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.border, strokeWidth: 0.8),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (v, _) => Text(
                  '${(v * 100).toInt()}%',
                  style: AppTextStyles.bodySmall,
                ),
                interval: 0.25,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: avgHealth,
              isCurved: true,
              color: AppColors.green,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.green.withValues(alpha: 0.25),
                    AppColors.green.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Summary Grid ─────────────────────────────────────────────────────────────
class _SummaryGrid extends StatelessWidget {
  final CricketSession session;

  const _SummaryGrid({required this.session});

  @override
  Widget build(BuildContext context) {
    final accepted = session.acceptedDeliveries;
    final dotBall = accepted.isNotEmpty
        ? (accepted.where((d) => d.speedKmh < 120).length / accepted.length * 100)
        : 0.0;
    final avgSwing = accepted.isNotEmpty
        ? accepted.map((d) => d.swingDeg).reduce((a, b) => a + b) / accepted.length
        : 0.0;

    final stats = [
      ('Avg Speed', '${session.avgSpeed.toStringAsFixed(1)} km/h', AppColors.cyan),
      ('Max Speed', '${session.maxSpeed.toStringAsFixed(1)} km/h', AppColors.rejected),
      ('Avg Spin', '${session.avgSpin.toStringAsFixed(0)} rpm', AppColors.phasePostBounce),
      ('Avg Swing', '${avgSwing.toStringAsFixed(1)}°', AppColors.phaseBounce),
      ('Dot Ball %', '${dotBall.toStringAsFixed(1)}%', AppColors.green),
      ('Accepted', '${session.acceptedCount}/${session.totalBalls}', AppColors.accepted),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) {
        final (label, value, color) = stats[i];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
