// lib/features/auth/presentation/otp_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/strings.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrlList =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusList = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  int _resendCountdown = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Autofocus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusList.first.requestFocus();
    });
  }

  void _startCountdown() async {
    for (int i = _resendCountdown; i >= 0; i--) {
      if (!mounted) return;
      setState(() => _resendCountdown = i);
      if (i == 0) setState(() => _canResend = true);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    for (final c in _ctrlList) { c.dispose(); }
    for (final f in _focusList) { f.dispose(); }
    super.dispose();
  }

  String get _otpValue => _ctrlList.map((c) => c.text).join();

  void _verify() async {
    if (_otpValue.length < 6) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    // Any 6-digit OTP works in mock mode
    if (mounted) {
      setState(() => _loading = false);
      context.go('/role?phone=${widget.phone}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verify OTP', style: AppTextStyles.headlineLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${AppStrings.otpSent} +91 ${widget.phone}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            // OTP boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                return SizedBox(
                  width: 48,
                  height: 56,
                  child: TextFormField(
                    controller: _ctrlList[i],
                    focusNode: _focusList[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(
                          color: AppColors.green,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty && i < 5) {
                        _focusList[i + 1].requestFocus();
                      } else if (val.isEmpty && i > 0) {
                        _focusList[i - 1].requestFocus();
                      }
                      if (_otpValue.length == 6) _verify();
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _loading || _otpValue.length < 6 ? null : _verify,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(AppStrings.verifyOtp),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: _canResend
                  ? TextButton(
                      onPressed: () {
                        setState(() {
                          _canResend = false;
                          _resendCountdown = 30;
                        });
                        _startCountdown();
                      },
                      child: const Text(AppStrings.resendOtp),
                    )
                  : Text(
                      'Resend OTP in ${_resendCountdown}s',
                      style: AppTextStyles.bodyMedium,
                    ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.greenGlow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.green, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Mock mode: any 6-digit code works.',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
