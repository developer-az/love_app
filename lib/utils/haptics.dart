import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void lightHaptic() {
  if (kIsWeb) return;
  HapticFeedback.selectionClick();
}

void mediumHaptic() {
  if (kIsWeb) return;
  HapticFeedback.mediumImpact();
}
