import 'package:flutter_test/flutter_test.dart';
import 'package:lcat_prep/core/scoring.dart';

import '../support.dart';

void main() {
  final sitting = sittingOf([
    (
      'verbal-1',
      [
        question('v1', section: 'verbal', topic: 'transitions', answer: 1),
        question('v2', section: 'verbal', topic: 'transitions', answer: 2),
      ],
    ),
    ('math-1', [question('q1', answer: 3), question('q2', topic: 'quadratics')]),
    ('math-2', [question('q3', topic: 'circles', answer: 1)]),
  ]);

  test('counts right, wrong and skipped with no negative marking', () {
    final score = scoreSitting(sitting, {'v1': 1, 'v2': 0, 'q1': 3});
    expect(score.overall.correct, 2);
    expect(score.overall.total, 5);
    expect(score.overall.percent, 40);
    expect(score.skipped, 2);
  });

  test('scores each section separately', () {
    final score = scoreSitting(sitting, {'v1': 1, 'q2': 0});
    expect(score.sections[0].tally.correct, 1);
    expect(score.sections[0].skipped, 1);
    expect(score.sections[1].tally.correct, 1);
  });

  test('lists the weakest topic first', () {
    final score = scoreSitting(sitting, {'q1': 3, 'q2': 0});
    expect(score.topics.first.topic, 'transitions');
    expect(score.topics.first.tally.percent, 0);
  });

  test('adds both sections of a bank together', () {
    final score = scoreSitting(sitting, {'q1': 3, 'q3': 1, 'v1': 1});
    expect(score.byBank.keys, ['verbal', 'math']);
    expect(score.byBank['math']!.correct, 2);
    expect(score.byBank['math']!.total, 3);
  });

  test('an empty tally is zero percent', () {
    expect(const Tally(0, 0).percent, 0);
  });
}
