import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

int decodeCacheWidth(BuildContext context, double logicalWidth) {
  if (!logicalWidth.isFinite || logicalWidth <= 0) return 400;
  final dpr = MediaQuery.devicePixelRatioOf(context);
  return (logicalWidth * dpr).round().clamp(64, 1200);
}

/// Keeps a small LRU of decoded data-URI photos so grid rebuilds do not
/// base64-decode the same image on every frame.
class DecodedImageCache {
  DecodedImageCache._();

  static const _maxEntries = 24;
  static final _order = <String>[];
  static final _bytes = <String, Uint8List>{};

  static Uint8List? bytesFor(String dataUri) {
    final cached = _bytes[dataUri];
    if (cached != null) {
      _order.remove(dataUri);
      _order.add(dataUri);
      return cached;
    }
    try {
      final comma = dataUri.indexOf(',');
      if (comma == -1) return null;
      final bytes = base64Decode(dataUri.substring(comma + 1));
      if (_order.length >= _maxEntries) {
        final evicted = _order.removeAt(0);
        _bytes.remove(evicted);
      }
      _order.add(dataUri);
      _bytes[dataUri] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  static void clear() {
    _order.clear();
    _bytes.clear();
  }
}

/// Renders a memory photo from a network URL or an inline data URI.
class MemoryPhoto extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? cacheWidth;
  final bool isThumbnail;

  const MemoryPhoto({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.placeholder,
    this.errorWidget,
    this.cacheWidth,
    this.isThumbnail = false,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = errorWidget ??
        ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: SizedBox(
            height: height,
            width: width,
            child: Icon(
              Icons.broken_image_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );

    Widget framed(Widget child) {
      if (height == null && width == null) return child;
      return SizedBox(height: height, width: width, child: child);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final pixels = cacheWidth ??
            decodeCacheWidth(
              context,
              constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : (width ?? 400),
            );
        final quality = isThumbnail ? FilterQuality.low : FilterQuality.medium;

        if (imageUrl.startsWith('data:image')) {
          final bytes = DecodedImageCache.bytesFor(imageUrl);
          if (bytes == null) return framed(fallback);
          return framed(
            Image.memory(
              bytes,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
              cacheWidth: pixels,
              gaplessPlayback: true,
              filterQuality: quality,
              errorBuilder: (_, __, ___) => fallback,
            ),
          );
        }

        if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
          return framed(
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: fit,
              width: double.infinity,
              height: double.infinity,
              memCacheWidth: pixels,
              fadeInDuration: isThumbnail
                  ? Duration.zero
                  : const Duration(milliseconds: 150),
              fadeOutDuration: Duration.zero,
              placeholder: (context, url) =>
                  placeholder ??
                  ColoredBox(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
              errorWidget: (context, url, error) => fallback,
            ),
          );
        }

        return framed(fallback);
      },
    );
  }
}

ImageProvider? memoryImageProvider(String imageUrl) {
  if (imageUrl.startsWith('data:image')) {
    final bytes = DecodedImageCache.bytesFor(imageUrl);
    if (bytes == null) return null;
    return MemoryImage(bytes);
  }
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return NetworkImage(imageUrl);
  }
  return null;
}
