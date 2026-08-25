import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/screens/add_memory_screen.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:my_special_app/state/memory_controller.dart';
import 'package:my_special_app/theme/app_theme.dart';
import 'package:my_special_app/utils/app_animations.dart';
import 'package:my_special_app/utils/haptics.dart';
import 'package:my_special_app/utils/memory_dates.dart';
import 'package:my_special_app/widgets/memory_photo.dart';
import 'package:my_special_app/widgets/motion.dart';
import 'package:photo_view/photo_view.dart';

class MemoryDetailScreen extends StatefulWidget {
  final Memory memory;
  final MemoryService memoryService;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
    required this.memoryService,
  });

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  late Memory _memory;

  @override
  void initState() {
    super.initState();
    _memory = widget.memory;
  }

  Future<void> _editMemory() async {
    final updated = await Navigator.push<bool>(
      context,
      fadeRoute(
        AddMemoryScreen(
          memoryService: widget.memoryService,
          existingMemory: _memory,
        ),
      ),
    );
    if (updated != true || !mounted) return;

    final refreshed = await widget.memoryService.getMemoryById(_memory.id);
    if (!mounted) return;
    if (refreshed == null) {
      Navigator.pop(context, true);
      return;
    }
    setState(() => _memory = refreshed);
  }

  Future<void> _toggleFavorite() async {
    lightHaptic();
    final controller = MemoryScope.maybeOf(context);
    if (controller != null) {
      await controller.toggleFavorite(_memory);
      if (!mounted) return;
      final match =
          controller.memories.where((memory) => memory.id == _memory.id);
      setState(() {
        _memory = match.isEmpty
            ? _memory.copyWith(isFavorite: !_memory.isFavorite)
            : match.first;
      });
      return;
    }
    final updated = _memory.copyWith(isFavorite: !_memory.isFavorite);
    await widget.memoryService.updateMemory(updated);
    if (!mounted) return;
    setState(() => _memory = updated);
  }

  Future<void> _deleteMemory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this memory?'),
        content: const Text(
          'This will remove the memory from your collection. You can undo from the home screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final controller = MemoryScope.maybeOf(context);
    if (controller != null) {
      await controller.delete(_memory);
    } else {
      await widget.memoryService.deleteMemory(_memory.id);
    }
    if (!mounted) return;
    mediumHaptic();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () => _showImageViewer(context),
                child: MemoryPhoto(
                  imageUrl: _memory.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: ColoredBox(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.photo_outlined,
                      size: 50,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            leading: _barButton(
              icon: Icons.arrow_back,
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              _barButton(
                icon:
                    _memory.isFavorite ? Icons.favorite : Icons.favorite_border,
                tooltip: _memory.isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: _toggleFavorite,
              ),
              _barButton(
                icon: Icons.edit_outlined,
                tooltip: 'Edit memory',
                onPressed: _editMemory,
              ),
              _barButton(
                icon: Icons.delete_outline,
                tooltip: 'Delete memory',
                onPressed: _deleteMemory,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SelectionArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _memory.title,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.1),
                              colorScheme.secondary.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.calendar_today,
                              'Date',
                              MemoryDates.full(_memory.date),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              Icons.location_on,
                              'Location',
                              _memory.location,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Story',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: AppTheme.cardDecorationOf(context),
                        child: Text(
                          _memory.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _shareMemory(context),
                              icon: const Icon(Icons.share),
                              label: const Text('Share Memory'),
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: () => _showImageViewer(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Icon(
                              Icons.zoom_in,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        child: IconButton(
          icon: FadeSwitcher(
            duration: AppAnimations.fast,
            child: Icon(icon, key: ValueKey(icon), color: Colors.white),
          ),
          tooltip: tooltip,
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }

  void _showImageViewer(BuildContext context) {
    final imageProvider = memoryImageProvider(_memory.imageUrl);
    if (imageProvider == null) return;

    Navigator.push(
      context,
      fadeRoute(
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PhotoView(
            imageProvider: imageProvider,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
  }

  Future<void> _shareMemory(BuildContext context) async {
    final text = StringBuffer()
      ..writeln(_memory.title)
      ..writeln(MemoryDates.full(_memory.date))
      ..writeln(_memory.location)
      ..writeln()
      ..write(_memory.description);

    await Clipboard.setData(ClipboardData(text: text.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Memory copied to clipboard')),
    );
  }
}
