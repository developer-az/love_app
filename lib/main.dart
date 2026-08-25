import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/screens/add_memory_screen.dart';
import 'package:my_special_app/screens/memory_detail_screen.dart';
import 'package:my_special_app/screens/stats_screen.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:my_special_app/state/memory_controller.dart';
import 'package:my_special_app/theme/app_theme.dart';
import 'package:my_special_app/utils/app_bootstrap.dart';
import 'package:my_special_app/utils/haptics.dart';
import 'package:my_special_app/widgets/memory_feed.dart';
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
  configureAppPerformance();
  final prefs = await SharedPreferences.getInstance();
  final memoryService = MemoryService(prefs);
  runApp(MySpecialApp(memoryService: memoryService));
}

class MySpecialApp extends StatefulWidget {
  final MemoryService memoryService;

  const MySpecialApp({super.key, required this.memoryService});

  @override
  State<MySpecialApp> createState() => _MySpecialAppState();
}

class _MySpecialAppState extends State<MySpecialApp>
    with WidgetsBindingObserver {
  late final MemoryController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MemoryController(widget.memoryService);
    _controller.load(showSpinner: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MemoryScope(
      controller: _controller,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _controller.themeListenable,
        builder: (context, themeMode, _) {
          return MaterialApp(
            title: 'Cherished Memories',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            restorationScopeId: 'cherished_memories',
            scrollBehavior: AppScrollBehavior(),
            builder: (context, child) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  textScaler: media.textScaler.clamp(
                    minScaleFactor: 0.85,
                    maxScaleFactor: 1.35,
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _shortcutsFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;

  MemoryController get _controller => MemoryScope.of(context);

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _shortcutsFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openAddMemory() async {
    lightHaptic();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddMemoryScreen(memoryService: _controller.service),
      ),
    );
    if (mounted) await _controller.load();
  }

  Future<void> _openMemory(Memory memory) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryDetailScreen(
          memory: memory,
          memoryService: _controller.service,
        ),
      ),
    );
    if (!mounted) return;
    await _controller.load();
    if (deleted == true && mounted) {
      _showUndoDeleteSnackBar();
    }
  }

  Future<void> _deleteMemory(Memory memory) async {
    await _controller.delete(memory);
    if (mounted) _showUndoDeleteSnackBar();
  }

  void _showUndoDeleteSnackBar() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Memory deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            final restored = await _controller.undoDelete();
            if (!mounted || !restored) return;
            messenger.showSnackBar(
              const SnackBar(content: Text('Memory restored')),
            );
          },
        ),
      ),
    );
  }

  void _focusSearch() {
    if (_controller.memories.isEmpty) return;
    _searchFocus.requestFocus();
  }

  void _clearSearch() {
    _searchController.clear();
    _controller.setSearchQuery('');
    _searchFocus.unfocus();
  }

  String get _themeTooltip {
    return switch (_controller.themeMode) {
      ThemeMode.system => 'Theme: system',
      ThemeMode.light => 'Theme: light',
      ThemeMode.dark => 'Theme: dark',
    };
  }

  IconData get _themeIcon {
    return switch (_controller.themeMode) {
      ThemeMode.system => Icons.brightness_auto_outlined,
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
    };
  }

  bool _onScroll(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse && _showFab) {
      setState(() => _showFab = false);
    } else if (notification.direction == ScrollDirection.forward && !_showFab) {
      setState(() => _showFab = true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyN, control: true):
                _openAddMemory,
            const SingleActivator(LogicalKeyboardKey.keyN, meta: true):
                _openAddMemory,
            const SingleActivator(LogicalKeyboardKey.slash): _focusSearch,
            const SingleActivator(LogicalKeyboardKey.keyF, control: true):
                _focusSearch,
            const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
                _focusSearch,
            const SingleActivator(LogicalKeyboardKey.escape): _clearSearch,
          },
          child: Focus(
            focusNode: _shortcutsFocus,
            autofocus: true,
            child: Scaffold(
              appBar: AppBar(
                toolbarHeight:
                    _controller.memories.isNotEmpty ? 72 : kToolbarHeight,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cherished Memories'),
                    if (_controller.memories.isNotEmpty)
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _controller.searchQuery.trim().isEmpty
                              ? '${_controller.memories.length} ${_controller.memories.length == 1 ? 'memory' : 'memories'} · ${_controller.favoriteCount} favorites'
                              : '${_controller.visibleMemories.length} matches',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: _themeTooltip,
                    onPressed: _controller.cycleThemeMode,
                    icon: Icon(_themeIcon),
                  ),
                  IconButton(
                    tooltip: _controller.layout == MemoryLayout.grid
                        ? 'Switch to timeline'
                        : 'Switch to grid',
                    onPressed: () {
                      lightHaptic();
                      _controller.setLayout(
                        _controller.layout == MemoryLayout.grid
                            ? MemoryLayout.timeline
                            : MemoryLayout.grid,
                      );
                    },
                    icon: Icon(
                      _controller.layout == MemoryLayout.grid
                          ? Icons.view_agenda_outlined
                          : Icons.grid_view_outlined,
                    ),
                  ),
                  PopupMenuButton<MemorySort>(
                    tooltip: 'Sort memories',
                    initialValue: _controller.sort,
                    onSelected: _controller.setSort,
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: MemorySort.newest,
                        child: Text('Newest first'),
                      ),
                      PopupMenuItem(
                        value: MemorySort.oldest,
                        child: Text('Oldest first'),
                      ),
                      PopupMenuItem(
                        value: MemorySort.title,
                        child: Text('Title'),
                      ),
                      PopupMenuItem(
                        value: MemorySort.location,
                        child: Text('Location'),
                      ),
                      PopupMenuItem(
                        value: MemorySort.favoritesFirst,
                        child: Text('Favorites first'),
                      ),
                    ],
                    icon: const Icon(Icons.sort),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatsScreen(
                            memoryService: _controller.service,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.insights_outlined),
                    tooltip: 'View Statistics',
                  ),
                ],
              ),
              body: NotificationListener<UserScrollNotification>(
                onNotification: _onScroll,
                child: Column(
                  children: [
                    if (_controller.memories.isNotEmpty)
                      PremiumComponents.searchBar(
                        hintText: 'Search memories...',
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onChanged: _controller.setSearchQuery,
                      ),
                    Expanded(
                      child: _controller.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _controller.memories.isEmpty
                              ? _EmptyMemoriesState(onAdd: _openAddMemory)
                              : MemoriesBody(
                                  controller: _controller,
                                  scrollController: _scrollController,
                                  onOpen: _openMemory,
                                  onFavorite: (memory) async {
                                    lightHaptic();
                                    await _controller.toggleFavorite(memory);
                                  },
                                  onDelete: _deleteMemory,
                                ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: AnimatedOpacity(
                opacity: _showFab ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: IgnorePointer(
                  ignoring: !_showFab,
                  child: FloatingActionButton(
                    onPressed: _openAddMemory,
                    tooltip: 'Add memory',
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyMemoriesState extends StatelessWidget {
  const _EmptyMemoriesState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
            Text(
              'No memories yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Start capturing your special moments',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add First Memory'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
