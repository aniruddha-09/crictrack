// lib/features/profile/presentation/paywall_screen.dart
// Mock paywall / upgrade to Pro screen.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Hero section
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.black, size: 44),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Upgrade to Pro',
              style: AppTextStyles.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Unlock unlimited sessions, advanced analytics, and team collaboration.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Feature list
            ...[
              ('Unlimited recording sessions', Icons.all_inclusive_rounded),
              ('Full 3D trajectory analysis', Icons.view_in_ar_rounded),
              ('Team sharing & collaboration', Icons.group_rounded),
              ('Export CSV / JSON data', Icons.download_rounded),
              ('Priority ML processing', Icons.bolt_rounded),
              ('Cloud storage — 50 GB', Icons.cloud_rounded),
            ].map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.greenGlow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(f.$2, color: AppColors.green, size: 16),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(f.$1, style: AppTextStyles.bodyLarge),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Pricing
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: AppColors.gradientGreen,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                children: [
                  const Text(
                    '₹499',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'per month',
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: AppColors.green,
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Payment (Mock)'),
                          content: const Text(
                            'This is a UI prototype. Payment is not implemented.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      'Get Pro — ₹499/month',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'Maybe later',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
