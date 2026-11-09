import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lcat_prep/core/scoring.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._preferences);

  final SharedPreferencesAsync _preferences;
  static const _practiceKey = 'practiceTally';

  /// `section/topic` to [correct, attempted] from practice sessions.
  Future<Map<String, List<int>>> practiceTally() async {
    final raw = await _preferences.getString(_practiceKey);
    if (raw == null) return {};
    return {
      for (final MapEntry(:key, :value) in (jsonDecode(raw) as Map<String, Object?>).entries)
        key: (value! as List<Object?>).cast<int>(),
    };
  }

  Future<void> savePracticeTally(Map<String, List<int>> tally) =>
      _preferences.setString(_practiceKey, jsonEncode(tally));
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(SharedPreferencesAsync()),
);

class PracticeTallyNotifier extends AsyncNotifier<Map<String, List<int>>> {
  @override
  Future<Map<String, List<int>>> build() => ref.watch(settingsRepositoryProvider).practiceTally();

  Future<void> record(
    String section,
    String topic, {
    required int correct,
    required int total,
  }) async {
    final current = {...await future};
    final key = '$section/$topic';
    final old = current[key] ?? const [0, 0];
    current[key] = [old[0] + correct, old[1] + total];
    await ref.read(settingsRepositoryProvider).savePracticeTally(current); // persist first
    state = AsyncData(current);
  }

  /// Adds a finished test's topic results in one write.
  Future<void> recordAll(List<TopicScore> topics) async {
    final current = {...await future};
    for (final topic in topics) {
      final key = '${topic.section}/${topic.topic}';
      final old = current[key] ?? const [0, 0];
      current[key] = [old[0] + topic.tally.correct, old[1] + topic.tally.total];
    }
    await ref.read(settingsRepositoryProvider).savePracticeTally(current); // persist first
    state = AsyncData(current);
  }
}

final practiceTallyProvider = AsyncNotifierProvider<PracticeTallyNotifier, Map<String, List<int>>>(
  PracticeTallyNotifier.new,
);
