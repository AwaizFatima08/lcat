import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lcat_prep/attempts/attempt.dart';
import 'package:lcat_prep/attempts/attempt_repository.dart';
import 'package:lcat_prep/content/content_repository.dart';
import 'package:lcat_prep/core/clock.dart';
import 'package:lcat_prep/core/result.dart';
import 'package:lcat_prep/features/exam/exam_notifier.dart';
import 'package:lcat_prep/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../attempts/attempt_repository_test.dart' show FixedClock, MemoryStore;

Map<String, Object?> _row(String id, int answer) => {
  'id': id,
  'tp': 't',
  'pl': 't',
  'lv': 1,
  's': 'Stem $id',
  'o': ['a', 'b', 'c', 'd'],
  'a': answer,
  'e': 'Because.',
};

Map<String, Object?> _part(String key, String bank, List<String> items) => {
  'key': key,
  'bank': bank,
  'title': key,
  'minutes': 1,
  'items': items,
};

final _assets = {
  'assets/data/forms.json': jsonEncode([
    {
      'id': 'lcat-01',
      'number': 1,
      'title': 'LCAT Mock 1',
      'minutes': 2,
      'sections': [
        _part('verbal-1', 'verbal', ['v1', 'v2']),
        _part('math-1', 'math', ['m1']),
      ],
    },
  ]),
  'assets/data/bank_verbal.json': jsonEncode({
    'sets': <String, Object?>{},
    'questions': [_row('v1', 0), _row('v2', 1)],
  }),
  'assets/data/bank_math.json': jsonEncode({
    'sets': <String, Object?>{},
    'questions': [_row('m1', 2)],
  }),
};

void main() {
  late ProviderContainer container;
  late String attemptId;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    container = ProviderContainer(
      overrides: [
        assetReaderProvider.overrideWithValue((path) async => _assets[path]!),
        attemptStoreProvider.overrideWithValue(MemoryStore()),
        clockProvider.overrideWithValue(FixedClock()),
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(SharedPreferencesAsync())),
      ],
    );
    final started = await container
        .read(attemptRepositoryProvider)
        .start(paperId: 'lcat-01', firstSectionMinutes: 1);
    attemptId = (started as Ok<Attempt, StorageFailure>).value.id;
  });

  tearDown(() => container.dispose());

  Future<ExamState> exam() => container.read(examProvider(attemptId).future);
  ExamNotifier notifier() => container.read(examProvider(attemptId).notifier);

  test('moves only inside the open section', () async {
    final sub = container.listen(examProvider(attemptId), (_, _) {});
    await exam();
    await notifier().goTo(2);
    expect((await exam()).attempt.currentIndex, 0);
    await notifier().goTo(1);
    expect((await exam()).attempt.currentIndex, 1);
    sub.close();
  });

  test('finishing a section opens the next with a fresh clock, then submits', () async {
    final sub = container.listen(examProvider(attemptId), (_, _) {});
    await exam();
    await notifier().choose(0);
    await notifier().finishSection();
    var state = await exam();
    expect(state.attempt.sectionIndex, 1);
    expect(state.attempt.currentIndex, 2);
    expect(state.attempt.remainingSeconds, 60);
    expect(state.attempt.isFinished, isFalse);

    await notifier().goTo(0);
    expect((await exam()).attempt.currentIndex, 2, reason: 'closed section stays closed');

    await notifier().choose(2);
    await notifier().finishSection();
    state = await exam();
    expect(state.attempt.isFinished, isTrue);
    expect(state.attempt.correct, 2);
    expect(state.attempt.total, 3);
    sub.close();
  });
}
