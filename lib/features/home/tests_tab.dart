import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lcat_prep/app.dart';
import 'package:lcat_prep/attempts/attempt.dart';
import 'package:lcat_prep/attempts/attempt_repository.dart';
import 'package:lcat_prep/content/content_repository.dart';
import 'package:lcat_prep/content/models.dart';
import 'package:lcat_prep/ui/async_value_view.dart';
import 'package:lcat_prep/ui/theme.dart';

class TestsTab extends ConsumerWidget {
  const TestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncBody(
    value: ref.watch(catalogProvider),
    data: (catalog) => AsyncBody(
      value: ref.watch(papersProvider),
      data: (papers) => _TestsList(catalog: catalog, papers: papers),
    ),
  );
}

class _TestsList extends ConsumerWidget {
  const _TestsList({required this.catalog, required this.papers});

  final Catalog catalog;
  final List<Paper> papers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final attempts = ref.watch(attemptsProvider).value ?? const <Attempt>[];
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.patternTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                for (final part in catalog.pattern)
                  Text(l10n.patternLine(part.title, part.questionCount, part.minutes)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.testsIntro(catalog.questionCount, catalog.minutes),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final paper in papers) _PaperTile(paper: paper, attempts: attempts),
      ],
    );
  }
}

class _PaperTile extends StatelessWidget {
  const _PaperTile({required this.paper, required this.attempts});

  final Paper paper;
  final List<Attempt> attempts;

  String _status(BuildContext context) {
    final mine = [
      for (final attempt in attempts)
        if (attempt.paperId == paper.id) attempt,
    ];
    final l10n = context.l10n;
    if (mine.any((attempt) => !attempt.isFinished)) return l10n.inProgress;
    if (mine.isEmpty) return l10n.notStarted;
    final best = mine.map((attempt) => attempt.percent).reduce((a, b) => a > b ? a : b);
    return l10n.bestScore(best);
  }

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(child: Text('${paper.number}')),
      title: Text(context.l10n.testNumber(paper.number)),
      subtitle: Text(_status(context)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => unawaited(context.push('/paper/${paper.id}')),
    ),
  );
}
