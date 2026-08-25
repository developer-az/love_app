import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_special_app/models/memory.dart';

/// Top-level so large payloads can be parsed on a worker isolate.
List<Memory> parseMemoriesJson(String raw) {
  try {
    final decoded = json.decode(raw);
    if (decoded is! List) return [];
    return decoded.map(Memory.tryFromJson).whereType<Memory>().toList();
  } catch (_) {
    return [];
  }
}

class MemoryService {
  static const String _storageKey = 'memories';
  static const int _isolateThresholdBytes = 100 * 1024;

  final SharedPreferences _prefs;
  List<Memory>? _cache;

  MemoryService(this._prefs);

  Future<List<Memory>> getMemories() async {
    if (_cache != null) return List<Memory>.from(_cache!);

    final String? memoriesJson = _prefs.getString(_storageKey);
    if (memoriesJson == null || memoriesJson.isEmpty) {
      _cache = const [];
      return [];
    }

    final parsed = !kIsWeb && memoriesJson.length > _isolateThresholdBytes
        ? await compute(parseMemoriesJson, memoriesJson)
        : parseMemoriesJson(memoriesJson);
    _cache = parsed;
    return List<Memory>.from(parsed);
  }

  Future<Memory?> getMemoryById(String id) async {
    final memories = await getMemories();
    for (final memory in memories) {
      if (memory.id == id) return memory;
    }
    return null;
  }

  Future<void> addMemory(Memory memory) async {
    final memories = await getMemories();
    memories.add(memory);
    await _saveMemories(memories);
  }

  Future<void> updateMemory(Memory memory) async {
    final memories = await getMemories();
    final index = memories.indexWhere((m) => m.id == memory.id);
    if (index != -1) {
      memories[index] = memory;
      await _saveMemories(memories);
    }
  }

  Future<void> deleteMemory(String id) async {
    final memories = await getMemories();
    memories.removeWhere((memory) => memory.id == id);
    await _saveMemories(memories);
  }

  Future<void> _saveMemories(List<Memory> memories) async {
    _cache = List<Memory>.from(memories);
    final memoriesJson = json.encode(
      memories.map((memory) => memory.toJson()).toList(),
    );
    await _prefs.setString(_storageKey, memoriesJson);
  }

  String? getSetting(String key) => _prefs.getString(key);

  Future<void> setSetting(String key, String value) async {
    await _prefs.setString(key, value);
  }
}
