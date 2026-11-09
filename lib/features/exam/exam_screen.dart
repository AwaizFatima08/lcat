import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lcat_prep/app.dart';
import 'package:lcat_prep/features/exam/exam_notifier.dart';
import 'package:lcat_prep/features/exam/exam_widgets.dart';
import 'package:lcat_prep/ui/async_value_view.dart';
import 'package:lcat_prep/ui/question_view.dart';
import 'package:lcat_prep/ui/theme.dart';

class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({required this.attemptId, super.key});

  final String attemptId;

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> with WidgetsBindingObserver {
  ExamNotifier get _notifier => ref.read(examProvider(widget.attemptId).notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused) unawaited(_notifier.pauseTimer());
    if (lifecycle == AppLifecycleState.resumed) _notifier.resumeTimer();
  }

  Future<void> _confirmLeave() async {
    final l10n = context.l10n;
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveTitle),
        content: Text(l10n.leaveBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.stay)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.leave)),
        ],
      ),
    );
    if (leave != true) return;
    await _notifier.pauseTimer();
    if (mounted) context.pop();
  }

  /// Confirms closing the open section; on the last section this submits the paper.
  Future<void> _confirmFinish(ExamState exam) async {
    final l10n = context.l10n;
    final last = exam.isLastSection;
    final finish = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(last ? l10n.submitTitle : l10n.finishSectionTitle(exam.section.title)),
        content: Text(
          last
              ? l10n.submitBody(
                  exam.attempt.answers.length,
                  exam.sitting.questions.length,
                  exam.attempt.flagged.length,
                )
              : l10n.finishSectionBody(
                  exam.sectionAnswered,
                  exam.section.itemIds.length,
                  exam.sitting.sections[exam.attempt.sectionIndex + 1].title,
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.keepWorking),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(last ? l10n.submit : l10n.finishSection),
          ),
        ],
      ),
    );
    if (finish == true) await _notifier.finishSection();
  }

  Future<void> _openPalette(ExamState exam) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => QuestionPalette(
      exam: exam,
      onPick: (index) {
        Navigator.pop(context);
        unawaited(_notifier.goTo(index));
      },
      onFinish: () {
        Navigator.pop(context);
        unawaited(_confirmFinish(exam));
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final provider = examProvider(widget.attemptId);
    ref.listen(provider, (previous, next) {
      final exam = next.value;
      if (exam == null) return;
      if (exam.attempt.isFinished) {
        context.pushReplacement('/results/${widget.attemptId}');
        return;
      }
      final before = previous?.value?.attempt.sectionIndex;
      if (before != null && before != exam.attempt.sectionIndex) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.sectionStarted(exam.section.title, exam.section.minutes)),
          ),
        );
      }
    });
    return AsyncValueView(
      value: ref.watch(provider),
      data: (exam) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(_confirmLeave());
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(exam.section.title),
            actions: [TimerLabel(seconds: exam.attempt.remainingSeconds)],
          ),
          body: _ExamBody(exam: exam, notifier: _notifier),
          bottomNavigationBar: ExamBar(
            exam: exam,
            onPrevious: () => unawaited(_notifier.goTo(exam.attempt.currentIndex - 1)),
            onNext: () => unawaited(_notifier.goTo(exam.attempt.currentIndex + 1)),
            onPalette: () => unawaited(_openPalette(exam)),
            onFinish: () => unawaited(_confirmFinish(exam)),
          ),
        ),
      ),
    );
  }
}

class _ExamBody extends StatelessWidget {
  const _ExamBody({required this.exam, required this.notifier});

  final ExamState exam;
  final ExamNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final question = exam.question;
    final chosen = exam.attempt.answers[question.id];
    final flagged = exam.attempt.flagged.contains(question.id);
    final l10n = context.l10n;
    return ListView(
      key: PageStorageKey(question.id),
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      children: [
        Text(
          l10n.questionOf(
            exam.attempt.currentIndex - exam.sectionStart + 1,
            exam.section.itemIds.length,
          ),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        QuestionHeader(question: question, set: exam.sitting.sets[question.setId]),
        for (var i = 0; i < question.options.length; i++)
          OptionBubble(
            index: i,
            text: question.options[i],
            mark: chosen == i ? OptionMark.selected : OptionMark.none,
            onTap: () => unawaited(notifier.choose(i)),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () => unawaited(notifier.toggleFlag()),
              icon: Icon(flagged ? Icons.flag : Icons.outlined_flag, color: AppColors.flagged),
              label: Text(flagged ? l10n.unflag : l10n.flag),
            ),
            if (chosen != null)
              TextButton(
                onPressed: () => unawaited(notifier.clearAnswer()),
                child: Text(l10n.clearAnswer),
              ),
          ],
        ),
      ],
    );
  }
}
