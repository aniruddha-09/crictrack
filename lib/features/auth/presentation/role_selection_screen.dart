// lib/features/auth/presentation/role_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/strings.dart';
import '../../../data/models/enums.dart';
import '../../../app/providers.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  final String phone;
  const RoleSelectionScreen({super.key, required this.phone});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole? _selected;
  bool _loading = false;

  final _roles = [
    (
      role: UserRole.player,
      label: AppStrings.rolePlayer,
      icon: Icons.sports_cricket_rounded,
      desc: 'Track your bowling deliveries and improve your performance.',
    ),
    (
      role: UserRole.coach,
      label: AppStrings.roleCoach,
      icon: Icons.record_voice_over_rounded,
      desc: 'Analyse player performance and manage training sessions.',
    ),
    (
      role: UserRole.analyst,
      label: AppStrings.roleAnalyst,
      icon: Icons.analytics_rounded,
      desc: 'Deep-dive into delivery data, exports and 3D trajectories.',
    ),
  ];

  void _proceed() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).login(widget.phone, _selected!);
    if (mounted) {
      setState(() => _loading = false);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const Text('Select Your Role', style: AppTextStyles.headlineLarge),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'This helps us personalise your experience.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              ...List.generate(_roles.length, (i) {
                final r = _roles[i];
                final isSelected = _selected == r.role;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _selected = r.role),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.greenGlow
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.green
                                  : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.green
                                      : AppColors.surfaceVariant,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                                child: Icon(
                                  r.icon,
                                  color: isSelected
                                      ? Colors.black
                                      : AppColors.textMuted,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.label,
                                      style: AppTextStyles.titleLarge.copyWith(
                                        color: isSelected
                                            ? AppColors.green
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(r.desc, style: AppTextStyles.bodySmall),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.green,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              ElevatedButton(
                onPressed: _selected == null || _loading ? null : _proceed,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(AppStrings.continueBtn),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
