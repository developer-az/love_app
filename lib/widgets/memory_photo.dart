import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders a memory photo from a network URL or an inline data URI.
class MemoryPhoto extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;
  final Widget? placeholder;
  final Widget? errorWidget;

  const MemoryPhoto({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = errorWidget ??
        ColoredBox(
          color: const Color(0xFFF3F4F6),
          child: SizedBox(
            height: height,
            width: width,
            child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
        );

    Widget framed(Widget child) {
      if (height == null && width == null) return child;
      return SizedBox(height: height, width: width, child: child);
    }

    if (imageUrl.startsWith('data:image')) {
      try {
        final comma = imageUrl.indexOf(',');
        if (comma == -1) return framed(fallback);
        final bytes = base64Decode(imageUrl.substring(comma + 1));
        return framed(
          Image.memory(
            bytes,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            cacheWidth: 800,
            gaplessPlayback: true,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => fallback,
          ),
        );
      } catch (_) {
        return framed(fallback);
      }
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return framed(
        CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          memCacheWidth: 800,
          placeholder: (context, url) =>
              placeholder ??
              const ColoredBox(
                color: Color(0xFFF3F4F6),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
          errorWidget: (context, url, error) => fallback,
        ),
      );
    }

    return framed(fallback);
  }
}

ImageProvider? memoryImageProvider(String imageUrl) {
  if (imageUrl.startsWith('data:image')) {
    try {
      final comma = imageUrl.indexOf(',');
      if (comma == -1) return null;
      return MemoryImage(base64Decode(imageUrl.substring(comma + 1)));
    } catch (_) {
      return null;
    }
  }
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return NetworkImage(imageUrl);
  }
  return null;
}
