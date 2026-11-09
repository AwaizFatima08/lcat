import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lcat_prep/app.dart';
import 'package:lcat_prep/attempts/attempt.dart';
import 'package:lcat_prep/attempts/attempt_repository.dart';
import 'package:lcat_prep/content/content_repository.dart';
import 'package:lcat_prep/content/models.dart';
import 'package:lcat_prep/core/result.dart';
import 'package:lcat_prep/ui/async_value_view.dart';
import 'package:lcat_prep/ui/theme.dart';

/// Pattern of one paper, the start or resume button, and past attempts.
class PaperScreen extends ConsumerWidget {
  const PaperScreen({required this.paperId, super.key});

  final String paperId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AsyncValueView(
    value: ref.watch(papersProvider),
    data: (papers) {
      final paper = papers.firstWhere((candidate) => candidate.id == paperId);
      return Scaffold(
        appBar: AppBar(title: Text(paper.title)),
        body: AsyncBody(
          value: ref.watch(attemptsProvider),
          data: (attempts) => _PaperBody(
            paper: paper,
            attempts: [
              for (final attempt in attempts)
                if (attempt.paperId == paper.id) attempt,
            ],
          ),
        ),
      );
    },
  );
}

class _PaperBody extends ConsumerWidget {
  const _PaperBody({required this.paper, required this.attempts});

  final Paper paper;
  final List<Attempt> attempts;

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final started = await ref
        .read(attemptRepositoryProvider)
        .start(paperId: paper.id, firstSectionMinutes: paper.sections.first.minutes);
    if (started case Ok(:final value) when context.mounted) {
      unawaited(context.push('/exam/${value.id}'));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final open = attempts.where((attempt) => !attempt.isFinished).firstOrNull;
    final finished = [...attempts.where((attempt) => attempt.isFinished)];
    return ListView(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        Text(
          l10n.paperSummary(paper.questionCount, paper.minutes),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final section in paper.sections)
          ListTile(
            dense: true,
            title: Text(section.title),
            trailing: Text(l10n.sectionCountTime(section.itemIds.length, section.minutes)),
          ),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.paperRules),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.unofficialNote, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.md),
        if (open != null) ...[
          FilledButton(
            onPressed: () => unawaited(context.push('/exam/${open.id}')),
            child: Text(l10n.resumeTest),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () async {
              await ref.read(attemptRepositoryProvider).delete(open.id);
              if (context.mounted) await _start(context, ref);
            },
            child: Text(l10n.restartTest),
          ),
        ] else
          FilledButton(
            onPressed: () => unawaited(_start(context, ref)),
            child: Text(l10n.startTest),
          ),
        if (finished.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.previousAttempts, style: Theme.of(context).textTheme.titleMedium),
          for (final attempt in finished)
            ListTile(
              title: Text(l10n.percentLabel(attempt.percent)),
              subtitle: Text(l10n.scoreOutOf(attempt.correct ?? 0, attempt.total ?? 0)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(context.push('/results/${attempt.id}')),
            ),
        ],
      ],
    );
  }
}
