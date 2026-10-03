# Contributing

- Follow the size rule and layering in [03-architecture.md](03-architecture.md).
- No business logic in views; no widget code in services.
- Log user actions with `AppLogger.action`, failures with `AppLogger.error`
  and surface failures as toasts.
- Add new framework-free code to `core_sources` and cover it in `tests/`.
- Add test cases for new features to [10-test-plan.md](10-test-plan.md)
- `meson test` must be green, including `lint-vala`/`lint-c` when the tools are installed.
- New user-visible strings need `_()` (or `ngettext`), then regenerate the POT
  and update `po/*.po` (see [translations](.features/translations.md)).
  and extend `tests/fixtures/make-fixtures.sh` when new fixtures are needed.
- Before a PR: `meson compile`, `meson test`, manual checklist in
  [07-testing-qa.md](07-testing-qa.md).
- New features start as a file in [.features](.features/README.md).
- New dependencies go in three places: `tools/onboard.sh`, the README
  prerequisites, and [02-getting-started](02-getting-started.md).
- Icons and raster images must follow the GNOME design language (see
  [app-icon](.features/app-icon.md)).
