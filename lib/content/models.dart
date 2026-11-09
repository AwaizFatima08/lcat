typedef Json = Map<String, Object?>;

List<T> _list<T>(Object? raw, T Function(Json) read) => [
  for (final item in raw! as List<Object?>) read(item! as Json),
];

/// One multiple-choice question from the bank.
class Question {
  const Question({
    required this.id,
    required this.section,
    required this.topic,
    required this.isPractice,
    required this.level,
    required this.stem,
    required this.options,
    required this.answer,
    required this.explanation,
    this.setId,
    this.table,
  });

  factory Question.fromJson(Json json, String section) => Question(
    id: json['id']! as String,
    section: section,
    topic: json['tp']! as String,
    isPractice: json['pl'] == 'p',
    level: json['lv']! as int,
    stem: json['s']! as String,
    options: (json['o']! as List<Object?>).cast<String>(),
    answer: json['a']! as int,
    explanation: json['e']! as String,
    setId: json['st'] as String?,
    table: switch (json['tb']) {
      final List<Object?> rows => [for (final row in rows) (row! as List<Object?>).cast<String>()],
      _ => null,
    },
  );

  final String id;
  final String section;
  final String topic;
  final bool isPractice;
  final int level;
  final String stem;
  final List<String> options;
  final int answer;
  final String explanation;
  final String? setId;
  final List<List<String>>? table;
}

/// A passage or scenario shared by several questions.
class QuestionSet {
  const QuestionSet({required this.title, required this.text});

  factory QuestionSet.fromJson(Json json) =>
      QuestionSet(title: json['t']! as String, text: json['x']! as String);

  final String title;
  final String text;
}

class TopicInfo {
  const TopicInfo({
    required this.key,
    required this.title,
    required this.domain,
    required this.practiceCount,
    required this.bankCount,
  });

  factory TopicInfo.fromJson(Json json) => TopicInfo(
    key: json['key']! as String,
    title: json['title']! as String,
    domain: json['domain']! as String,
    practiceCount: json['practice']! as int,
    bankCount: json['bank']! as int,
  );

  final String key;
  final String title;

  /// The LUMS content domain, e.g. "Craft and Structure" or "Advanced Math".
  final String domain;
  final int practiceCount;

  /// Practice plus test questions on this topic.
  final int bankCount;
}

class SectionInfo {
  const SectionInfo({required this.key, required this.title, required this.topics});

  factory SectionInfo.fromJson(Json json) => SectionInfo(
    key: json['key']! as String,
    title: json['title']! as String,
    topics: _list(json['topics'], TopicInfo.fromJson),
  );

  final String key;
  final String title;
  final List<TopicInfo> topics;

  /// Topics grouped by domain, in blueprint order.
  Map<String, List<TopicInfo>> get byDomain {
    final groups = <String, List<TopicInfo>>{};
    for (final topic in topics) {
      (groups[topic.domain] ??= []).add(topic);
    }
    return groups;
  }
}

/// One timed section of the paper pattern, e.g. "Verbal Section 1".
class PatternPart {
  const PatternPart({
    required this.title,
    required this.minutes,
    required this.questionCount,
  });

  factory PatternPart.fromJson(Json json) => PatternPart(
    title: json['title']! as String,
    minutes: json['minutes']! as int,
    questionCount: json['questions']! as int,
  );

  final String title;
  final int minutes;
  final int questionCount;
}

class Catalog {
  const Catalog({required this.sections, required this.pattern});

  factory Catalog.fromJson(Json json) => Catalog(
    sections: _list(json['sections'], SectionInfo.fromJson),
    pattern: _list(json['pattern'], PatternPart.fromJson),
  );

  final List<SectionInfo> sections;
  final List<PatternPart> pattern;

  int get questionCount => pattern.fold(0, (sum, part) => sum + part.questionCount);

  int get minutes => pattern.fold(0, (sum, part) => sum + part.minutes);

  /// Title of a topic, falling back to its key for retired content.
  String topicTitle(String section, String topic) => topicInfo(section, topic)?.title ?? topic;

  TopicInfo? topicInfo(String section, String topic) {
    for (final candidate in sections) {
      if (candidate.key != section) continue;
      for (final info in candidate.topics) {
        if (info.key == topic) return info;
      }
    }
    return null;
  }
}

/// One separately timed section of a paper. Several sections can draw on the same bank.
class PaperSection {
  const PaperSection({
    required this.key,
    required this.bank,
    required this.title,
    required this.minutes,
    required this.itemIds,
  });

  factory PaperSection.fromJson(Json json) => PaperSection(
    key: json['key']! as String,
    bank: json['bank']! as String,
    title: json['title']! as String,
    minutes: json['minutes']! as int,
    itemIds: (json['items']! as List<Object?>).cast<String>(),
  );

  final String key;
  final String bank;
  final String title;
  final int minutes;
  final List<String> itemIds;
}

/// One full-length mock exam.
class Paper {
  const Paper({
    required this.id,
    required this.number,
    required this.title,
    required this.minutes,
    required this.sections,
  });

  factory Paper.fromJson(Json json) => Paper(
    id: json['id']! as String,
    number: json['number']! as int,
    title: json['title']! as String,
    minutes: json['minutes']! as int,
    sections: _list(json['sections'], PaperSection.fromJson),
  );

  final String id;
  final int number;
  final String title;
  final int minutes;
  final List<PaperSection> sections;

  int get questionCount => sections.fold(0, (sum, section) => sum + section.itemIds.length);
}

/// One article of the Guidance section. Body lines: `## heading`, `- bullet`, or a paragraph.
class GuideArticle {
  const GuideArticle({
    required this.id,
    required this.group,
    required this.title,
    required this.lines,
  });

  factory GuideArticle.fromJson(Json json) => GuideArticle(
    id: json['id']! as String,
    group: json['group']! as String,
    title: json['title']! as String,
    lines: (json['lines']! as List<Object?>).cast<String>(),
  );

  final String id;
  final String group;
  final String title;
  final List<String> lines;
}
