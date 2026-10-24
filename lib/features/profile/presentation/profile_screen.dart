// lib/features/profile/presentation/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/strings.dart';
import '../../../app/providers.dart';
import '../../../data/models/enums.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final showJson = ref.watch(showTrajectoryJsonProvider);

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── User card ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.gradientCard,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.greenGlow,
                  child: Text(
                    user.avatarInitials,
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 4),
                      Text('+91 ${user.phone}', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 6),
                      _RoleBadge(role: user.role),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Subscription card ────────────────────────────────────────────
          _SectionHeader('Subscription'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text(
                    AppStrings.freePlan,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Limited to 5 sessions/month', style: AppTextStyles.bodySmall),
                      Text('Upgrade for unlimited analysis', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => context.push('/paywall'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Upgrade'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Storage card ────────────────────────────────────────────────
          _SectionHeader('Cloud Storage'),
          const SizedBox(height: AppSpacing.sm),
          Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${user.storageUsedGb} GB of ${user.storageTotalGb} GB used',
                      style: AppTextStyles.bodyMedium,
                    ),
                    Text(
                      '${(user.storageUsedGb / user.storageTotalGb * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: AppColors.cyan,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: user.storageUsedGb / user.storageTotalGb,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Developer options ─────────────────────────────────────────────
          _SectionHeader('Developer Options'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: showJson,
                  onChanged: (v) =>
                      ref.read(showTrajectoryJsonProvider.notifier).state = v,
                  title: const Text(AppStrings.showTrajectoryJson, style: AppTextStyles.bodyLarge),
                  subtitle: const Text(
                    'Show raw FinalTrajectory JSON in Outputs tab',
                    style: AppTextStyles.bodySmall,
                  ),
                  activeThumbColor: AppColors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Settings list ─────────────────────────────────────────────────
          _SectionHeader('Account'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _SettingsItem(
                  icon: Icons.privacy_tip_rounded,
                  label: AppStrings.privacy,
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingsItem(
                  icon: Icons.description_rounded,
                  label: AppStrings.terms,
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingsItem(
                  icon: Icons.logout_rounded,
                  label: AppStrings.logout,
                  color: AppColors.rejected,
                  onTap: () => _confirmLogout(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(AppStrings.version, style: AppTextStyles.bodySmall),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rejected,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) =>
      Text(title, style: AppTextStyles.headlineSmall);
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final label = switch (role) {
      UserRole.player => 'PLAYER',
      UserRole.coach => 'COACH',
      UserRole.analyst => 'ANALYST',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.greenGlow,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.green,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c, size: 20),
      title: Text(label, style: TextStyle(color: c, fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
