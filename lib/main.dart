import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_special_app/theme/app_theme.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:my_special_app/screens/add_memory_screen.dart';
import 'package:my_special_app/screens/memory_detail_screen.dart';
import 'package:my_special_app/screens/stats_screen.dart';
import 'package:my_special_app/widgets/premium_components.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final memoryService = MemoryService(prefs);
  runApp(MySpecialApp(memoryService: memoryService));
}

class MySpecialApp extends StatelessWidget {
  final MemoryService memoryService;

  const MySpecialApp({super.key, required this.memoryService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cherished Memories',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(memoryService: memoryService),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final MemoryService memoryService;

  const HomeScreen({super.key, required this.memoryService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Memory> _memories = [];
  List<Memory> _filteredMemories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    setState(() => _isLoading = true);
    final memories = await widget.memoryService.getMemories();
    setState(() {
      _memories = memories;
      _filteredMemories = memories;
      _isLoading = false;
    });
  }

  void _filterMemories(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMemories = _memories;
      } else {
        _filteredMemories = _memories.where((memory) {
          return memory.title.toLowerCase().contains(query.toLowerCase()) ||
                 memory.description.toLowerCase().contains(query.toLowerCase()) ||
                 memory.location.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Cherished Memories',
          style: AppTheme.titleStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        StatsScreen(memoryService: widget.memoryService),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: animation.drive(
                          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              },
              icon: Icon(
                Icons.analytics,
                color: AppTheme.primaryColor,
              ),
              tooltip: 'View Statistics',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFEDF2F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar
              if (_memories.isNotEmpty)
                PremiumComponents.searchBar(
                  hintText: 'Search memories...',
                  onChanged: _filterMemories,
                ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
              
              // Content
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _memories.isEmpty
                        ? _buildEmptyState()
                        : _buildMemoriesGrid(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: AppTheme.gradientButtonDecoration,
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AddMemoryScreen(memoryService: widget.memoryService),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween(begin: const Offset(0.0, 1.0), end: Offset.zero),
                    ),
                    child: child,
                  );
                },
              ),
            );
            _loadMemories();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      )
          .animate()
          .scale(delay: const Duration(milliseconds: 500))
          .fadeIn(duration: const Duration(milliseconds: 300)),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        itemCount: 6, // Show skeleton cards
        itemBuilder: (context, index) => _buildSkeletonCard(),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 250,
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: const Duration(milliseconds: 1500));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_outline,
              size: 60,
              color: Colors.white,
            ),
          )
              .animate()
              .scale(duration: const Duration(milliseconds: 600))
              .then()
              .shimmer(duration: const Duration(milliseconds: 1000)),
          const SizedBox(height: 32),
          Text(
            'No memories yet',
            style: AppTheme.headingStyle,
          ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
          const SizedBox(height: 12),
          Text(
            'Start capturing your special moments',
            style: AppTheme.captionStyle,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
          const SizedBox(height: 32),
          Container(
            decoration: AppTheme.gradientButtonDecoration,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMemoryScreen(memoryService: widget.memoryService),
                  ),
                );
                _loadMemories();
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add First Memory',
                style: AppTheme.bodyStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 700)),
        ],
      ),
    );
  }

  Widget _buildMemoriesGrid() {
    final displayMemories = _filteredMemories;
    
    if (displayMemories.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No memories found',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: AppTheme.captionStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn();
    }
    
    return RefreshIndicator(
      onRefresh: _loadMemories,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          itemCount: displayMemories.length,
          itemBuilder: (context, index) {
            final memory = displayMemories[index];
            return PremiumMemoryCard(
              memory: memory,
              index: index,
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        MemoryDetailScreen(memory: memory),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class PremiumMemoryCard extends StatelessWidget {
  final Memory memory;
  final int index;
  final VoidCallback onTap;

  const PremiumMemoryCard({
    super.key,
    required this.memory,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'memory-${memory.id}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: AppTheme.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: memory.imageUrl,
                  height: index.isEven ? 200 : 160, // Staggered heights
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: index.isEven ? 200 : 160,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: index.isEven ? 200 : 160,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memory.title,
                      style: AppTheme.subheadingStyle.copyWith(fontSize: 18),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${memory.date.day}/${memory.date.month}/${memory.date.year}',
                          style: AppTheme.captionStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            memory.location,
                            style: AppTheme.captionStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideX(begin: 0.2, end: 0);
  }
}
