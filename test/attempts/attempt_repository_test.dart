import 'package:flutter_test/flutter_test.dart';
import 'package:lcat_prep/attempts/attempt.dart';
import 'package:lcat_prep/attempts/attempt_repository.dart';
import 'package:lcat_prep/core/clock.dart';
import 'package:lcat_prep/core/result.dart';

class MemoryStore implements DocumentStore {
  String? contents;

  @override
  Future<String?> read() async => contents;

  @override
  Future<void> write(String value) async => contents = value;
}

class FixedClock implements Clock {
  @override
  DateTime now() => DateTime(2026, 11, 2, 10);
}

void main() {
  test('an attempt survives a reload with its answers, flags and time', () async {
    final store = MemoryStore();
    final repository = AttemptRepository(store, FixedClock());
    final started = await repository.start(paperId: 'lcat-01', firstSectionMinutes: 40);
    final attempt = (started as Ok<Attempt, StorageFailure>).value;
    await repository.update(
      attempt.id,
      (current) => current.copyWith(
        answers: {'q1': 2},
        flagged: {'q2'},
        remainingSeconds: 100,
        currentIndex: 7,
        sectionIndex: 2,
      ),
    );
    final reloaded = await AttemptRepository(store, FixedClock()).byId(attempt.id);
    expect(reloaded!.answers, {'q1': 2});
    expect(reloaded.flagged, {'q2'});
    expect(reloaded.remainingSeconds, 100);
    expect(reloaded.currentIndex, 7);
    expect(reloaded.sectionIndex, 2);
    expect(reloaded.isFinished, isFalse);
  });

  test('a new attempt opens the first section with its time in seconds', () async {
    final repository = AttemptRepository(MemoryStore(), FixedClock());
    await repository.start(paperId: 'lcat-01', firstSectionMinutes: 40);
    final all = await repository.watchAll().first;
    expect(all.single.remainingSeconds, 2400);
    expect(all.single.sectionIndex, 0);
  });
}
