# Release and hosting kit: Prep Simulator for LCAT

## Build
- Package `com.homilabs.lcat_prep` (locked after the first Play upload). Version 1.0.0 (versionCode 1).
- Debug: `jobq run --name lcat-debug-apk -- flutter build apk --debug`.
- Release: `jobq run --name lcat-release-aab -- flutter build appbundle --release`, then `./gradlew --stop` in `android/`.
- Before every release: `bash scripts/check-release-ad-ids.sh`, `python3 tool/validate.py`, `flutter test`.
- Signing (set up 9 Nov 2026): upload keystore `.secrets/lcat-upload.keystore`, alias `lcat-upload`, RSA 2048, valid 10,000 days. Passwords in `.secrets/lcat-upload-keystore-credentials.txt`; `android/key.properties` points at it. Both are gitignored and only in the local backup — keep a second copy off this machine. Upload certificate SHA-256 `AB:F7:4B:EA:A7:7D:E5:64:A7:A7:C9:A2:34:27:B8:4C:E6:AD:A7:A6:96:2A:40:8A:7B:82:36:45:C5:07:55:D5`. Use Play App Signing; this is the upload key only.
- First bundle: 1.0.0 (code 1), 48.8 MB, built 9 Nov 2026. Raise `version:` in pubspec.yaml before each new upload.

## Website: https://lcat.homilabs.org
- PHP/HTML website in hPanel (created 9 Nov 2026), deployed by Hostinger Git from the `deploy` branch into `public_html`.
- Change `website/`, commit, then `bash scripts/publish-site.sh`, then press Deploy in hPanel → Advanced → GIT if auto-deploy has not picked it up. Flush the CDN cache if pages look stale.
- Pages: landing, `/privacy.html`, `/terms.html`, `/app-ads.txt`.
- Play link on the landing page since approval (10 Nov 2026): https://play.google.com/store/apps/details?id=com.homilabs.lcat_prep. Still to do: add the app to homilabs.org.

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

## Play submission (9 Nov 2026)
- Play Console app id 4972305870071878272 (HomiLabs organisation account). Production release 1 (1.0.0), full rollout, 177 countries + rest of world.
- Listing: Education; contact homilabs.smc@gmail.com, https://lcat.homilabs.org; 7 phone screenshots from `store-assets/screenshots/phone/`; no tablet screenshots yet.
- Declarations: ads yes, no sign-in, target audience 18+, AI asset label not used. Data safety: approximate location, crash logs, diagnostics, app interactions, device IDs; collected and shared (AdMob) for analytics, advertising, fraud prevention; required; encrypted in transit; no accounts.
- Sent for review 9 Nov 2026, approved and live 10 Nov 2026: https://play.google.com/store/apps/details?id=com.homilabs.lcat_prep. Play link on the website since 10 Nov 2026.

## AdMob
- Account homilabs.smc@gmail.com. App "Prep Simulator for LCAT", ID `ca-app-pub-2087846699268567~9430766791` (created 9 Nov 2026); units in `config/admob.json`. Debug builds use Google test units.
- Play store linked to the AdMob app 10 Nov 2026 (searched by the full listing URL). app-ads.txt verification first said "details don't match" although lcat.homilabs.org/app-ads.txt and homilabs.org/app-ads.txt both serve the exact line AdMob asks for; GRE had the same on launch day and verified on its own the next day. Re-check in AdMob → Apps → this app → App settings; limited ad serving lifts after verification and AdMob's app review.
- `app-ads.txt` is live at https://lcat.homilabs.org/app-ads.txt.
- Consent: create and publish a European regulations message for this app (Privacy & messaging) before serving EEA/UK users.

## Before production (open items)
- Homi reviews `docs/review-flags.md`.
- Trademark: the name uses "LCAT" and "LUMS" descriptively with a not-affiliated notice in the About screen, listing and website; Play can still ask for proof of permission.
- Phone and tablet screenshots (2-8) for the listing.
