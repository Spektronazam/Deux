#!/usr/bin/env python3
"""
Collapse decorative banner-rule comment blocks of the form:

    ------------------------------------------------------------------------
    -- HEADING TEXT
    ------------------------------------------------------------------------

into a single line:

    -- HEADING TEXT

Matches the tone of Moon's original Lib.lua / ScriptViewer.lua. Only
operates on rule lines that are >= 24 dashes, so genuine short `--`
comments are untouched.
"""

import re
import sys
from pathlib import Path

RULE_RE = re.compile(r"^[ \t]*-{24,}[ \t]*$")
CAPTION_RE = re.compile(r"^([ \t]*)-- ?(.*)$")


def collapse(path: Path) -> int:
    src = path.read_text(encoding="utf-8")
    lines = src.split("\n")
    out = []
    i = 0
    n = len(lines)
    collapsed = 0

    while i < n:
        if (
            i + 2 < n
            and RULE_RE.match(lines[i])
            and CAPTION_RE.match(lines[i + 1])
            and RULE_RE.match(lines[i + 2])
        ):
            m = CAPTION_RE.match(lines[i + 1])
            indent, caption = m.group(1), m.group(2).strip()
            if caption and caption == caption.upper() and any(c.isalpha() for c in caption):
                caption = caption[0] + caption[1:].lower()
            out.append(f"{indent}-- {caption}")
            i += 3
            collapsed += 1
            continue
        out.append(lines[i])
        i += 1

    new_src = "\n".join(out)
    if new_src != src:
        path.write_text(new_src, encoding="utf-8")
    return collapsed


if __name__ == "__main__":
    total = 0
    for p in sys.argv[1:]:
        path = Path(p)
        if not path.exists():
            print(f"skip (missing): {p}")
            continue
        n = collapse(path)
        total += n
        print(f"{p}: collapsed {n} banner(s)")
    print(f"total: {total}")
