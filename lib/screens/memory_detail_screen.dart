import 'package:flutter/material.dart';
import 'package:my_special_app/theme/app_theme.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:photo_view/photo_view.dart';

class MemoryDetailScreen extends StatelessWidget {
  final Memory memory;

  const MemoryDetailScreen({super.key, required this.memory});

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
                tag: 'memory-${memory.id}',
                child: GestureDetector(
                  onTap: () => _showImageViewer(context),
                  child: CachedNetworkImage(
                    imageUrl: memory.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
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
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () => _shareMemory(context),
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
                    // Title Section
                    Text(
                      memory.title,
                      style: AppTheme.headingStyle.copyWith(fontSize: 32),
                    ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Date and Location Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.1),
                            AppTheme.secondaryColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Date',
                            '${memory.date.day}/${memory.date.month}/${memory.date.year}',
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            Icons.location_on,
                            'Location',
                            memory.location,
                          ),
                        ],
                      ),
                    ).animate(delay: const Duration(milliseconds: 200))
                        .fadeIn()
                        .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    // Description Section
                    Text(
                      'Story',
                      style: AppTheme.titleStyle.copyWith(fontSize: 22),
                    ).animate(delay: const Duration(milliseconds: 300))
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
                        memory.description,
                        style: AppTheme.bodyStyle.copyWith(
                          height: 1.6,
                          fontSize: 17,
                        ),
                      ),
                    ).animate(delay: const Duration(milliseconds: 400))
                        .fadeIn()
                        .slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: AppTheme.gradientButtonDecoration,
                            child: ElevatedButton.icon(
                              onPressed: () => _shareMemory(context),
                              icon: const Icon(Icons.share, color: Colors.white),
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
                                padding: const EdgeInsets.symmetric(vertical: 16),
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
                    ).animate(delay: const Duration(milliseconds: 500))
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
            color: AppTheme.primaryColor.withOpacity(0.1),
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
            imageProvider: CachedNetworkImageProvider(memory.imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: 'memory-${memory.id}'),
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _shareMemory(BuildContext context) {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sharing feature coming soon!',
          style: AppTheme.bodyStyle.copyWith(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
