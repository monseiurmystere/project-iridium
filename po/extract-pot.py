#!/usr/bin/env python3
"""Extracts iridium.pot from Vala sources, generated Blueprint .ui files and
data files. Run: meson compile -C build iridium-pot (then msgmerge into po/).
xgettext cannot parse .blp, so the generated .ui files are used instead.
Each group gets its own xgettext run (language flags leak across groups
otherwise); the parts are merged with msgcat."""
import subprocess
import sys
import tempfile
from pathlib import Path

srcdir, src_builddir, out = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]

base = ["xgettext", "--from-code=UTF-8", "--package-name=iridium",
        "--keyword=_", "--keyword=N_", "--add-comments"]
groups = [
    ([str(p) for p in sorted((srcdir / "src").rglob("*.vala"))], []),
    ([str(p) for p in sorted(src_builddir.rglob("*.ui"))], ["-L", "Glade"]),
    ([str(srcdir / "data/co.tylr.Iridium.desktop.in")], ["-L", "Desktop"]),
    ([str(srcdir / "data/co.tylr.Iridium.metainfo.xml.in")], ["-L", "AppData"]),
]

parts = []
with tempfile.TemporaryDirectory() as tmp:
    for i, (files, lang) in enumerate(groups):
        part = str(Path(tmp) / f"part{i}.pot")
        subprocess.run(base + lang + ["-o", part] + files, check=True)
        parts.append(part)
    subprocess.run(["msgcat", "--use-first"] + parts + ["-o", out], check=True)
print(f"wrote {out}")
