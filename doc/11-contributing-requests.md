# Contributing requests

Things maintainers would welcome from contributors, roughly ordered by value.
Comment on (or open) an issue before starting, so work does not duplicate.

## Package-manager ports of the onboarding script

`tools/onboard.sh` supports Fedora only. Wanted: equivalent scripts (or flags)
for other distributions' package managers — `apt` (Debian/Ubuntu), `pacman`
(Arch), `apk` (Alpine/postmarketOS) at minimum. Acceptance per port:

- Fresh install of that distro + script = `meson setup build`,
  `meson compile -C build`, `meson test -C build` all green.
- Maps every package in the Fedora lists (including `-devel` equivalents and
  the vala-lint source build in `--with-lint`).
- Progress is tracked in [.features/portable-onboarding](.features/portable-onboarding.md).

## Translation review (French, Spanish, German)

`po/*.po` files are LLM drafts. Native speakers: fix gender, plurals and
audio-domain terms (`tags`, `cover`, `revert` are the contested ones).
See [.features/translations](.features/translations.md).

## App icon

The current icon is a placeholder. Design one in the GNOME language; checklist
in [.features/app-icon](.features/app-icon.md).

## Test-plan runs

Work through [10-test-plan](../10-test-plan.md) (fixtures via
`tests/fixtures/make-fixtures.sh`) and record results in its run log —
especially the I18N cases and the FLAC/M4A best-effort rows.
