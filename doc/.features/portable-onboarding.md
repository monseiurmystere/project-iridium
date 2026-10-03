# Portable onboarding

**Status:** Idea (Fedora script exists; ports requested).

## Goal
First-time setup on non-Fedora distributions, reusing the structure of
`tools/onboard.sh` (groups, opt-in flags, `--check`).

## Decisions
- One script per package manager family, or flags within one script —
  contributor's choice, but `--check` semantics must match.
- Fedora remains the reference: ports map its package lists 1:1, including
  `-devel` equivalents, the vala-lint source build, and the langpack/RPM
  Fusion equivalents (or documented "no equivalent" with a fallback).
- Progress and help wanted:
  [11-contributing-requests](../11-contributing-requests.md).

## Per-manager package mapping (to fill in)

| Fedora (reference) | apt (Debian/Ubuntu) | pacman (Arch) | apk (Alpine) |
|---|---|---|---|
| vala | | | |
| meson ninja-build gcc | | | |
| gtk4-devel libadwaita-devel | | | |
| blueprint-compiler | | | |
| taglib-devel json-glib-devel | | | |
| gettext desktop-file-utils appstream | | | |
| flatpak-builder | | | |
| clang-tools-extra libvala-devel | | | |
| glibc-langpack-* | | | |
| ffmpeg (any build with libmp3lame; Fedora's -free qualifies) | | | |

## Acceptance
Fresh install of the target distro + ported script: `meson setup build`,
`meson compile -C build`, `meson test -C build` all green, and
`tools/onboard.sh --check`-equivalent reports READY.

## Risks
- Package-name drift across releases (pin the distro version tested).
- vala-lint source build needs `libvala` dev files everywhere; confirm the
  equivalent package name per distro.
- Flatpak SDK steps are distro-independent and can be shared verbatim.
