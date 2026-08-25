import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/screens/add_memory_screen.dart';
import 'package:my_special_app/screens/memory_detail_screen.dart';
import 'package:my_special_app/screens/stats_screen.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:my_special_app/state/memory_controller.dart';
import 'package:my_special_app/theme/app_theme.dart';
import 'package:my_special_app/utils/haptics.dart';
import 'package:my_special_app/utils/memory_dates.dart';
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

class MySpecialApp extends StatefulWidget {
  final MemoryService memoryService;

  const MySpecialApp({super.key, required this.memoryService});

  @override
  State<MySpecialApp> createState() => _MySpecialAppState();
}

class _MySpecialAppState extends State<MySpecialApp> {
  late final MemoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MemoryController(widget.memoryService);
    _controller.load(showSpinner: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MemoryScope(
      controller: _controller,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return MaterialApp(
            title: 'Cherished Memories',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _controller.themeMode,
            debugShowCheckedModeBanner: false,
            scrollBehavior: AppScrollBehavior(),
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

  MemoryController get _controller => MemoryScope.of(context);

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _shortcutsFocus.dispose();
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
          },
          child: Focus(
            focusNode: _shortcutsFocus,
            autofocus: true,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Cherished Memories'),
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
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: MemorySort.newest,
                        child: Text('Newest first'),
                      ),
                      const PopupMenuItem(
                        value: MemorySort.oldest,
                        child: Text('Oldest first'),
                      ),
                      const PopupMenuItem(
                        value: MemorySort.title,
                        child: Text('Title'),
                      ),
                      const PopupMenuItem(
                        value: MemorySort.location,
                        child: Text('Location'),
                      ),
                      const PopupMenuItem(
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
              body: Column(
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
                            : _MemoriesBody(
                                controller: _controller,
                                onOpen: _openMemory,
                                onFavorite: (memory) async {
                                  lightHaptic();
                                  await _controller.toggleFavorite(memory);
                                },
                              ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _openAddMemory,
                tooltip: 'Add memory',
                child: const Icon(Icons.add),
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

class _MemoriesBody extends StatelessWidget {
  const _MemoriesBody({
    required this.controller,
    required this.onOpen,
    required this.onFavorite,
  });

  final MemoryController controller;
  final ValueChanged<Memory> onOpen;
  final ValueChanged<Memory> onFavorite;

  @override
  Widget build(BuildContext context) {
    final memories = controller.visibleMemories;
    if (memories.isEmpty && controller.searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'No memories found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.load(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: controller.layout == MemoryLayout.timeline
            ? _TimelineView(
                key: const ValueKey('timeline'),
                grouped: controller.memoriesByMonth,
                onOpen: onOpen,
                onFavorite: onFavorite,
              )
            : _GridView(
                key: const ValueKey('grid'),
                memories: memories,
                onOpen: onOpen,
                onFavorite: onFavorite,
              ),
      ),
    );
  }
}

class _GridView extends StatelessWidget {
  const _GridView({
    super.key,
    required this.memories,
    required this.onOpen,
    required this.onFavorite,
  });

  final List<Memory> memories;
  final ValueChanged<Memory> onOpen;
  final ValueChanged<Memory> onFavorite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = gridColumnsForWidth(constraints.maxWidth);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: memories.length,
          itemBuilder: (context, index) {
            final memory = memories[index];
            return PremiumMemoryCard(
              key: ValueKey(memory.id),
              memory: memory,
              onTap: () => onOpen(memory),
              onFavorite: () => onFavorite(memory),
            );
          },
        );
      },
    );
  }
}

class _TimelineView extends StatelessWidget {
  const _TimelineView({
    super.key,
    required this.grouped,
    required this.onOpen,
    required this.onFavorite,
  });

  final Map<String, List<Memory>> grouped;
  final ValueChanged<Memory> onOpen;
  final ValueChanged<Memory> onFavorite;

  @override
  Widget build(BuildContext context) {
    final months = grouped.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: months.length,
      itemBuilder: (context, index) {
        final entry = months[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...entry.value.map(
                (memory) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TimelineTile(
                    memory: memory,
                    onTap: () => onOpen(memory),
                    onFavorite: () => onFavorite(memory),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.memory,
    required this.onTap,
    required this.onFavorite,
  });

  final Memory memory;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: '${memory.title}, ${memory.location}',
      child: Material(
        color: Theme.of(context).cardTheme.color ?? colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 96,
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: MemoryPhoto(
                    imageUrl: memory.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.favorite_outline,
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memory.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MemoryDates.relative(memory.date),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          memory.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: memory.isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  onPressed: onFavorite,
                  icon: Icon(
                    memory.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: memory.isFavorite
                        ? colorScheme.secondary
                        : colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumMemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;

  const PremiumMemoryCard({
    super.key,
    required this.memory,
    required this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final card = RepaintBoundary(
      child: Semantics(
        button: true,
        label: '${memory.title}, ${memory.location}',
        child: Material(
          color: Theme.of(context).cardTheme.color ?? colorScheme.surface,
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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MemoryPhoto(
                        imageUrl: memory.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: ColoredBox(
                          color: colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: ColoredBox(
                          color: colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Icon(
                              Icons.favorite_outline,
                              color: colorScheme.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      if (onFavorite != null)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Material(
                            color: Colors.black45,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: onFavorite,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  memory.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 18,
                                  color: memory.isFavorite
                                      ? const Color(0xFFF472B6)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        MemoryDates.short(memory.date),
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        memory.location,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (kIsWeb) return card;
    return Hero(tag: 'memory-${memory.id}', child: card);
  }
}
