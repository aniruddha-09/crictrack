// lib/features/record/presentation/recording_screen.dart
// Full-screen camera preview with real camera package.
// Overlay: REC indicator, timer, pitch guide lines, ball counter.

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme.dart';
import '../../../core/strings.dart';
import '../../../app/providers.dart';
import '../widgets/rec_overlay.dart';
import '../widgets/pitch_guide_overlay.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraCtrl;
  List<CameraDescription> _cameras = [];
  bool _initialized = false;
  bool _permissionDenied = false;
  bool _isRecording = false;
  int _elapsedSeconds = 0;
  int _ballsDetected = 0;
  double _zoom = 1.0;
  double _maxZoom = 5.0;

  Timer? _recordTimer;
  Timer? _ballDetectTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() => _permissionDenied = true);
      return;
    }

    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      setState(() => _permissionDenied = true);
      return;
    }

    _cameraCtrl = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _cameraCtrl!.initialize();
    _maxZoom = await _cameraCtrl!.getMaxZoomLevel();

    if (mounted) {
      setState(() => _initialized = true);
      _startRecording();
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _elapsedSeconds = 0;
      _ballsDetected = 0;
    });

    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });

    // Simulate ball detection every 8–12 seconds
    _scheduleBallDetect();
  }

  void _scheduleBallDetect() {
    final delay = 8 + (DateTime.now().millisecondsSinceEpoch % 4);
    _ballDetectTimer = Timer(Duration(seconds: delay), () {
      if (!mounted || !_isRecording) return;
      setState(() => _ballsDetected++);
      _showBallToast();
      _scheduleBallDetect();
    });
  }

  void _showBallToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Delivery $_ballsDetected clipped ✓',
          style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.card,
      ),
    );
  }

  void _stopRecording() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.confirmStop),
        content: const Text(AppStrings.confirmStopMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rejected,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _recordTimer?.cancel();
      _ballDetectTimer?.cancel();

      // TODO(backend): Stop recording and upload video for processing
      final repo = ref.read(cricketRepositoryProvider);
      final recordingId = await repo.startRecording();

      if (!mounted) return;
      // ignore: use_build_context_synchronously
      context.pushReplacement('/processing?sessionId=$recordingId');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordTimer?.cancel();
    _ballDetectTimer?.cancel();
    _cameraCtrl?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraCtrl?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) return _PermissionDeniedView();
    if (!_initialized || _cameraCtrl == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          CameraPreview(_cameraCtrl!),

          // Pitch guide overlay
          const PitchGuideOverlay(),

          // REC overlay (timer + ball count)
          RecOverlay(
            isRecording: _isRecording,
            elapsed: _elapsedSeconds,
            ballsDetected: _ballsDetected,
          ),

          // Zoom slider (right side)
          Positioned(
            right: 16,
            top: 120,
            bottom: 120,
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: _zoom,
                min: 1.0,
                max: _maxZoom,
                onChanged: (v) async {
                  setState(() => _zoom = v);
                  await _cameraCtrl!.setZoomLevel(v);
                },
              ),
            ),
          ),

          // Zoom label
          Positioned(
            right: 48,
            bottom: 140,
            child: Text(
              '${_zoom.toStringAsFixed(1)}×',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 48,
            left: 16,
            child: _IconBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                _recordTimer?.cancel();
                _ballDetectTimer?.cancel();
                context.pop();
              },
            ),
          ),

          // Mark bowler button
          Positioned(
            top: 48,
            right: 16,
            child: _IconBtn(
              icon: Icons.person_pin_circle_rounded,
              label: AppStrings.markBowler,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bowler marked'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),

          // Stop button
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _stopRecording,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.rejected,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.rejected.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.stop_rounded, color: Colors.white, size: 36),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_rounded,
                color: AppColors.textMuted,
                size: 72,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                AppStrings.cameraPermissionDenied,
                style: AppTextStyles.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                AppStrings.cameraPermissionMsg,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: () => openAppSettings(),
                icon: const Icon(Icons.settings_rounded),
                label: const Text(AppStrings.openSettings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Wakelock compatibility shim (wakelock_plus would be the real package)
class WakelockPlus {
  static Future<void> enable() async {}
  static Future<void> disable() async {}
}
