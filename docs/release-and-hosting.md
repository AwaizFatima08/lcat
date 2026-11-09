# Release and hosting kit: Prep Simulator for LCAT

## Build
- Package `com.homilabs.lcat_prep` (locked after the first Play upload). Version 1.0.0 (versionCode 1).
- Debug: `jobq run --name lcat-debug-apk -- flutter build apk --debug`.
- Release: `jobq run --name lcat-release-aab -- flutter build appbundle --release`, then `./gradlew --stop` in `android/`.
- Before every release: `bash scripts/check-release-ad-ids.sh`, `python3 tool/validate.py`, `flutter test`.
- Signing: not set up yet. Create an upload keystore in `.secrets/` (gitignored) and `android/key.properties`, as in the NTS app. Without it, release builds are unsigned.

## Website: https://lcat.homilabs.org
- PHP/HTML website in hPanel (created 9 Nov 2026), deployed by Hostinger Git from the `deploy` branch into `public_html`.
- Change `website/`, commit, then `bash scripts/publish-site.sh`, then press Deploy in hPanel → Advanced → GIT if auto-deploy has not picked it up. Flush the CDN cache if pages look stale.
- Pages: landing, `/privacy.html`, `/terms.html`, `/app-ads.txt`.
- After Play launch: replace "Coming soon on Google Play" with the Play link, and add the app to homilabs.org.

## Play Console
| Item | Value |
|---|---|
| App icon 512×512 | `store-assets/icon-512.png` |
| Feature graphic | `store-assets/feature-graphic.png` |
| Privacy policy URL | https://lcat.homilabs.org/privacy.html |
| Website | https://lcat.homilabs.org |
| Contact email | homilabs.smc@gmail.com |
| Ads | Yes (AdMob banner on home tabs; one interstitial after results or practice) |
| App access | All functionality available without login |
| Data safety | Collected and shared: Device or other IDs (advertising ID) and app activity via the ads SDK, purpose Advertising, shared with Google AdMob; encrypted in transit. Attempts stay on the device |
| Content rating | Reference/educational; No to violence, sexuality, language, drugs, gambling, purchases, user interaction |
| Target audience | 13+ |
| Category | Education |

**App name** (23 characters): `Prep Simulator for LCAT`

**Short description** (80 max): `20 timed LUMS LCAT-style mocks, a Verbal and Math question bank, all explained.`

**Full description**:
```
Prepare for the LUMS Common Admission Test (LCAT) the way it feels on the day. Prep Simulator for LCAT gives you full mock exams timed section by section, a question bank sorted by topic, and the rules in one place.

20 FULL MOCK EXAMS
• Four sections like the paper test: Verbal 1, Verbal 2, Math 1 and Math 2, 40 minutes each.
• 90 questions per mock, four options each, no calculator.
• Each section has its own clock. When a section ends you move on and cannot go back, as on the day.

SCORES THAT HELP
• Your result by section, Verbal and Math totals, and the topics to work on next.
• Every question explained after the mock, with the working or the grammar rule and why the tempting option is wrong.

QUESTION BANK BY TOPIC
• Sorted by section, LUMS content domain and topic: words in context, text structure, cross-text, central ideas, evidence and data, inferences, punctuation, grammar, transitions, notes, reading passages; linear equations and systems, functions, inequalities, quadratics, exponents, polynomials, logarithms and sequences, ratios and percentages, statistics, probability, area and volume, triangles and trigonometry, circles.
• Instant answers and explanations. Practice questions are separate from the 20 mocks.

GUIDE AND RULES
• Who needs the LCAT, the test pattern, test-day rules and documents, marking, formulas, grammar rules, time management and study plans.

PRIVATE AND OFFLINE
• Works offline, with no account. Your scores stay on your phone.
• Free, with light ads, never during a mock.

Prep Simulator for LCAT is independent practice material by HomiLabs. It is not affiliated with, endorsed by or connected to the Lahore University of Management Sciences (LUMS). All questions are original practice material, not real LCAT papers, and scores are for practice only. Always follow the latest LUMS admission instructions.
```

## AdMob
- Account homilabs.smc@gmail.com. App "Prep Simulator for LCAT", ID `ca-app-pub-2087846699268567~9430766791` (created 9 Nov 2026); units in `config/admob.json`. Debug builds use Google test units.
- "Limited ad serving" until the Play listing is live: after publishing, AdMob → Apps → this app → Add store (com.homilabs.lcat_prep).
- `app-ads.txt` is live at https://lcat.homilabs.org/app-ads.txt.
- Consent: create and publish a European regulations message for this app (Privacy & messaging) before serving EEA/UK users.

## Before production (open items)
- Homi reviews `docs/review-flags.md`.
- Trademark: the name uses "LCAT" and "LUMS" descriptively with a not-affiliated notice in the About screen, listing and website; Play can still ask for proof of permission.
- Phone and tablet screenshots (2-8) for the listing.
