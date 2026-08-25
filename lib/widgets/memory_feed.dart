import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/state/memory_controller.dart';
import 'package:my_special_app/utils/app_animations.dart';
import 'package:my_special_app/utils/memory_dates.dart';
import 'package:my_special_app/widgets/memory_card.dart';

class MemoriesBody extends StatelessWidget {
  const MemoriesBody({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.onOpen,
    required this.onFavorite,
    required this.onDelete,
  });

  final MemoryController controller;
  final ScrollController scrollController;
  final ValueChanged<Memory> onOpen;
  final ValueChanged<Memory> onFavorite;
  final ValueChanged<Memory> onDelete;

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
      child: controller.layout == MemoryLayout.timeline
          ? MemoryTimelineView(
              key: const PageStorageKey('memory-timeline'),
              grouped: controller.memoriesByMonth,
              scrollController: scrollController,
              onOpen: onOpen,
              onFavorite: onFavorite,
              onDelete: onDelete,
            )
          : MemoryGridView(
              key: const PageStorageKey('memory-grid'),
              memories: memories,
              scrollController: scrollController,
              onOpen: onOpen,
              onFavorite: onFavorite,
            ),
    );
  }
}

class MemoryGridView extends StatelessWidget {
  const MemoryGridView({
    super.key,
    required this.memories,
    required this.scrollController,
    required this.onOpen,
    required this.onFavorite,
  });

  final List<Memory> memories;
  final ScrollController scrollController;
  final ValueChanged<Memory> onOpen;
  final ValueChanged<Memory> onFavorite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = gridColumnsForWidth(constraints.maxWidth);
        return Scrollbar(
          controller: scrollController,
          thumbVisibility: kIsWeb,
          child: GridView.builder(
            controller: scrollController,
            cacheExtent: 480,
            addAutomaticKeepAlives: false,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: memories.length,
            findChildIndexCallback: (key) {
              if (key is! ValueKey<String>) return null;
              final index =
                  memories.indexWhere((memory) => memory.id == key.value);
              return index == -1 ? null : index;
            },
            itemBuilder: (context, index) {
              final memory = memories[index];
              return PremiumMemoryCard(
                key: ValueKey(memory.id),
                memory: memory,
                onTap: () => onOpen(memory),
                onFavorite: () => onFavorite(memory),
              );
            },
          ),
        );
      },
    );
  }
}

class MemoryTimelineView extends StatelessWidget {
  const MemoryTimelineView({
    super.key,
    required this.grouped,
    required this.scrollController,
    required this.onOpen,
    required this.onFavorite,
    required this.onDelete,
  });

  final Map<String, List<Memory>> grouped;
  final ScrollController scrollController;
  final ValueChanged<Memory> onOpen;
  final ValueChanged<Memory> onFavorite;
  final ValueChanged<Memory> onDelete;

  @override
  Widget build(BuildContext context) {
    final items = <Object>[];
    for (final entry in grouped.entries) {
      items.add(entry.key);
      items.addAll(entry.value);
    }

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: kIsWeb,
      child: ListView.builder(
        controller: scrollController,
        cacheExtent: 480,
        addAutomaticKeepAlives: false,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item is String) {
            return Padding(
              padding: EdgeInsets.only(
                  left: 4, bottom: 10, top: index == 0 ? 0 : 12),
              child: Text(
                item,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          final memory = item as Memory;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Dismissible(
              key: ValueKey('dismiss-${memory.id}'),
              direction: DismissDirection.endToStart,
              movementDuration: AppAnimations.medium,
              resizeDuration: AppAnimations.fast,
              onDismissed: (_) => onDelete(memory),
              background: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
              ),
              child: TimelineMemoryTile(
                memory: memory,
                onTap: () => onOpen(memory),
                onFavorite: () => onFavorite(memory),
              ),
            ),
          );
        },
      ),
    );
  }
}
