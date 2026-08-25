import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/screens/add_memory_screen.dart';
import 'package:my_special_app/screens/memory_detail_screen.dart';
import 'package:my_special_app/screens/stats_screen.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:my_special_app/theme/app_theme.dart';
import 'package:my_special_app/widgets/memory_photo.dart';
import 'package:my_special_app/widgets/premium_components.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

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
      scrollBehavior: AppScrollBehavior(),
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

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Memory> _memories = [];
  List<Memory> _filteredMemories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMemories(showSpinner: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMemories({bool showSpinner = false}) async {
    if (showSpinner && mounted) {
      setState(() => _isLoading = true);
    }
    final memories = await widget.memoryService.getMemories();
    if (!mounted) return;
    setState(() {
      _memories = memories;
      _isLoading = false;
      _applyFilter(_searchQuery);
    });
  }

  Future<void> _openAddMemory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddMemoryScreen(memoryService: widget.memoryService),
      ),
    );
    if (mounted) await _loadMemories();
  }

  void _applyFilter(String query) {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _filteredMemories = _memories;
    } else {
      _filteredMemories =
          _memories.where((memory) => memory.matchesQuery(query)).toList();
    }
  }

  void _filterMemories(String query) {
    setState(() => _applyFilter(query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Cherished Memories'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StatsScreen(memoryService: widget.memoryService),
                ),
              );
            },
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'View Statistics',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_memories.isNotEmpty)
            PremiumComponents.searchBar(
              hintText: 'Search memories...',
              controller: _searchController,
              onChanged: _filterMemories,
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _memories.isEmpty
                    ? _buildEmptyState()
                    : _buildMemoriesGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddMemory,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        tooltip: 'Add memory',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No memories yet',
              style: AppTheme.headingStyle,
            ),
            const SizedBox(height: 12),
            const Text(
              'Start capturing your special moments',
              style: AppTheme.captionStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _openAddMemory,
              icon: const Icon(Icons.add),
              label: const Text('Add First Memory'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoriesGrid() {
    final displayMemories = _filteredMemories;

    if (displayMemories.isEmpty && _searchQuery.isNotEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: AppTheme.primaryColor),
              SizedBox(height: 16),
              Text('No memories found', style: AppTheme.subheadingStyle),
              SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: AppTheme.captionStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMemories,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: displayMemories.length,
        itemBuilder: (context, index) {
          final memory = displayMemories[index];
          return PremiumMemoryCard(
            key: ValueKey(memory.id),
            memory: memory,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemoryDetailScreen(
                    memory: memory,
                    memoryService: widget.memoryService,
                  ),
                ),
              );
              if (mounted) await _loadMemories();
            },
          );
        },
      ),
    );
  }
}

class PremiumMemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback onTap;

  const PremiumMemoryCard({
    super.key,
    required this.memory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MemoryPhoto(
                imageUrl: memory.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: const ColoredBox(
                  color: Color(0xFFF3F4F6),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: ColoredBox(
                  color: const Color(0xFFF3F4F6),
                  child: Center(
                    child: Icon(
                      Icons.favorite_outline,
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.title,
                    style: AppTheme.subheadingStyle.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('MMM d, yyyy').format(memory.date),
                    style: AppTheme.captionStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    memory.location,
                    style: AppTheme.captionStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (kIsWeb) return card;
    return Hero(tag: 'memory-${memory.id}', child: card);
  }
}
