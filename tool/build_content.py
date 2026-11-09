#!/usr/bin/env python3
"""Builds assets/data from content/bank and content/guide.json: one bank file per section, forms.json, catalog.json.

Run after any bank change. Same input gives the same 20 papers (fixed seed), so paper ids stay stable.
Each paper follows the blueprint pattern (Verbal 1, Verbal 2, Math 1, Math 2). The test pool of a topic is dealt
into one slot per paper section of that kind (40 slots for 20 papers x 2 sections), so no test question appears twice.
  python3 tool/build_content.py            needs the full bank
  python3 tool/build_content.py --partial  skips papers that cannot be filled (development only)
"""
import collections, json, random, re, shutil, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets/data"
BP = json.loads((ROOT / "content/blueprint.json").read_text())
PAPERS = BP["papers"]
PARTIAL = "--partial" in sys.argv


def load():
    sets, questions = {}, collections.defaultdict(list)
    for path in sorted((ROOT / "content/bank").glob("*/*.jsonl")):
        section, topic = path.parent.name, re.sub(r"-\d+$", "", path.stem)
        for line in path.read_text().splitlines():
            if not line.strip():
                continue
            row = json.loads(line)
            if row.get("type") == "set":
                sets[row["id"]] = row
            else:
                row["section"], row["topic"] = section, topic
                questions[(section, topic, row["pool"])].append(row)
    return sets, questions


def deal(items, seed, slots):
    """Splits items across slots so each gets the same spread of levels. Sets stay whole."""
    rng = random.Random(seed)
    groups = collections.OrderedDict()
    for q in items:
        groups.setdefault(q.get("set") or q["id"], []).append(q)
    groups = list(groups.values())
    rng.shuffle(groups)
    groups.sort(key=lambda g: sum(q["level"] for q in g) / len(g))
    start = rng.randrange(slots)  # so the odd extra hard question does not always land in slot 1
    out = [[] for _ in range(slots)]
    for i, group in enumerate(groups):
        out[(start + i) % slots].append(group)
    for s in out:
        rng.shuffle(s)
    return out


def take(groups, count):
    """First `count` questions from a slot's groups; a set keeps its questions together and in order."""
    out = []
    for g in groups:
        if len(out) >= count:
            break
        out += g
    return out[:count] if len(out) >= count else out


def order(items, rank):
    """Paper order inside a section: by topic order of the blueprint, sets kept together, easier first within a topic."""
    return sorted(items, key=lambda q: (rank[q["topic"]], q.get("set") or "", q["level"] if "set" not in q else 0, q["id"]))


def check(forms, questions):
    level = {q["id"]: q["level"] for items in questions.values() for q in items}
    ids = [i for form in forms for part in form["sections"] for i in part["items"]]
    repeats = [i for i, n in collections.Counter(ids).items() if n > 1]
    if repeats:
        sys.exit(f"{len(repeats)} questions repeat across papers, e.g. {repeats[:3]}")
    for form in forms:
        mine = [i for part in form["sections"] for i in part["items"]]
        hard = sum(level[i] == 3 for i in mine) / len(mine)
        if not 0.08 <= hard <= 0.32:
            sys.exit(f"{form['id']}: {hard:.0%} hard questions is outside 8-32%")
    unused = {q["id"] for (s, t, pool), items in questions.items() if pool == "test" for q in items} - set(ids)
    if unused:
        print(f"note: {len(unused)} spare test questions not used in papers, e.g. {sorted(unused)[:5]}")


def main():
    sets, questions = load()
    sections = {s["key"]: s for s in BP["sections"]}
    slots_of = collections.Counter(p["section"] for p in BP["pattern"])
    dealt = {}
    for sec in BP["sections"]:
        for t in sec["topics"]:
            dealt[(sec["key"], t["key"])] = deal(questions[(sec["key"], t["key"], "test")], f"{sec['key']}/{t['key']}", PAPERS * slots_of[sec["key"]])

    forms, skipped = [], 0
    for k in range(PAPERS):
        seen = collections.Counter()
        parts, ok = [], True
        for part in BP["pattern"]:
            bank = part["section"]
            slot = k * slots_of[bank] + seen[bank]
            seen[bank] += 1
            rank = {t["key"]: i for i, t in enumerate(sections[bank]["topics"])}
            items = []
            for t in sections[bank]["topics"]:
                have = take(dealt[(bank, t["key"])][slot], t["quota"])
                if len(have) < t["quota"]:
                    if not PARTIAL:
                        sys.exit(f"cannot build paper {k + 1}: {bank}/{t['key']} short {len(have)}/{t['quota']}")
                    ok = False
                items += have
            parts.append({"key": part["key"], "bank": bank, "title": part["title"], "minutes": part["minutes"],
                          "items": [q["id"] for q in order(items, rank)]})
        if not ok:
            skipped += 1
            continue
        forms.append({"id": f"lcat-{k + 1:02d}", "number": k + 1, "title": f"LCAT Mock {k + 1}",
                      "minutes": sum(p["minutes"] for p in parts), "sections": parts})

    if not PARTIAL:
        check(forms, questions)
    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir(parents=True)
    for s in BP["sections"]:
        rows, used_sets = [], {}
        for t in s["topics"]:
            for pool in ("test", "practice"):
                for q in questions[(s["key"], t["key"], pool)]:
                    row = {"id": q["id"], "tp": t["key"], "pl": pool[0], "lv": q["level"], "s": q["stem"], "o": q["options"], "a": q["answer"], "e": q["explanation"]}
                    if "set" in q:
                        row["st"] = q["set"]
                        used_sets[q["set"]] = {"t": sets[q["set"]].get("title", ""), "x": sets[q["set"]]["text"]}
                    if "table" in q:
                        row["tb"] = q["table"]
                    rows.append(row)
        (OUT / f"bank_{s['key']}.json").write_text(json.dumps({"sets": used_sets, "questions": rows}, ensure_ascii=False, separators=(",", ":")))
    catalog = {
        "sections": [{"key": s["key"], "title": s["title"], "topics": [
            {"key": t["key"], "title": t["title"], "domain": t["domain"], "practice": len(questions[(s["key"], t["key"], "practice")]),
             "bank": len(questions[(s["key"], t["key"], "practice")]) + len(questions[(s["key"], t["key"], "test")])}
            for t in s["topics"]
        ]} for s in BP["sections"]],
        "pattern": BP["pattern"],
    }
    (OUT / "catalog.json").write_text(json.dumps(catalog, ensure_ascii=False, separators=(",", ":")))
    (OUT / "forms.json").write_text(json.dumps(forms, separators=(",", ":")))
    guide = ROOT / "content/guide.json"
    if guide.exists():
        shutil.copy(guide, OUT / "guide.json")
    size = sum(f.stat().st_size for f in OUT.iterdir())
    print(f"{len(forms)} papers built, {skipped} skipped, {sum(len(v) for v in questions.values())} questions, {size / 1e6:.1f} MB")


main()
