# Prep Simulator for LCAT (HomiLabs) — project notes

Flutter Android app: 20 timed LCAT-style mock exams (LUMS Common Admission Test), a topic-wise question bank, and a Guide & Rules section.
Package `lcat_prep`, app id `com.homilabs.lcat_prep` (locked after the first Play upload). Built from the NTS app (`/mnt/storage/projects/nts`).

## Locations
- Code: `/mnt/storage/projects/lcat` · GitHub `AwaizFatima08/lcat` (PUBLIC repo: no secrets)
- Local backup: `/mnt/storage/project_backups/lcat_backup` (`bash scripts/backup.sh`)
- Site: https://lcat.homilabs.org (Hostinger), source in `website/`, deployed from the `deploy` branch by `scripts/publish-site.sh`

## Test pattern (sources in `docs/review-flags.md`)
- LUMS publishes: paper-based, 4 sections (2 Verbal, 2 Math), 40 min each, about 3 hours, options A-D, no calculator; the 8 content domains.
- LUMS does not publish question counts or marking. Our mocks: Verbal 25 + 25, Math 20 + 20 = 90 questions, 160 minutes, no negative marking.
- Each section has its own clock; a finished section is closed (`ExamNotifier.finishSection`).

## Content
- Source: `content/bank/<section>/<topic>.jsonl` (format in `docs/content-schema.md`); topics, quotas and the pattern in `tool/make_blueprint.py` → `content/blueprint.json`; guide in `content/guide.json`.
- Every question and passage is original HomiLabs work (`docs/writer-brief.md`). Never copy LUMS samples, SAT material or prep books.
- `python3 tool/validate.py` checks the bank; `python3 tool/build_content.py` builds `assets/data/` (fixed seed: papers stay stable);
  `tool/blind.py` runs the independent answer check; `tool/equal_options.py` finds equal-valued options. `flutter test test/content` checks the built papers.
- Practice pool is separate from the test pool; no test question appears in two mocks.
- Dated facts (fees, dates, eligibility) live only in `content/guide.json` articles "dates" and "eligibility": update them every admission cycle.

## Ads
Ids in `config/admob.json`. Banner on Home tabs only; interstitial when leaving results or a practice set, 5 minutes apart. Never on exam, review or practice question screens. Debug builds use Google test units.

## Gate before commit
```
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```
Heavy jobs follow `~/.claude/heavy-jobs.md`: use `jobq`, then `./gradlew --stop`.
