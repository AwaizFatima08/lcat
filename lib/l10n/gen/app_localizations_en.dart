// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prep Simulator for LCAT';

  @override
  String loadError(String code) {
    return 'Could not load this. Please restart the app. ($code)';
  }

  @override
  String get tabTests => 'Mocks';

  @override
  String get tabPractice => 'Practice';

  @override
  String get tabGuide => 'Guide & Rules';

  @override
  String get tabProgress => 'Progress';

  @override
  String get about => 'About';

  @override
  String testsIntro(int count, int minutes) {
    return '$count questions in $minutes minutes, four options each, no calculator. 20 full mock exams.';
  }

  @override
  String testNumber(int number) {
    return 'Mock exam $number';
  }

  @override
  String bestScore(int percent) {
    return 'Best $percent%';
  }

  @override
  String get inProgress => 'In progress';

  @override
  String get notStarted => 'Not taken';

  @override
  String get startTest => 'Start exam';

  @override
  String get resumeTest => 'Resume exam';

  @override
  String get restartTest => 'Start again';

  @override
  String get paperRules =>
      'Each section has its own 40-minute clock. Inside a section you can move between questions, flag them and change answers. When you finish a section or its time runs out, the next section starts and you cannot go back, as on the paper test. No calculator: keep rough paper and a pencil ready. The clock pauses if you leave the app.';

  @override
  String get unofficialNote =>
      'Independent practice exam. LUMS does not publish question counts or a marking scheme, so the real LCAT can differ. Always follow your own LUMS admission instructions.';

  @override
  String get previousAttempts => 'Previous attempts';

  @override
  String questionOf(int number, int total) {
    return 'Question $number of $total';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get flag => 'Flag';

  @override
  String get unflag => 'Unflag';

  @override
  String get questions => 'Questions';

  @override
  String get clearAnswer => 'Clear answer';

  @override
  String get submit => 'Submit exam';

  @override
  String get submitTitle => 'Submit this exam?';

  @override
  String submitBody(int answered, int total, int flagged) {
    return 'Answered $answered of $total in the whole exam. Flagged $flagged. You cannot change answers after submitting.';
  }

  @override
  String get keepWorking => 'Keep working';

  @override
  String get leaveTitle => 'Leave this exam?';

  @override
  String get leaveBody =>
      'Your answers are saved and the section clock pauses. You can resume from the exam page.';

  @override
  String get leave => 'Leave';

  @override
  String get stay => 'Stay';

  @override
  String get readPassage => 'Show passage';

  @override
  String get hidePassage => 'Hide passage';

  @override
  String get timeLeft => 'Time left';

  @override
  String get results => 'Your result';

  @override
  String scoreOutOf(int correct, int total) {
    return '$correct / $total';
  }

  @override
  String percentLabel(int percent) {
    return '$percent%';
  }

  @override
  String scoreNote(int answered, int skipped) {
    return 'Answered $answered, skipped $skipped. No marks are taken off for wrong answers. This is a practice score, not an LCAT result: LUMS does not release LCAT scores.';
  }

  @override
  String get bySection => 'By section';

  @override
  String get weakTopics => 'Topics to work on';

  @override
  String get reviewAnswers => 'Review answers and explanations';

  @override
  String get backHome => 'Back to mocks';

  @override
  String get filterAll => 'All';

  @override
  String get filterWrong => 'Wrong';

  @override
  String get filterSkipped => 'Skipped';

  @override
  String get filterEmpty => 'Nothing here.';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get correctAnswer => 'Correct answer';

  @override
  String get notAnswered => 'Not answered';

  @override
  String get explanation => 'Explanation';

  @override
  String get practiceIntro =>
      'The question bank, sorted by section, LUMS content domain and topic. You see the answer and explanation straight away. Practice questions are separate from the 20 mock exams.';

  @override
  String practiceTally(int correct, int total) {
    return '$correct of $total right';
  }

  @override
  String get practiceEmpty => 'Questions for this topic are on the way.';

  @override
  String get checkAnswer => 'Check';

  @override
  String get finish => 'Finish';

  @override
  String get practiceAgain => 'Practise again';

  @override
  String get practiceDone => 'Practice finished';

  @override
  String get guideLoading => 'Guidance';

  @override
  String get progressEmpty => 'Finish a mock exam or a practice set to see your progress here.';

  @override
  String get testsTaken => 'Mocks taken';

  @override
  String get averageScore => 'Average';

  @override
  String get bestOverall => 'Best';

  @override
  String get history => 'Mock history';

  @override
  String get topicMastery => 'Weakest topics';

  @override
  String get deleteAttempt => 'Delete';

  @override
  String get aboutBody =>
      'Prep Simulator for LCAT is an independent practice app by HomiLabs. It is not affiliated with, endorsed by or connected to the Lahore University of Management Sciences (LUMS). All questions are original practice material, not real LCAT papers, and scores are for practice only.';

  @override
  String get privacy => 'Privacy policy';

  @override
  String get privacyChoices => 'Privacy choices';

  @override
  String get terms => 'Terms of use';

  @override
  String get website => 'Website';

  @override
  String get contact => 'Contact: homilabs.smc@gmail.com';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get reviewTitle => 'Review answers';

  @override
  String get patternTitle => 'LCAT pattern';

  @override
  String patternLine(String title, int count, int minutes) {
    return '$title: $count questions, $minutes min';
  }

  @override
  String paperSummary(int count, int minutes) {
    return '$count questions · $minutes minutes in four timed sections';
  }

  @override
  String sectionCountTime(int count, int minutes) {
    return '$count Q · $minutes min';
  }

  @override
  String get finishSection => 'Finish section';

  @override
  String finishSectionTitle(String title) {
    return 'Finish $title?';
  }

  @override
  String finishSectionBody(int answered, int total, String next) {
    return 'Answered $answered of $total in this section. $next starts straight away, and you cannot come back to this section.';
  }

  @override
  String sectionStarted(String title, int minutes) {
    return '$title has started: $minutes minutes.';
  }

  @override
  String get sectionLockNote => 'Only this section is open. Finished sections are closed.';

  @override
  String get byPart => 'Verbal and Math';

  @override
  String sectionBankCount(int count) {
    return '$count practice questions';
  }

  @override
  String practiceCount(int count) {
    return '$count questions';
  }
}
