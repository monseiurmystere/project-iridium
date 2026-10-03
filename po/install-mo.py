#!/usr/bin/env python3
"""Compiles po/*.po to $DESTDIR$localedir/<lang>/LC_MESSAGES/iridium.mo."""
import os
import subprocess
import sys
from pathlib import Path

localedir = Path(os.environ.get("MESON_INSTALL_DESTDIR_PREFIX", "")) / sys.argv[1]
srcdir = Path(os.environ["MESON_SOURCE_ROOT"])
for lang in sys.argv[2:]:
    dest = localedir / lang / "LC_MESSAGES"
    dest.mkdir(parents=True, exist_ok=True)
    subprocess.run(["msgfmt", str(srcdir / "po" / f"{lang}.po"),
                    "-o", str(dest / "iridium.mo")], check=True)
