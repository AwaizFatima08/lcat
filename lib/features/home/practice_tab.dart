import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lcat_prep/app.dart';
import 'package:lcat_prep/content/content_repository.dart';
import 'package:lcat_prep/settings/settings_repository.dart';
import 'package:lcat_prep/ui/async_value_view.dart';
import 'package:lcat_prep/ui/theme.dart';

class PracticeTab extends ConsumerWidget {
  const PracticeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tally = ref.watch(practiceTallyProvider).value ?? const <String, List<int>>{};
    return AsyncBody(
      value: ref.watch(catalogProvider),
      data: (catalog) => ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          Text(context.l10n.practiceIntro),
          const SizedBox(height: AppSpacing.sm),
          for (final section in catalog.sections)
            Card(
              child: ExpansionTile(
                initiallyExpanded: true,
                title: Text(section.title),
                subtitle: Text(
                  context.l10n.sectionBankCount(
                    section.topics.fold(0, (sum, topic) => sum + topic.practiceCount),
                  ),
                ),
                children: [
                  for (final MapEntry(key: domain, value: topics) in section.byDomain.entries) ...[
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        0,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(domain, style: Theme.of(context).textTheme.labelLarge),
                      ),
                    ),
                    for (final topic in topics)
                      ListTile(
                        title: Text(topic.title),
                        subtitle: Text(switch (tally['${section.key}/${topic.key}']) {
                          [final correct, final total] => context.l10n.practiceTally(
                            correct,
                            total,
                          ),
                          _ => context.l10n.practiceCount(topic.practiceCount),
                        }),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            unawaited(context.push('/practice/${section.key}/${topic.key}')),
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
