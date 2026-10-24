// lib/features/sessions/presentation/sessions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/strings.dart';
import '../../../app/providers.dart';
import '../../../data/models/session.dart';
import '../../../data/models/enums.dart';
import '../widgets/session_card.dart';
import '../../record/widgets/new_session_sheet.dart';

class SessionsScreen extends ConsumerStatefulWidget {
  const SessionsScreen({super.key});

  @override
  ConsumerState<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends ConsumerState<SessionsScreen> {
  SessionType? _filter; // null = All

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(sessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.sessions),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {}, // TODO: search
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: AppStrings.all,
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: AppStrings.practice,
                  selected: _filter == SessionType.practice,
                  onTap: () => setState(
                    () => _filter = SessionType.practice,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: AppStrings.match,
                  selected: _filter == SessionType.match,
                  onTap: () => setState(() => _filter = SessionType.match),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Sessions list
          Expanded(
            child: sessionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(e.toString(), style: AppTextStyles.bodyMedium),
              ),
              data: (sessions) {
                final filtered = _filter == null
                    ? sessions
                    : sessions
                        .where((s) => s.type == _filter)
                        .toList();

                if (filtered.isEmpty) {
                  return _EmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (ctx, i) {
                    return SessionCard(
                      session: filtered[i],
                      onTap: () =>
                          context.push('/session/${filtered[i].id}'),
                      onShare: () => _showShareSheet(context, filtered[i]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showShareSheet(BuildContext context, CricketSession session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _ShareSheet(session: session),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.green : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.black : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.video_library_outlined,
            color: AppColors.textMuted,
            size: 64,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(AppStrings.noSessionsFound, style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Tap the Record button to get started.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 160,
            child: ElevatedButton.icon(
              onPressed: () => NewSessionSheet.show(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Session'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareSheet extends StatefulWidget {
  final CricketSession session;
  const _ShareSheet({required this.session});

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _selected = <String>{};
  bool _linkCopied = false;

  final _teammates = [
    ('t1', 'Arjun Sharma', 'AS'),
    ('t2', 'Priya Mehta', 'PM'),
    ('t3', 'Rohan Patel', 'RP'),
    ('t4', 'Kavita Nair', 'KN'),
    ('t5', 'Dev Gupta', 'DG'),
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
          const SizedBox(height: AppSpacing.sm),
          Text(widget.session.title, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          const Text(AppStrings.shareWith, style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          ..._teammates.map((t) {
            final isSelected = _selected.contains(t.$1);
            return CheckboxListTile(
              value: isSelected,
              onChanged: (_) {
                setState(() {
                  if (isSelected) {
                    _selected.remove(t.$1);
                  } else {
                    _selected.add(t.$1);
                  }
                });
              },
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
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _linkCopied = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _linkCopied = false);
                    });
                  },
                  icon: Icon(
                    _linkCopied ? Icons.check_rounded : Icons.copy_rounded,
                  ),
                  label: Text(
                    _linkCopied ? 'Copied!' : AppStrings.copyLink,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _selected.isEmpty ? null : () {},
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Send'),
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
