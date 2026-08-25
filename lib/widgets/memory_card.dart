import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_special_app/models/memory.dart';
import 'package:my_special_app/utils/memory_dates.dart';
import 'package:my_special_app/widgets/memory_photo.dart';
import 'package:my_special_app/widgets/motion.dart';

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
      child: PressableScale(
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
                          isThumbnail: true,
                          placeholder: ColoredBox(
                            color: colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: ColoredBox(
                            color: colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Icon(
                                Icons.favorite_outline,
                                color:
                                    colorScheme.primary.withValues(alpha: 0.5),
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
                                  child: AnimatedHeart(
                                    isFavorite: memory.isFavorite,
                                    size: 18,
                                    color: const Color(0xFFF472B6),
                                    outlineColor: Colors.white,
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
      ),
    );

    if (kIsWeb) return card;
    return Hero(tag: 'memory-${memory.id}', child: card);
  }
}

class TimelineMemoryTile extends StatelessWidget {
  const TimelineMemoryTile({
    super.key,
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
      child: PressableScale(
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
                      isThumbnail: true,
                      placeholder: ColoredBox(
                        color: colorScheme.surfaceContainerHighest,
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
                    icon: AnimatedHeart(
                      isFavorite: memory.isFavorite,
                      size: 24,
                      color: colorScheme.secondary,
                      outlineColor: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
