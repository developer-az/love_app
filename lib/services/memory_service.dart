import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memory.dart';

class MemoryService {
  static const String _storageKey = 'memories';
  final SharedPreferences _prefs;

  MemoryService(this._prefs);

  Future<List<Memory>> getMemories() async {
    final String? memoriesJson = _prefs.getString(_storageKey);
    if (memoriesJson == null) return [];

    final List<dynamic> memoriesList = json.decode(memoriesJson);
    return memoriesList.map((json) => Memory.fromJson(json)).toList();
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
    final memoriesJson = json.encode(
      memories.map((memory) => memory.toJson()).toList(),
    );
    await _prefs.setString(_storageKey, memoriesJson);
  }
}
