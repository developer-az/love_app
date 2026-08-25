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
        Container(
          height: height,
          width: width,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
        );

    if (imageUrl.startsWith('data:image')) {
      try {
        final comma = imageUrl.indexOf(',');
        if (comma == -1) return fallback;
        final bytes = base64Decode(imageUrl.substring(comma + 1));
        return Image.memory(
          bytes,
          fit: fit,
          height: height,
          width: width,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => fallback,
        );
      } catch (_) {
        return fallback;
      }
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        height: height,
        width: width,
        placeholder: (context, url) =>
            placeholder ??
            Container(
              height: height,
              width: width,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget: (context, url, error) => fallback,
      );
    }

    return fallback;
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
