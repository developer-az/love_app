import 'package:flutter/material.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/services/memory_service.dart';
import 'package:my_special_app/utils/memory_dates.dart';

enum MemorySort { newest, oldest, title, location, favoritesFirst }

enum MemoryLayout { grid, timeline }

class MemoryController extends ChangeNotifier {
  MemoryController(this._service);

  static const _sortKey = 'memory_sort';
  static const _layoutKey = 'memory_layout';
  static const _themeKey = 'theme_mode';

  final MemoryService _service;

  List<Memory> _memories = [];
  String _searchQuery = '';
  MemorySort _sort = MemorySort.newest;
  MemoryLayout _layout = MemoryLayout.grid;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;
  Memory? _lastDeleted;

  List<Memory> get memories => List.unmodifiable(_memories);
  String get searchQuery => _searchQuery;
  MemorySort get sort => _sort;
  MemoryLayout get layout => _layout;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  MemoryService get service => _service;
  int get favoriteCount =>
      _memories.where((memory) => memory.isFavorite).length;

  List<Memory> get visibleMemories {
    final filtered = _searchQuery.trim().isEmpty
        ? List<Memory>.from(_memories)
        : _memories
            .where((memory) => memory.matchesQuery(_searchQuery))
            .toList();

    filtered.sort((a, b) {
      switch (_sort) {
        case MemorySort.oldest:
          return a.date.compareTo(b.date);
        case MemorySort.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case MemorySort.location:
          return a.location.toLowerCase().compareTo(b.location.toLowerCase());
        case MemorySort.favoritesFirst:
          if (a.isFavorite != b.isFavorite) {
            return a.isFavorite ? -1 : 1;
          }
          return b.date.compareTo(a.date);
        case MemorySort.newest:
          return b.date.compareTo(a.date);
      }
    });
    return filtered;
  }

  Map<String, List<Memory>> get memoriesByMonth {
    final grouped = <String, List<Memory>>{};
    for (final memory in visibleMemories) {
      grouped
          .putIfAbsent(MemoryDates.monthYear(memory.date), () => [])
          .add(memory);
    }
    return grouped;
  }

  Future<void> load({bool showSpinner = false}) async {
    if (showSpinner) {
      _isLoading = true;
      notifyListeners();
    }
    _restorePrefs();
    _memories = await _service.getMemories();
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (query == _searchQuery) return;
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> setSort(MemorySort sort) async {
    _sort = sort;
    await _service.setSetting(_sortKey, sort.name);
    notifyListeners();
  }

  Future<void> setLayout(MemoryLayout layout) async {
    _layout = layout;
    await _service.setSetting(_layoutKey, layout.name);
    notifyListeners();
  }

  Future<void> cycleThemeMode() async {
    _themeMode = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await _service.setSetting(_themeKey, _themeMode.name);
    notifyListeners();
  }

  Future<void> add(Memory memory) async {
    await _service.addMemory(memory);
    await load();
  }

  Future<void> update(Memory memory) async {
    await _service.updateMemory(memory);
    await load();
  }

  Future<void> toggleFavorite(Memory memory) async {
    await update(memory.copyWith(isFavorite: !memory.isFavorite));
  }

  Future<void> delete(Memory memory) async {
    _lastDeleted = memory;
    await _service.deleteMemory(memory.id);
    await load();
  }

  Future<bool> undoDelete() async {
    final restored = _lastDeleted;
    if (restored == null) return false;
    _lastDeleted = null;
    await _service.addMemory(restored);
    await load();
    return true;
  }

  void _restorePrefs() {
    final sortName = _service.getSetting(_sortKey);
    _sort = MemorySort.values.firstWhere(
      (value) => value.name == sortName,
      orElse: () => MemorySort.newest,
    );
    final layoutName = _service.getSetting(_layoutKey);
    _layout = MemoryLayout.values.firstWhere(
      (value) => value.name == layoutName,
      orElse: () => MemoryLayout.grid,
    );
    final themeName = _service.getSetting(_themeKey);
    _themeMode = ThemeMode.values.firstWhere(
      (value) => value.name == themeName,
      orElse: () => ThemeMode.system,
    );
  }
}

class MemoryScope extends InheritedNotifier<MemoryController> {
  const MemoryScope({
    super.key,
    required MemoryController controller,
    required super.child,
  }) : super(notifier: controller);

  static MemoryController of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'MemoryScope not found in the widget tree');
    return scope!;
  }

  static MemoryController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MemoryScope>()?.notifier;
  }
}
