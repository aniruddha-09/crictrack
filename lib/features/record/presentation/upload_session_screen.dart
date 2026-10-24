// lib/features/record/presentation/upload_session_screen.dart
// Screen for selecting multiple videos from gallery (up to 7) and naming the session.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';
import '../../../app/providers.dart';

/// Provider: list of picked video files for the upload session.
final _pickedVideosProvider =
    StateNotifierProvider.autoDispose<_VideosNotifier, List<XFile>>(
  (_) => _VideosNotifier(),
);

class _VideosNotifier extends StateNotifier<List<XFile>> {
  _VideosNotifier() : super([]);

  static const _maxVideos = 7;

  Future<void> pickMore() async {
    final picker = ImagePicker();
    final remaining = _maxVideos - state.length;
    if (remaining <= 0) return;

    final picked = await picker.pickMultipleMedia(
      limit: remaining,
    );
    if (picked.isNotEmpty) {
      // Deduplicate by path
      final existing = state.map((f) => f.path).toSet();
      final fresh = picked.where((f) => !existing.contains(f.path)).toList();
      state = [...state, ...fresh];
    }
  }

  void remove(int index) {
    final list = [...state];
    list.removeAt(index);
    state = list;
  }

  void reorder(int oldIndex, int newIndex) {
    final list = [...state];
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class UploadSessionScreen extends ConsumerStatefulWidget {
  const UploadSessionScreen({super.key});

  @override
  ConsumerState<UploadSessionScreen> createState() =>
      _UploadSessionScreenState();
}

class _UploadSessionScreenState extends ConsumerState<UploadSessionScreen> {
  final _titleCtrl = TextEditingController(text: 'Upload Session');
  final _locationCtrl = TextEditingController(text: 'Training Ground');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final videos = ref.read(_pickedVideosProvider);
    if (videos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one video.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO(backend): Upload video files to API and start processing pipeline.
    final repo = ref.read(cricketRepositoryProvider);
    final recordingId = await repo.startRecording();

    if (!mounted) return;
    // ignore: use_build_context_synchronously
    context.pushReplacement(
      '/processing?sessionId=$recordingId&source=upload',
    );
  }

  @override
  Widget build(BuildContext context) {
    final videos = ref.watch(_pickedVideosProvider);
    const maxVideos = 7;
    final canAddMore = videos.length < maxVideos;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upload Session'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (videos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: TextButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Process'),
              ),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ─── Session info fields ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoCard(
                    titleCtrl: _titleCtrl,
                    locationCtrl: _locationCtrl,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Header row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Videos',
                              style: AppTextStyles.headlineSmall,
                            ),
                            Text(
                              '${videos.length} / $maxVideos videos · Drag to reorder',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (canAddMore)
                        _AddButton(
                          onTap: () => ref
                              .read(_pickedVideosProvider.notifier)
                              .pickMore(),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),

          // ─── Video list (empty state or filled) ───────────────────────
          if (videos.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyPickerArea(
                onTap: () =>
                    ref.read(_pickedVideosProvider.notifier).pickMore(),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverReorderableList(
                itemCount: videos.length,
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(_pickedVideosProvider.notifier)
                      .reorder(oldIndex, newIndex);
                },
                itemBuilder: (ctx, i) {
                  return _VideoTile(
                    key: ValueKey(videos[i].path),
                    index: i,
                    file: videos[i],
                    onRemove: () =>
                        ref.read(_pickedVideosProvider.notifier).remove(i),
                  );
                },
              ),
            ),

          // ─── Add more button below list ──────────────────────────────
          if (videos.isNotEmpty && canAddMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(_pickedVideosProvider.notifier).pickMore(),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    'Add More Videos (${maxVideos - videos.length} remaining)',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: AppColors.cyan),
                    foregroundColor: AppColors.cyan,
                  ),
                ),
              ),
            ),

          // ─── Process button ──────────────────────────────────────────
          if (videos.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                child: _ProcessButton(
                  videoCount: videos.length,
                  isLoading: _isSubmitting,
                  onTap: _submit,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session Info Card
// ─────────────────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController locationCtrl;

  const _InfoCard({required this.titleCtrl, required this.locationCtrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: titleCtrl,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(
              labelText: 'Session Name',
              prefixIcon: Icon(Icons.label_outline),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          TextFormField(
            controller: locationCtrl,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on_outlined),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State / Drop Zone
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyPickerArea extends StatefulWidget {
  final VoidCallback onTap;
  const _EmptyPickerArea({required this.onTap});

  @override
  State<_EmptyPickerArea> createState() => _EmptyPickerAreaState();
}

class _EmptyPickerAreaState extends State<_EmptyPickerArea>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.cyanGlow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cyan.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.video_library_rounded,
                    color: AppColors.cyan,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Tap to Select Videos',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choose up to 7 videos from your gallery.\nThey will be processed together as one session.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              // Supported formats info
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: ['MP4', 'MOV', 'AVI', 'MKV'].map((fmt) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      fmt,
                      style: AppTextStyles.labelMedium,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Video Tile (reorderable)
// ─────────────────────────────────────────────────────────────────────────────
class _VideoTile extends StatefulWidget {
  final int index;
  final XFile file;
  final VoidCallback onRemove;

  const _VideoTile({
    required super.key,
    required this.index,
    required this.file,
    required this.onRemove,
  });

  @override
  State<_VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<_VideoTile> {
  // Try to estimate file size
  Future<String> _size() async {
    try {
      final bytes = await File(widget.file.path).length();
      if (bytes > 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
      }
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.file.path.split('/').last.split('\\').last;
    final ext = name.contains('.') ? name.split('.').last.toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.sm,
          AppSpacing.xs,
          AppSpacing.sm,
          AppSpacing.xs,
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            ReorderableDragStartListener(
              index: widget.index,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Icon(
                  Icons.drag_handle_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              ),
            ),
            // Index badge + format pill
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cyanGlow,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.index + 1}',
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        ext,
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        title: Text(
          name,
          style: AppTextStyles.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: FutureBuilder<String>(
          future: _size(),
          builder: (_, snap) => Text(
            snap.data ?? 'Calculating…',
            style: AppTextStyles.bodySmall,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.remove_circle_outline_rounded,
            color: AppColors.rejected,
          ),
          onPressed: widget.onRemove,
          tooltip: 'Remove',
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Button
// ─────────────────────────────────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.cyanGlow,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: AppColors.cyan, size: 16),
            const SizedBox(width: 4),
            Text(
              'Add Videos',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.cyan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Process CTA Button
// ─────────────────────────────────────────────────────────────────────────────
class _ProcessButton extends StatelessWidget {
  final int videoCount;
  final bool isLoading;
  final VoidCallback onTap;

  const _ProcessButton({
    required this.videoCount,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: isLoading
              ? const LinearGradient(
                  colors: [AppColors.surfaceVariant, AppColors.surfaceVariant],
                )
              : AppColors.gradientGreen,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.green,
                ),
              )
            else
              const Icon(Icons.analytics_rounded, color: Colors.black),
            const SizedBox(width: AppSpacing.sm),
            Text(
              isLoading
                  ? 'Uploading…'
                  : 'Process $videoCount Video${videoCount == 1 ? '' : 's'}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
