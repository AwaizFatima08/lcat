import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lcat_prep/content/models.dart';

/// Checks the built assets: every paper resolves to real questions in the right pool and bank.
void main() {
  final forms = jsonDecode(File('assets/data/forms.json').readAsStringSync()) as List<Object?>;
  final papers = [for (final form in forms) Paper.fromJson(form! as Json)];
  final questions = <String, Question>{};
  for (final file in Directory('assets/data').listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    if (!name.startsWith('bank_')) continue;
    final section = name.substring(5, name.length - 5);
    final json = jsonDecode(file.readAsStringSync()) as Json;
    for (final raw in json['questions']! as List<Object?>) {
      final question = Question.fromJson(raw! as Json, section);
      questions[question.id] = question;
    }
  }

  test('there are 20 mock exams of 4 sections and 90 questions', () {
    expect(papers, hasLength(20));
    for (final paper in papers) {
      expect(
        [for (final s in paper.sections) s.title],
        [
          'Verbal Section 1',
          'Verbal Section 2',
          'Math Section 1',
          'Math Section 2',
        ],
      );
      expect(paper.questionCount, 90, reason: paper.id);
      expect(paper.minutes, 160, reason: paper.id);
    }
  });

  test('no test question appears twice in any exam, and practice items never do', () {
    final ids = [
      for (final paper in papers)
        for (final section in paper.sections) ...section.itemIds,
    ];
    expect(ids.toSet(), hasLength(ids.length));
    for (final paper in papers) {
      for (final section in paper.sections) {
        for (final id in section.itemIds) {
          final question = questions[id];
          expect(question, isNotNull, reason: '${paper.id} $id');
          expect(question!.isPractice, isFalse, reason: '${paper.id} $id');
          expect(question.section, section.bank, reason: '${paper.id} $id');
        }
      }
    }
  });

  test('every answer key points at one of four options', () {
    for (final question in questions.values) {
      expect(question.options, hasLength(4), reason: question.id);
      expect(question.answer, inInclusiveRange(0, 3), reason: question.id);
    }
  });
}
