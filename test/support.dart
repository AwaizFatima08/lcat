import 'package:lcat_prep/content/content_repository.dart';
import 'package:lcat_prep/content/models.dart';

Question question(
  String id, {
  String section = 'math',
  String topic = 'statistics',
  int answer = 0,
  String? setId,
}) => Question(
  id: id,
  section: section,
  topic: topic,
  isPractice: false,
  level: 1,
  stem: 'Stem $id',
  options: const ['a', 'b', 'c', 'd'],
  answer: answer,
  explanation: 'Because.',
  setId: setId,
);

Sitting sittingOf(List<(String, List<Question>)> sections) {
  final parts = [
    for (final (key, questions) in sections)
      PaperSection(
        key: key,
        bank: key.split('-').first,
        title: key,
        minutes: 40,
        itemIds: [for (final q in questions) q.id],
      ),
  ];
  return Sitting(
    paper: Paper(
      id: 'lcat-01',
      number: 1,
      title: 'LCAT Mock 1',
      minutes: 40 * sections.length,
      sections: parts,
    ),
    sections: parts,
    questions: [for (final (_, questions) in sections) ...questions],
    sets: const {},
  );
}
