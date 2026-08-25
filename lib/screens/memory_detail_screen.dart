import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/screens/add_memory_screen.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:my_special_app/theme/app_theme.dart';
import 'package:my_special_app/widgets/memory_photo.dart';
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
      MaterialPageRoute(
        builder: (context) => AddMemoryScreen(
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

  Future<void> _deleteMemory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this memory?'),
        content: const Text(
          'This will permanently remove the memory from your collection.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await widget.memoryService.deleteMemory(_memory.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Memory deleted',
          style: AppTheme.bodyStyle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'memory-${_memory.id}',
                child: GestureDetector(
                  onTap: () => _showImageViewer(context),
                  child: MemoryPhoto(
                    imageUrl: _memory.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      color: Colors.grey[200],
                      child:
                          const Icon(Icons.error, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  tooltip: 'Edit memory',
                  onPressed: _editMemory,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  tooltip: 'Delete memory',
                  onPressed: _deleteMemory,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _memory.title,
                      style: AppTheme.headingStyle.copyWith(fontSize: 32),
                    ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                            AppTheme.secondaryColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Date',
                            DateFormat('MMMM d, yyyy').format(_memory.date),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            Icons.location_on,
                            'Location',
                            _memory.location,
                          ),
                        ],
                      ),
                    )
                        .animate(delay: const Duration(milliseconds: 200))
                        .fadeIn()
                        .slideY(begin: 0.3, end: 0),
                    const SizedBox(height: 32),
                    Text(
                      'Story',
                      style: AppTheme.titleStyle.copyWith(fontSize: 22),
                    )
                        .animate(delay: const Duration(milliseconds: 300))
                        .fadeIn()
                        .slideY(begin: 0.3, end: 0),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[200]!,
                        ),
                      ),
                      child: Text(
                        _memory.description,
                        style: AppTheme.bodyStyle.copyWith(
                          height: 1.6,
                          fontSize: 17,
                        ),
                      ),
                    )
                        .animate(delay: const Duration(milliseconds: 400))
                        .fadeIn()
                        .slideY(begin: 0.3, end: 0),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: AppTheme.gradientButtonDecoration,
                            child: ElevatedButton.icon(
                              onPressed: () => _shareMemory(context),
                              icon:
                                  const Icon(Icons.share, color: Colors.white),
                              label: Text(
                                'Share Memory',
                                style: AppTheme.bodyStyle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.primaryColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            onPressed: () => _showImageViewer(context),
                            icon: Icon(
                              Icons.zoom_in,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    )
                        .animate(delay: const Duration(milliseconds: 500))
                        .fadeIn()
                        .slideY(begin: 0.3, end: 0),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.captionStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
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
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _shareMemory(BuildContext context) async {
    final text = StringBuffer()
      ..writeln(_memory.title)
      ..writeln(DateFormat('MMMM d, yyyy').format(_memory.date))
      ..writeln(_memory.location)
      ..writeln()
      ..write(_memory.description);

    await Clipboard.setData(ClipboardData(text: text.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Memory copied to clipboard',
          style: AppTheme.bodyStyle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
