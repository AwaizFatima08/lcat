#!/usr/bin/env python3
"""Writes content/blueprint.json: the topic list, per-topic targets and the LCAT paper pattern.

LCAT pattern (LUMS programme pages and the official 2025 sample paper): four paper-based multiple-choice
sections, two Verbal and two Math, 40 minutes each, four options A-D, no calculator. LUMS does not publish
question counts, so each mock uses 25 questions per Verbal section and 20 per Math section (90 in all).
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# section key, title, [(topic key, id prefix, title, domain, per-section quota, practice items, scope note)]
# Test items per topic = quota x 2 sections x 20 papers.
SECTIONS = [
    ("verbal", "Verbal", [
        ("words-in-context", "wc", "Words in Context", "Craft and Structure", 3, 40,
         "A sentence or short text (1-3 sentences) with a blank or an underlined-style quoted word; choose the most logical and precise word or phrase. High-utility academic words, not obscure ones."),
        ("text-structure", "ts", "Text Structure and Purpose", "Craft and Structure", 2, 25,
         "A short text of 60-130 words; ask for its main purpose, overall structure, or the function of one quoted sentence."),
        ("cross-text", "ct", "Cross-Text Connections", "Craft and Structure", 1, 15,
         "Text 1 and Text 2 (each 50-90 words) on one topic; how would the author of Text 2 respond to a claim in Text 1, or how do they relate."),
        ("central-ideas", "ci", "Central Ideas and Details", "Information and Ideas", 1, 20,
         "A short text of 60-130 words; main idea or a supported detail."),
        ("evidence", "ev", "Command of Evidence", "Information and Ideas", 3, 30,
         "Which finding/quotation would best support or weaken a stated claim. About a third quantitative: use the `table` field (or describe a small data set in words) and ask which choice accurately uses the data to complete the text."),
        ("inference", "in", "Inferences", "Information and Ideas", 2, 25,
         "A short text ending in a blank; choose the choice that most logically completes the text."),
        ("boundaries", "bd", "Boundaries (Punctuation)", "Standard English Conventions", 3, 30,
         "Choose the punctuation that completes the text: commas, semicolons, colons, dashes, apostrophes, run-ons and fragments, restrictive vs non-restrictive clauses."),
        ("form-structure-sense", "fs", "Form, Structure and Sense", "Standard English Conventions", 3, 30,
         "Subject-verb agreement, pronoun-antecedent agreement and case, verb tense and form, plurals and possessives, dangling and misplaced modifiers, parallelism."),
        ("transitions", "tr", "Transitions", "Expression of Ideas", 2, 25,
         "Choose the most logical transition word or phrase; logical relationships: contrast, cause, addition, example, sequence, concession."),
        ("rhetorical-synthesis", "rs", "Rhetorical Synthesis", "Expression of Ideas", 1, 15,
         "A student's bulleted notes (4-6 bullets) and a goal; which choice most effectively uses relevant information to accomplish the goal."),
        ("comprehension", "rc", "Reading Comprehension Passages", "Information and Ideas", 4, 24,
         "Sets: one original passage of 280-400 words (science, history, social science, arts, Pakistani or world settings) with 4 questions: main idea or summary, detail, inference, author's purpose or tone or vocabulary in context."),
    ]),
    ("math", "Math", [
        ("linear-equations", "le", "Linear Equations in One Variable", "Algebra", 2, 25,
         "Solving linear equations, including fractions and word problems; equations with no or infinitely many solutions."),
        ("linear-systems", "sy", "Systems of Linear Equations", "Algebra", 2, 25,
         "Two equations in two unknowns, substitution and elimination, word problems, no-solution and infinite-solution conditions."),
        ("linear-functions", "lf", "Linear Functions and Graphs", "Algebra", 2, 25,
         "Slope, intercepts, equations of lines from points, parallel and perpendicular lines, interpreting slope and intercept in context."),
        ("inequalities", "iq", "Linear Inequalities", "Algebra", 1, 25,
         "Solving and interpreting linear inequalities and systems of inequalities in context; absolute-value inequalities."),
        ("quadratics", "qd", "Quadratic Equations and Functions", "Advanced Math", 2, 25,
         "Factoring, the quadratic formula, sum and product of roots, discriminant, vertex form, maximum and minimum, modelling."),
        ("exponents", "ex", "Exponents, Radicals and Exponential Functions", "Advanced Math", 2, 25,
         "Laws of exponents, fractional exponents, radicals, exponential growth and decay, percentage growth models."),
        ("polynomials-rational", "pr", "Polynomials and Rational Expressions", "Advanced Math", 1, 25,
         "Expanding and factoring polynomials, remainder and factor theorem, simplifying rational expressions, rational and radical equations, absolute-value equations."),
        ("functions", "fn", "Functions", "Advanced Math", 1, 25,
         "Function notation, evaluating, composition, inverse, transformations, domain and range, functions given by a table."),
        ("logs-sequences", "lg", "Logarithms and Sequences", "Advanced Math", 1, 25,
         "Logarithm laws and equations (no calculator), arithmetic and geometric sequences and series."),
        ("ratios-percentages", "rp", "Ratios, Rates and Percentages", "Problem-Solving and Data Analysis", 1, 25,
         "Ratios, proportions, unit rates, unit conversion, percentage change, successive discounts, mixtures, speed."),
        ("statistics", "st", "Statistics", "Problem-Solving and Data Analysis", 1, 25,
         "Mean, median, mode, range, effect of changing data, weighted averages, standard deviation (conceptual), sampling and inference from samples."),
        ("probability-data", "pd", "Probability and Data Interpretation", "Problem-Solving and Data Analysis", 1, 25,
         "Simple and conditional probability, two-way tables (use `table`), reading tables of data, counting."),
        ("area-volume", "av", "Area and Volume", "Geometry and Trigonometry", 1, 25,
         "Areas and perimeters of polygons, surface area and volume of prisms, cylinders, cones, spheres; scale factors."),
        ("triangles-trig", "tt", "Lines, Angles, Triangles and Trigonometry", "Geometry and Trigonometry", 1, 25,
         "Angle facts, similar and congruent triangles, Pythagoras, special right triangles, sine, cosine and tangent, radians, trig identities and signs by quadrant."),
        ("circles", "cc", "Circles", "Geometry and Trigonometry", 1, 25,
         "Arc length, sector area, radians, inscribed and central angles, tangents, the equation of a circle (completing the square)."),
    ]),
]

PAPERS = 20
PATTERN = [
    ("verbal-1", "Verbal Section 1", "verbal"),
    ("verbal-2", "Verbal Section 2", "verbal"),
    ("math-1", "Math Section 1", "math"),
    ("math-2", "Math Section 2", "math"),
]
MINUTES_PER_SECTION = 40

uses = {k: sum(1 for _, _, b in PATTERN if b == k) for k, _, _ in SECTIONS}
doc = {
    "sections": [
        {"key": k, "title": t, "topics": [
            {"key": tk, "prefix": p, "title": tt, "domain": d, "quota": q, "test": q * uses[k] * PAPERS, "practice": pr, "scope": s}
            for tk, p, tt, d, q, pr, s in topics
        ]} for k, t, topics in SECTIONS
    ],
    "pattern": [
        {"key": key, "title": title, "section": bank, "minutes": MINUTES_PER_SECTION,
         "questions": sum(t[4] for k, _, ts in SECTIONS if k == bank for t in ts)}
        for key, title, bank in PATTERN
    ],
    "papers": PAPERS,
}
(ROOT / "content/blueprint.json").write_text(json.dumps(doc, indent=1) + "\n")
print("pattern", [(p["title"], p["questions"]) for p in doc["pattern"]],
      "test", sum(t["test"] for s in doc["sections"] for t in s["topics"]),
      "practice", sum(t["practice"] for s in doc["sections"] for t in s["topics"]))
