import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void configureAppPerformance() {
  final cache = PaintingBinding.instance.imageCache;
  cache.maximumSize = 80;
  cache.maximumSizeBytes = 40 << 20;

  if (kReleaseMode) {
    ErrorWidget.builder = (details) {
      return const Material(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    };
  }
}
