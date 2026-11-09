# Writer brief: Prep Simulator for LCAT

You write original multiple-choice questions for a HomiLabs Android app that helps Pakistani students prepare for the LCAT (LUMS Common Admission Test), the admission test of the Lahore University of Management Sciences. Accuracy matters more than speed: one wrong key damages a candidate's trust.

## The test
- Paper-based, four sections: two Verbal and two Math, 40 minutes each. Four options A-D. **No calculator.**
- LUMS describes it as "like the SAT", with these domains. Verbal: Craft and Structure, Information and Ideas, Standard English Conventions, Expression of Ideas. Math: Algebra, Advanced Math, Problem-Solving and Data Analysis, Geometry and Trigonometry. Its sample paper also has a long comprehension passage with several questions, sequences, logarithms and trigonometry.
- Level: the strongest A-Level / FSc candidates should find hard items hard; average candidates should get most easy items.

## Format
Read `docs/content-schema.md` and `content/blueprint.json` (your topics' prefix, counts, scope). Write `content/bank/<section>/<topic>.jsonl`. Write in chunks of at most 30 questions per tool call (append with Bash heredocs, `cat >> file <<'EOF'`), and run `python3 tool/validate.py --files <your files>` after each chunk until it reports 0 errors. Each topic needs its `test` count with ids `<prefix>-t0001…` and its `practice` count with ids `<prefix>-p0001…`. Write a few more test items than asked only if told to.

## Rules
- Original work only. Never copy or closely reword LUMS sample questions, SAT/College Board material, prep books or websites. Invent your own texts, numbers and scenarios.
- English as used in Pakistan's A-Level and university settings. Where a context helps, make it feel Pakistani or global (Ayesha, Bilal, Hunza, Karachi, rupees, a Lahore start-up, a biology lab) but keep it varied: science, history, literature, economics, technology, arts.
- Exactly one correct option. Wrong options must be clearly wrong on reflection, plausible, and drawn from real mistakes. No "all/none of the above", no "both A and B". No trick wording.
- Options of similar length and form. The correct option must not stand out: it is the longest option no more often than the others. The validator warns above 40 %; a file with that WARN is not finished. Spread the correct answer evenly over A-D, no pattern.
- Plain Unicode for maths: x², √2, π, ½, ≤, ≥, ×, ÷, −, θ, log₂ 8, f⁻¹(x). Never LaTeX. Never refer to a figure or graph you cannot show: describe geometry fully in words. Numbers of 1,000 or more take a comma.
- Levels about 30 % easy (1), 50 % medium (2), 20 % hard (3), in both pools.
- A test question reads like the real test: concise, no hints. Verbal items take about 1½ minutes, math items about 2 minutes without a calculator, so keep arithmetic hand-friendly.
- Vary question shapes, numbers and scenarios. No near-duplicates within or across files. Check what already exists in your topic files before continuing.
- Explanations teach: show the working or the rule, then say why the tempting wrong option fails. 1-4 sentences. Do not start with "The answer is".

## Verbal specifics
- The stem contains the short text and then the question, separated by a blank line (`\n\n`). Show a blank as `______`. For a quoted word in context, put it in double quotes.
- Typical question lines: "Which choice completes the text with the most logical and precise word or phrase?", "Which choice best states the main purpose of the text?", "Which choice completes the text so that it conforms to the conventions of Standard English?", "Which choice completes the text with the most logical transition?", "Which choice most logically completes the text?", "Which finding, if true, would most directly support the researcher's claim?", "The student wants to … Which choice most effectively uses relevant information from the notes to accomplish this goal?" Vary them where natural.
- Conventions items: the text is one or two sentences with a blank; the four options are versions of the missing part. Test one rule per item and say the rule in the explanation.
- Data items: use the `table` field (header row first, up to 6 rows) and refer to "the table" in the stem.
- Facts in texts: you may invent researchers, studies and figures (say "a researcher", "a 2019 survey" or invent a plausible name) but never misstate real, checkable facts about real people, places or science.

## Math specifics
- Solve every question yourself twice before writing the key, and check that exactly one option matches. For anything computed, write a throwaway Python check in your scratch folder and run it. Make distractors from real slips (sign error, forgetting to square, wrong formula).
- No calculator: choose numbers that work by hand. Leave answers like 4√3 or 6π in exact form when natural.
- Put units in the options where relevant. Currency: rupees (Rs 1,500) or plain numbers.

## Boundaries
Only write the files in your task, plus your scratch folder (given in your task). Do not edit tools, the blueprint or other topics' files. Do not run git. The final reply is at most 6 lines: files, question counts, validator result, anything you are unsure about.
