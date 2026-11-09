import 'package:lcat_prep/content/models.dart';

/// One sitting of a paper. Immutable; every change goes through
/// the repository as a new value. LCAT sections are timed one at a time:
/// [remainingSeconds] belongs to [sectionIndex], and a finished section is closed.
class Attempt {
  const Attempt({
    required this.id,
    required this.paperId,
    required this.startedAt,
    required this.remainingSeconds,
    this.answers = const {},
    this.flagged = const {},
    this.currentIndex = 0,
    this.sectionIndex = 0,
    this.finishedAt,
    this.correct,
    this.total,
  });

  factory Attempt.fromJson(Json json) => Attempt(
    id: json['id']! as String,
    paperId: json['paperId']! as String,
    startedAt: DateTime.parse(json['startedAt']! as String),
    remainingSeconds: json['remaining']! as int,
    answers: (json['answers']! as Json).cast<String, int>(),
    flagged: (json['flagged']! as List<Object?>).cast<String>().toSet(),
    currentIndex: json['index']! as int,
    sectionIndex: json['section'] as int? ?? 0,
    finishedAt: switch (json['finishedAt']) {
      final String value => DateTime.parse(value),
      _ => null,
    },
    correct: json['correct'] as int?,
    total: json['total'] as int?,
  );

  final String id;
  final String paperId;
  final DateTime startedAt;
  final int remainingSeconds;

  /// Question id to chosen option.
  final Map<String, int> answers;
  final Set<String> flagged;
  final int currentIndex;

  /// The open section; earlier ones are closed.
  final int sectionIndex;
  final DateTime? finishedAt;
  final int? correct;
  final int? total;

  bool get isFinished => finishedAt != null;

  int get percent => (total ?? 0) == 0 ? 0 : ((correct ?? 0) * 100 / total!).round();

  Attempt copyWith({
    int? remainingSeconds,
    Map<String, int>? answers,
    Set<String>? flagged,
    int? currentIndex,
    int? sectionIndex,
    DateTime? finishedAt,
    int? correct,
    int? total,
  }) => Attempt(
    id: id,
    paperId: paperId,
    startedAt: startedAt,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    answers: answers ?? this.answers,
    flagged: flagged ?? this.flagged,
    currentIndex: currentIndex ?? this.currentIndex,
    sectionIndex: sectionIndex ?? this.sectionIndex,
    finishedAt: finishedAt ?? this.finishedAt,
    correct: correct ?? this.correct,
    total: total ?? this.total,
  );

  Json toJson() => {
    'id': id,
    'paperId': paperId,
    'section': sectionIndex,
    'startedAt': startedAt.toIso8601String(),
    'remaining': remainingSeconds,
    'answers': answers,
    'flagged': flagged.toList(),
    'index': currentIndex,
    if (finishedAt case final finished?) 'finishedAt': finished.toIso8601String(),
    'correct': ?correct,
    'total': ?total,
  };
}
